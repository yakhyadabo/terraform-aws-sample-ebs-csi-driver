/*variable "iam_role_name" {
  description = "IAM role name"
}*/

variable "kms_key_arn" {
  description = "(Optional) ARN of the AWS KMS key used for volume encryption"
  default = ""
}

variable "oidc_provider_url" {
  description = "OpenID Connect (OIDC) Identity Provider associated with the EKS cluster"
}

variable "cluster_name" {
  description = "Name of the cluster"
}

variable "namespace" {
  description = "Namespace on which to install"
  default = "kube-system"
}

variable "service_account" {
  description = "Name of the service account"
  default = "ebs-csi-controller-sa"
}
