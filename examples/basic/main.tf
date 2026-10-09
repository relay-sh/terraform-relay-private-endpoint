provider "relay" {}

provider "aws" {
  region = "us-east-1"
}

variable "workspace_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

module "private_endpoint" {
  source = "../.."

  workspace_id = var.workspace_id

  aws = {
    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids
  }
}

output "private_endpoint" {
  value = module.private_endpoint.aws
}
