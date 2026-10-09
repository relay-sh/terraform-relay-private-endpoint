variable "workspace_id" {
  description = "Workspace whose databases the endpoint reaches."
  type        = string
}

variable "aws" {
  description = "AWS PrivateLink endpoint in the aws provider's region. See the aws submodule for each field."
  type = object({
    vpc_id             = string
    subnet_ids         = list(string)
    security_group_ids = optional(list(string))
    allowed_cidrs      = optional(list(string))
    ports              = optional(list(number), [5432])
    create_service     = optional(bool, true)
    service_id         = optional(string)
  })
  default = null
}

variable "name_prefix" {
  description = "Prefix for the names of the cloud resources the module creates."
  type        = string
  default     = "relay"
}

variable "tags" {
  description = "Tags for the cloud resources the module creates."
  type        = map(string)
  default     = {}
}
