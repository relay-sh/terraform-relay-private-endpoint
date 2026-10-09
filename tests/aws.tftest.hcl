mock_provider "relay" {
  mock_data "relay_private_endpoint_service" {
    defaults = {
      endpoint_service_name = "com.amazonaws.vpce.us-east-1.vpce-svc-existing"
    }
  }
  mock_resource "relay_private_endpoint_service" {
    defaults = {
      id                    = "pes-1"
      endpoint_service_name = "com.amazonaws.vpce.us-east-1.vpce-svc-0123456789abcdef0"
    }
  }
  mock_resource "relay_private_endpoint" {
    defaults = {
      id                = "pe-1"
      index             = 0
      connection_status = "AVAILABLE"
    }
  }
}

mock_provider "aws" {
  mock_data "aws_region" {
    defaults = {
      region = "us-east-1"
    }
  }
  mock_data "aws_vpc_endpoint_service" {
    defaults = {
      availability_zones = ["us-east-1a", "us-east-1b"]
    }
  }
  mock_data "aws_subnet" {
    defaults = {
      availability_zone = "us-east-1a"
    }
  }
  mock_data "aws_vpc" {
    defaults = {
      cidr_block = "10.0.0.0/16"
    }
  }
  mock_resource "aws_security_group" {
    defaults = {
      id = "sg-created"
    }
  }
  mock_resource "aws_vpc_endpoint" {
    defaults = {
      id = "vpce-0123456789abcdef0"
    }
  }
}

mock_provider "aws" {
  alias = "unserved_zone"

  mock_data "aws_region" {
    defaults = {
      region = "us-east-1"
    }
  }
  mock_data "aws_vpc_endpoint_service" {
    defaults = {
      availability_zones = ["us-east-1a", "us-east-1b"]
    }
  }
  mock_data "aws_subnet" {
    defaults = {
      availability_zone = "us-east-1e"
    }
  }
  mock_data "aws_vpc" {
    defaults = {
      cidr_block = "10.0.0.0/16"
    }
  }
}

variables {
  workspace_id = "ws-1"
  vpc_id       = "vpc-1"
  subnet_ids   = ["subnet-a", "subnet-b"]
}

run "full_chain" {
  command = apply

  module {
    source = "./aws"
  }

  assert {
    condition     = relay_private_endpoint_service.this[0].region == "us-east-1" && relay_private_endpoint_service.this[0].cloud == "aws"
    error_message = "a service is created in the provider's region"
  }

  assert {
    condition     = aws_vpc_endpoint.this.service_name == "com.amazonaws.vpce.us-east-1.vpce-svc-0123456789abcdef0" && aws_vpc_endpoint.this.vpc_endpoint_type == "Interface"
    error_message = "the VPC endpoint connects to the service"
  }

  assert {
    condition     = aws_vpc_endpoint.this.subnet_ids == toset(["subnet-a", "subnet-b"])
    error_message = "subnets in the service's availability zones are kept"
  }

  assert {
    condition     = aws_vpc_endpoint.this.security_group_ids == toset(["sg-created"])
    error_message = "a security group is created when none is given"
  }

  assert {
    condition     = one(aws_security_group.this[0].ingress).cidr_blocks == tolist(["10.0.0.0/16"]) && one(aws_security_group.this[0].ingress).from_port == 5432
    error_message = "the created security group opens 5432 to the VPC"
  }

  assert {
    condition     = relay_private_endpoint.this.vpc_endpoint_id == "vpce-0123456789abcdef0" && relay_private_endpoint.this.service_id == "pes-1"
    error_message = "the VPC endpoint is registered on the service"
  }

  assert {
    condition     = output.connection_status == "AVAILABLE" && output.subnet_ids == tolist(["subnet-a", "subnet-b"]) && output.service_id == "pes-1"
    error_message = "outputs expose the endpoint"
  }
}

run "existing_service_and_security_group" {
  command = apply

  module {
    source = "./aws"
  }

  variables {
    subnet_ids         = ["subnet-a"]
    security_group_ids = ["sg-mine"]
    create_service     = false
    service_id         = "pes-existing"
  }

  assert {
    condition     = length(relay_private_endpoint_service.this) == 0 && length(aws_security_group.this) == 0
    error_message = "an existing service and security group are reused, not created"
  }

  assert {
    condition     = relay_private_endpoint.this.service_id == "pes-existing" && aws_vpc_endpoint.this.security_group_ids == toset(["sg-mine"])
    error_message = "the endpoint uses the given service and security group"
  }
}

run "allowed_cidrs_and_ports" {
  command = apply

  module {
    source = "./aws"
  }

  variables {
    subnet_ids    = ["subnet-a"]
    allowed_cidrs = ["10.1.0.0/24"]
    ports         = [5432, 6432]
  }

  assert {
    condition     = length(aws_security_group.this[0].ingress) == 2 && alltrue([for i in aws_security_group.this[0].ingress : i.cidr_blocks == tolist(["10.1.0.0/24"])])
    error_message = "allowed_cidrs replaces the VPC CIDR, once per port"
  }
}

run "no_served_subnet" {
  command = plan

  module {
    source = "./aws"
  }

  providers = {
    relay = relay
    aws   = aws.unserved_zone
  }

  variables {
    subnet_ids = ["subnet-e"]
  }

  expect_failures = [aws_vpc_endpoint.this]
}

run "conflicting_security_group_inputs" {
  command = plan

  module {
    source = "./aws"
  }

  variables {
    security_group_ids = ["sg-mine"]
    allowed_cidrs      = ["10.1.0.0/24"]
  }

  expect_failures = [var.allowed_cidrs]
}

run "service_id_without_create_service_false" {
  command = plan

  module {
    source = "./aws"
  }

  variables {
    service_id = "pes-existing"
  }

  expect_failures = [var.service_id]
}

run "create_service_false_without_service_id" {
  command = plan

  module {
    source = "./aws"
  }

  variables {
    create_service = false
  }

  expect_failures = [var.service_id]
}

run "no_subnets" {
  command = plan

  module {
    source = "./aws"
  }

  variables {
    subnet_ids = []
  }

  expect_failures = [var.subnet_ids]
}

run "root_passes_aws_through" {
  command = apply

  variables {
    aws = {
      vpc_id     = "vpc-1"
      subnet_ids = ["subnet-a"]
      ports      = [6432]
    }
    name_prefix = "acme"
  }

  assert {
    condition     = output.aws.vpc_endpoint_id == "vpce-0123456789abcdef0" && output.aws.service_id == "pes-1" && output.aws.subnet_ids == tolist(["subnet-a"])
    error_message = "the root module exposes the aws endpoint"
  }
}

run "root_without_cloud" {
  command = apply

  assert {
    condition     = output.aws == null
    error_message = "without aws nothing is created"
  }
}
