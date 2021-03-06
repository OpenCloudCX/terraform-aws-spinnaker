# Complete example

terraform {
  required_version = "~> 0.13"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 3.0"
}

provider "aws" {
  alias               = "prod"
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 3.0"
}

# spinnaker
module "spinnaker" {
  source  = "Young-ook/spinnaker/aws"
  version = "~> 2.0"

  name   = "example"
  stack  = "dev"
  detail = "module-test"
  tags   = { "env" = "dev" }
  region = "ap-northeast-2"
  azs    = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  cidr   = "10.0.0.0/16"

  container_insights_enabled = true
  kubernetes_version         = "1.17"
  kubernetes_node_groups = {
    default = {
      instance_type = "m5.large"
      min_size      = "1"
      max_size      = "3"
      desired_size  = "2"
    }
  }

  aurora_cluster = {
    version = "5.7.12"
    port    = "3306"
  }
  aurora_instances = {
    main = {
      node_type = "db.t3.medium"
    }
  }

  helm = {
    version = "2.2.2"
    values  = join("/", [path.cwd, "values.yaml"])
  }
  assume_role_arn = [module.spinnaker-managed-role.role_arn]
}

# spinnaker managed role
module "spinnaker-managed-role" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-aws"
  version = "~> 2.0"

  providers        = { aws = aws.prod }
  name             = "example"
  stack            = "dev"
  trusted_role_arn = [module.spinnaker.role_arn]
}
