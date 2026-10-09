data "aws_region" "current" {}

data "relay_private_endpoint_service" "existing" {
  count = var.create_service ? 0 : 1

  workspace_id = var.workspace_id
  id           = var.service_id
}

data "aws_vpc_endpoint_service" "relay" {
  service_name = local.service.endpoint_service_name
}

data "aws_subnet" "this" {
  for_each = toset(var.subnet_ids)

  id = each.value
}

data "aws_vpc" "this" {
  count = var.security_group_ids == null && var.allowed_cidrs == null ? 1 : 0

  id = var.vpc_id
}
