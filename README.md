# Terraform + Jenkins AWS Infrastructure for REST API

This repository provisions AWS infrastructure for a Python REST API backed by MySQL and supports pipeline-driven infrastructure operations through Jenkins.

The stack is primarily built with Terraform modules under `infra/` and a parameterized Jenkins pipeline in `Jenkinsfile` for `init`, `plan`, `apply`, and `destroy`.

---

## Project Overview

The infrastructure provisions:

- A custom VPC with public and private subnets
- Security groups for EC2, API port exposure, and RDS MySQL access
- An EC2 instance that clones and runs a sample Python API on startup
- An Application Load Balancer with HTTP and HTTPS listeners
- Route53 hosted zone integration for domain mapping
- ACM certificate wiring for HTTPS on the ALB
- RDS MySQL instance and subnet group

Pipeline automation in Jenkins lets you choose whether to run:

- Terraform plan
- Terraform apply
- Terraform destroy

---

## Repository Structure

```text
.
├── Jenkinsfile
└── infra
    ├── main.tf
    ├── provider.tf
    ├── remote_backend_s3.tf
    ├── terraform.tfvars
    ├── variables.tf
    ├── outputs.tf
    ├── networking/
    ├── security-groups/
    ├── ec2/
    ├── load-balancer/
    ├── load-balancer-target-group/
    ├── hosted-zone/
    ├── certificate-manager/
    ├── rds/
    ├── s3/                  # currently commented out in root module
    └── template/
        └── ec2_install_apache.sh
```

---

## Architecture Flow

1. Terraform creates networking resources (VPC, subnets, route tables, IGW).
2. Security groups are created for:
   - SSH/HTTP/HTTPS to EC2
   - API traffic on port `5000`
   - MySQL traffic to RDS (`3306`) from public subnet CIDRs
3. EC2 is launched with user data (`infra/template/ec2_install_apache.sh`) that:
   - Installs Python and pip
   - Clones the sample app repository
   - Installs Python dependencies
   - Runs `app.py`
4. A target group and ALB route traffic to the API on port `5000`.
5. Route53 and ACM are used for domain and HTTPS certificate integration.
6. RDS MySQL is provisioned and attached to the VPC security configuration.

---

## Prerequisites

Before running Terraform locally or via Jenkins, ensure:

- AWS account access with permissions to create VPC, EC2, ALB, Route53, ACM, RDS, IAM-related resources used by providers and modules
- Terraform installed (recommended `>= 1.4`)
- AWS CLI configured (for local execution)
- A valid SSH public key (used in `terraform.tfvars`)
- A registered domain in Route53 (or a domain you control) for hosted zone / ACM flow
- Jenkins with:
  - Pipeline plugin
  - AWS credentials binding plugin
  - Terraform available on Jenkins agent

---

## Configure the Project

### 1) Review provider and backend settings

Check:

- `infra/provider.tf` for region and credentials strategy
- `infra/remote_backend_s3.tf` for remote state bucket and key

> Recommended: use environment variables or IAM roles instead of hardcoded credential paths.

### 2) Update variable values

Edit `infra/terraform.tfvars` with your own values:

- `vpc_cidr`, subnet CIDRs, availability zones
- `public_key`
- `ec2_ami_id`
- `domain_name`
- other environment-specific values

### 3) Initialize Terraform

From repo root:

```bash
cd infra
terraform init
```

---

## Local Terraform Workflow

```bash
cd infra
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Destroy when needed:

```bash
cd infra
terraform destroy
```

---

## Jenkins Pipeline Usage

`Jenkinsfile` exposes three boolean parameters:

- `PLAN_TERRAFORM`
- `APPLY_TERRAFORM`
- `DESTROY_TERRAFORM`

Pipeline stage order:

1. Clone repository
2. Terraform init
3. Terraform plan (if `PLAN_TERRAFORM=true`)
4. Terraform apply (if `APPLY_TERRAFORM=true`)
5. Terraform destroy (if `DESTROY_TERRAFORM=true`)

### Jenkins Setup Notes

- Configure AWS credentials in Jenkins and map to expected credential ID.
- Ensure the Jenkins agent can execute `terraform`.
- Validate that the branch and repository URL in `Jenkinsfile` match your repository.

---

## Module Summary

- `networking/`: VPC, public/private subnets, IGW, route tables and associations
- `security-groups/`: EC2 ingress (22/80/443), API ingress (`5000`), RDS ingress (`3306`)
- `ec2/`: key pair and API host instance with user-data bootstrap
- `load-balancer-target-group/`: ALB target group on API port
- `load-balancer/`: ALB, target attachment, HTTP and HTTPS listeners
- `hosted-zone/`: DNS records and hosted zone linkage
- `certificate-manager/`: ACM certificate and validation resources
- `rds/`: DB subnet group and MySQL instance

---

## Outputs

Current root outputs include:

- `dev_proj_1_vpc_id`

Additional outputs are present but commented in `infra/outputs.tf`.

---

## Important Security and Reliability Notes

Please review before production usage:

- AWS credentials path is hardcoded in `infra/provider.tf`; prefer IAM role or environment-based auth.
- Database credentials are hardcoded in `infra/main.tf`; move to secure secrets handling.
- Security groups currently allow broad inbound traffic (`0.0.0.0/0`) on multiple ports.
- RDS is configured with:
  - `skip_final_snapshot = true`
  - `backup_retention_period = 0`
  - `deletion_protection = false`
  These settings are convenient for dev but risky for production.
- The EC2 bootstrap script clones and runs app code directly; pin versions/commits for reproducibility.

---

## Known Issues to Fix

There are a few configuration inconsistencies you should correct:

- `infra/terraform.tfvars` includes `ec2_ami_id = "aami-070e5bd3ff10324f8"` (likely typo in AMI ID).
- Region and availability zones appear inconsistent between:
  - `infra/provider.tf` (`eu-central-1`)
  - `infra/terraform.tfvars` (uses `ap-south-2*` zones)
- Jenkins credential ID appears as `aws-crendentails-exp` (possible spelling mismatch).
- Jenkins clone URL currently targets a specific external repository; update if needed.

---

## Recommended Next Improvements

- Add `versions.tf` with provider and Terraform version constraints.
- Add `terraform.tfvars.example` and keep sensitive values out of VCS.
- Replace static DB credentials with AWS Secrets Manager or SSM Parameter Store.
- Restrict security group CIDRs to trusted ranges.
- Add CI checks for `terraform fmt`, `validate`, and optional `tflint`.
- Add environment folders (`dev`, `staging`, `prod`) or workspaces for safer lifecycle management.

---

## License

Add your preferred license (for example MIT, Apache-2.0, or proprietary internal use).

