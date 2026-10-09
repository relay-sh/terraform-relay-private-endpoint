variable "workspace_id" {
  description = "Workspace whose databases the endpoint reaches."
  type        = string
}

variable "vpc_id" {
  description = "VPC the endpoint is created in, in the aws provider's region."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the endpoint's network interfaces. Those outside the availability zones the Relay endpoint service is offered in are skipped."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "subnet_ids must contain at least one subnet."
  }
}

variable "security_group_ids" {
  description = "Security groups for the endpoint. When null, the module creates one that opens ports to allowed_cidrs."
  type        = list(string)
  default     = null
}

variable "allowed_cidrs" {
  description = "Sources the created security group admits. Defaults to the VPC's CIDR."
  type        = list(string)
  default     = null

  validation {
    condition     = var.allowed_cidrs == null || var.security_group_ids == null
    error_message = "allowed_cidrs configures the security group the module creates; it cannot be combined with security_group_ids."
  }
}

variable "ports" {
  description = "Ports the created security group opens."
  type        = list(number)
  default     = [5432]
}

variable "create_service" {
  description = "Create the workspace's endpoint service in this region. Set to false for a second VPC in a region that already has one, and pass its service_id."
  type        = bool
  default     = true
}

variable "service_id" {
  description = "Existing relay_private_endpoint_service to register on when create_service is false."
  type        = string
  default     = null

  validation {
    condition     = var.create_service == (var.service_id == null)
    error_message = "Set service_id exactly when create_service is false."
  }
}

variable "name_prefix" {
  description = "Prefix for the names of the AWS resources the module creates."
  type        = string
  default     = "relay"
}

variable "tags" {
  description = "Tags for the AWS resources the module creates."
  type        = map(string)
  default     = {}
}
