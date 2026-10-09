locals {
  region  = data.aws_region.current.region
  service = var.create_service ? relay_private_endpoint_service.this[0] : data.relay_private_endpoint_service.existing[0]
  served_subnets = [
    for id in var.subnet_ids : id
    if contains(data.aws_vpc_endpoint_service.relay.availability_zones, data.aws_subnet.this[id].availability_zone)
  ]
}

resource "relay_private_endpoint_service" "this" {
  count = var.create_service ? 1 : 0

  workspace_id = var.workspace_id
  cloud        = "aws"
  region       = local.region
}

resource "aws_security_group" "this" {
  count = var.security_group_ids == null ? 1 : 0

  name_prefix = "${var.name_prefix}-private-endpoint-"
  description = "Relay private endpoint"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name_prefix}-private-endpoint" })

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidrs != null ? var.allowed_cidrs : [data.aws_vpc.this[0].cidr_block]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_endpoint" "this" {
  vpc_id              = var.vpc_id
  service_name        = local.service.endpoint_service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.served_subnets
  security_group_ids  = var.security_group_ids != null ? var.security_group_ids : [aws_security_group.this[0].id]
  private_dns_enabled = false
  tags                = merge(var.tags, { Name = "${var.name_prefix}-private-endpoint" })

  lifecycle {
    precondition {
      condition     = length(local.served_subnets) > 0
      error_message = "None of subnet_ids is in an availability zone the Relay endpoint service is offered in: ${join(", ", data.aws_vpc_endpoint_service.relay.availability_zones)}."
    }
  }
}

resource "relay_private_endpoint" "this" {
  workspace_id    = var.workspace_id
  service_id      = local.service.id
  vpc_endpoint_id = aws_vpc_endpoint.this.id
}
