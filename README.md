# terraform-relay-private-endpoint

Connects a VPC to a Relay workspace's databases over a private endpoint, end to
end: the workspace's endpoint service, the cloud-side endpoint, and its
registration. The platform accepts the connection by itself, so one apply ends
with the endpoint `AVAILABLE` and the databases answering on
`<name>-pl-<index>` and `<name>-ro-pl-<index>` from inside the VPC. Private
routes are not subject to the workspace's IP access list.

```hcl
provider "aws" {
  region = "us-east-1"
}

module "private_endpoint" {
  source  = "relay-sh/private-endpoint/relay"
  version = "~> 0.0.1"

  workspace_id = module.workspace.workspace_id

  aws = {
    vpc_id     = "vpc-0123456789abcdef0"
    subnet_ids = ["subnet-0aaa", "subnet-0bbb", "subnet-0ccc"]
  }
}
```

Only AWS is served today. The endpoint is created in the `aws` provider's
region; for several regions, call the module once per region with an aliased
provider. A workspace has one endpoint service per region, so a second VPC in
the same region sets `create_service = false` and passes the first call's
`service_id` (`examples/second-vpc`). The flag is separate from `service_id`
because the ID is usually unknown until apply, and the plan has to know whether
to create a service.

Apply returns once the connection is `AVAILABLE`; the endpoint's hostnames
can take another minute or two to be published. Until then the names resolve
to the public endpoints, and a resolver that asked early keeps that answer for
up to a minute.

Subnets in availability zones the Relay endpoint service is not offered in are
dropped, so passing every subnet of a VPC works; the plan fails if none is
left. Without `security_group_ids`, the module creates a security group that
opens `ports` (default `5432`) to `allowed_cidrs`, or to the VPC's CIDR.

Destroying the module rejects the connection on the AWS side, and AWS never
accepts a rejected VPC endpoint again. Replacing only the registration
(`terraform apply -replace` on `relay_private_endpoint`) therefore fails with
`REJECTED`; replace the VPC endpoint with it.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_relay"></a> [relay](#requirement\_relay) | ~> 0.0.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_aws"></a> [aws](#module\_aws) | ./aws | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | Workspace whose databases the endpoint reaches. | `string` | n/a | yes |
| <a name="input_aws"></a> [aws](#input\_aws) | AWS PrivateLink endpoint in the aws provider's region. See the aws submodule for each field. | <pre>object({<br/>    vpc_id             = string<br/>    subnet_ids         = list(string)<br/>    security_group_ids = optional(list(string))<br/>    allowed_cidrs      = optional(list(string))<br/>    ports              = optional(list(number), [5432])<br/>    create_service     = optional(bool, true)<br/>    service_id         = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for the names of the cloud resources the module creates. | `string` | `"relay"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the cloud resources the module creates. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_aws"></a> [aws](#output\_aws) | The AWS endpoint, null when aws is not set. |
<!-- END_TF_DOCS -->
