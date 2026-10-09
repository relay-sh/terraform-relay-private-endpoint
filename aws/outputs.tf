output "service_id" {
  description = "Relay private endpoint service ID."
  value       = local.service.id
}

output "endpoint_service_name" {
  description = "AWS VPC endpoint service name the endpoint connects to."
  value       = local.service.endpoint_service_name
}

output "vpc_endpoint_id" {
  description = "AWS VPC endpoint ID."
  value       = aws_vpc_endpoint.this.id
}

output "subnet_ids" {
  description = "Subnets the endpoint was placed in, after dropping those outside the service's availability zones."
  value       = tolist(local.served_subnets)
}

output "security_group_ids" {
  description = "Security groups attached to the endpoint."
  value       = aws_vpc_endpoint.this.security_group_ids
}

output "private_endpoint_id" {
  description = "Relay private endpoint ID."
  value       = relay_private_endpoint.this.id
}

output "index" {
  description = "Index in the databases' hostnames: <name>-pl-<index> and <name>-ro-pl-<index>."
  value       = relay_private_endpoint.this.index
}

output "connection_status" {
  description = "Connection status, AVAILABLE once apply returns."
  value       = relay_private_endpoint.this.connection_status
}
