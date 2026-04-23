terraform {
  backend "s3" {
    bucket = "dev-proj-1-jenkins-remote-state-bucket-713205"
    key    = "devops-project-1/terraform.tfstate"
    region = "ap-south-1"
  }
}