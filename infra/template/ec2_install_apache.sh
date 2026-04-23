#!/bin/bash
set -euo pipefail

APP_DIR="/home/ubuntu/python-mysql-db-sample-devops"

cd /home/ubuntu
apt-get update -y
apt-get install -y git python3 python3-pip

if [ -d "$APP_DIR/.git" ]; then
	cd "$APP_DIR"
	git pull --ff-only
else
	git clone https://github.com/ArnabAdhikar/python-mysql-db-sample-devops.git "$APP_DIR"
fi

cd "$APP_DIR"
pip3 install -r requirements.txt

# Keep app running in background and persist logs for debugging ALB health checks.
pkill -f "python3 -u app.py" || true
nohup python3 -u app.py > /var/log/python-api.log 2>&1 &