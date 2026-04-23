#!/bin/bash
set -euo pipefail

APP_DIR="/home/ubuntu/python-mysql-db-sample-devops"
VENV_DIR="/home/ubuntu/python-mysql-db-sample-devops/.venv"
DB_HOST="${rds_endpoint}"
DB_USER="${db_user}"
DB_PASSWORD="${db_password}"
DB_NAME="${db_name}"

exec > >(tee -a /var/log/user-data.log) 2>&1

cd /home/ubuntu
apt-get update -y
apt-get install -y git python3 python3-pip python3-venv

if [ -d "$APP_DIR/.git" ]; then
	cd "$APP_DIR"
	git pull --ff-only
else
	git clone https://github.com/ArnabAdhikar/python-mysql-db-sample-devops.git "$APP_DIR"
fi

cd "$APP_DIR"

# Override repo defaults with runtime infrastructure values.
sed -i -E "s#host='[^']*'#host='$${DB_HOST}'#" app.py
sed -i -E "s#user='[^']*'#user='$${DB_USER}'#" app.py
sed -i -E "s#password='[^']*'#password='$${DB_PASSWORD}'#" app.py
sed -i -E "s#db='[^']*'#db='$${DB_NAME}'#" app.py

python3 -m venv "$VENV_DIR"
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install -r requirements.txt

# Keep app running in background and persist logs for debugging ALB health checks.
pkill -f "app.py" || true
nohup "$VENV_DIR/bin/python" -u app.py > /var/log/python-api.log 2>&1 &

# Quick local health probe for cloud-init log visibility.
sleep 5
curl -fsS http://127.0.0.1:5000/health || true