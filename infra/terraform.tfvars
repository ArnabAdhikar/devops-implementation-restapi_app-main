bucket_name = "dev-proj-1-remote-state-bucket"
name        = "environment"
environment = "dev-1"

vpc_cidr             = "10.0.0.0/16"
vpc_name             = "dev-proj-ap-south-2-vpc-1"
cidr_public_subnet   = ["10.0.1.0/24", "10.0.2.0/24"]
cidr_private_subnet  = ["10.0.3.0/24", "10.0.4.0/24"]
eu_availability_zone = ["ap-south-2a", "ap-south-2b"]

public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEYwTZqDNcncTIBIlW0CD2uNJ4cP7QErdcVWWzG232WQ arnab-adhikary@arnab-adhikary"
ec2_ami_id     = "aami-070e5bd3ff10324f8"

ec2_user_data_install_apache = ""

domain_name = "arnaba075.com"