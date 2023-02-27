locals {
  cluster_name = format("%s-%s", var.project.name, var.project.environment)
  oidc_provider_url = "https://oidc.eks.us-east-1.amazonaws.com/id/808B5186EE6C45CA8E7A669611B19117"
}

module "ebs_csi_driver" {
  source               = "../module"
  cluster_name         = local.cluster_name
  oidc_provider_url    = local.oidc_provider_url
}