provider "relay" {}

provider "aws" {
  region = "us-east-1"
}

variable "workspace_id" {
  type = string
}

variable "app_vpc" {
  type = object({ id = string, subnet_ids = list(string) })
}

variable "analytics_vpc" {
  type = object({ id = string, subnet_ids = list(string), cidr = string })
}

module "app" {
  source = "../.."

  workspace_id = var.workspace_id

  aws = {
    vpc_id     = var.app_vpc.id
    subnet_ids = var.app_vpc.subnet_ids
  }
}

module "analytics" {
  source = "../.."

  workspace_id = var.workspace_id
  name_prefix  = "relay-analytics"

  aws = {
    vpc_id         = var.analytics_vpc.id
    subnet_ids     = var.analytics_vpc.subnet_ids
    allowed_cidrs  = [var.analytics_vpc.cidr]
    create_service = false
    service_id     = module.app.aws.service_id
  }
}

output "indexes" {
  value = {
    app       = module.app.aws.index
    analytics = module.analytics.aws.index
  }
}
