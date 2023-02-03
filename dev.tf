locals {
  cluster_name = format("%s-%s", var.project.name, var.project.environment)
  oidc_provider_url = "https://oidc.eks.us-east-1.amazonaws.com/id/FA0691F33106028DA55B8E849A5CA4B9"
}

module "ebs_csi_driver" {
  source               = "./module"
  cluster_name         = local.cluster_name
  oidc_provider_url    = local.oidc_provider_url
}