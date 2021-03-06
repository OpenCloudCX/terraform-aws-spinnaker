data "aws_partition" "current" {}

locals {
  name = var.name
  default-tags = merge(
    { "terraform.io" = "managed" },
    local.eks-owned-tag
  )
}

# kubernetes tags
locals {
  eks-shared-tag = {
    format("kubernetes.io/cluster/%s", local.name) = "shared"
  }
  eks-owned-tag = {
    format("kubernetes.io/cluster/%s", local.name) = "owned"
  }
  eks-elb-tag = {
    "kubernetes.io/role/elb" = "1"
  }
  eks-internal-elb-tag = {
    "kubernetes.io/role/internal-elb" = "1"
  }
  eks-autoscaler-tag = {
    format("k8s.io/cluster-autoscaler/%s", local.name) = "owned"
  }
  eks-tag = merge(
    {
      "eks:cluster-name"   = local.name
      "eks:nodegroup-name" = local.name
    },
    local.eks-owned-tag,
    local.eks-autoscaler-tag,
  )
}
