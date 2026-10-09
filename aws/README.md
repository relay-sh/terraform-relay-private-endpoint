# aws

The AWS implementation the root module calls. It can also be used directly, as
`relay-sh/private-endpoint/relay//aws`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_relay"></a> [relay](#requirement\_relay) | ~> 0.0.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |
| <a name="provider_relay"></a> [relay](#provider\_relay) | ~> 0.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [relay_private_endpoint.this](https://registry.terraform.io/providers/relay-sh/relay/latest/docs/resources/private_endpoint) | resource |
| [relay_private_endpoint_service.this](https://registry.terraform.io/providers/relay-sh/relay/latest/docs/resources/private_endpoint_service) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_vpc_endpoint_service.relay](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |
| [relay_private_endpoint_service.existing](https://registry.terraform.io/providers/relay-sh/relay/latest/docs/data-sources/private_endpoint_service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets for the endpoint's network interfaces. Those outside the availability zones the Relay endpoint service is offered in are skipped. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC the endpoint is created in, in the aws provider's region. | `string` | n/a | yes |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | Workspace whose databases the endpoint reaches. | `string` | n/a | yes |
| <a name="input_allowed_cidrs"></a> [allowed\_cidrs](#input\_allowed\_cidrs) | Sources the created security group admits. Defaults to the VPC's CIDR. | `list(string)` | `null` | no |
| <a name="input_create_service"></a> [create\_service](#input\_create\_service) | Create the workspace's endpoint service in this region. Set to false for a second VPC in a region that already has one, and pass its service\_id. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for the names of the AWS resources the module creates. | `string` | `"relay"` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | Ports the created security group opens. | `list(number)` | <pre>[<br/>  5432<br/>]</pre> | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security groups for the endpoint. When null, the module creates one that opens ports to allowed\_cidrs. | `list(string)` | `null` | no |
| <a name="input_service_id"></a> [service\_id](#input\_service\_id) | Existing relay\_private\_endpoint\_service to register on when create\_service is false. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the AWS resources the module creates. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_connection_status"></a> [connection\_status](#output\_connection\_status) | Connection status, AVAILABLE once apply returns. |
| <a name="output_endpoint_service_name"></a> [endpoint\_service\_name](#output\_endpoint\_service\_name) | AWS VPC endpoint service name the endpoint connects to. |
| <a name="output_index"></a> [index](#output\_index) | Index in the databases' hostnames: <name>-pl-<index> and <name>-ro-pl-<index>. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Relay private endpoint ID. |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | Security groups attached to the endpoint. |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | Relay private endpoint service ID. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Subnets the endpoint was placed in, after dropping those outside the service's availability zones. |
| <a name="output_vpc_endpoint_id"></a> [vpc\_endpoint\_id](#output\_vpc\_endpoint\_id) | AWS VPC endpoint ID. |
<!-- END_TF_DOCS -->
