module "aws" {
  source = "./aws"
  count  = var.aws == null ? 0 : 1

  workspace_id       = var.workspace_id
  vpc_id             = var.aws.vpc_id
  subnet_ids         = var.aws.subnet_ids
  security_group_ids = var.aws.security_group_ids
  allowed_cidrs      = var.aws.allowed_cidrs
  ports              = var.aws.ports
  create_service     = var.aws.create_service
  service_id         = var.aws.service_id
  name_prefix        = var.name_prefix
  tags               = var.tags
}
