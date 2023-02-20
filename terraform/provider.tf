provider "aws" {
    shared_config_files      = ["~/.aws/config"]
    shared_credentials_files = ["~/.aws/credentials"]
    profile                  = "default"
    region = "us-east-1"
}


# aws eks --region us-east-1 update-kubeconfig --name eks-iti