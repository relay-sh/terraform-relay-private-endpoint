output "aws" {
  description = "The AWS endpoint, null when aws is not set."
  value       = try(module.aws[0], null)
}
