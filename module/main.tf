locals {
  iam_role_name = "ebs-csi-driver"
  kms_key_arn = var.kms_key_arn == "" ? null : var.kms_key_arn
  ebs_addon_name = "aws-ebs-csi-driver"
  ebs_addon_version = "v1.5.2-eksbuild.1"
}

data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "eks_cluster" {
  url = var.oidc_provider_url
}

/*

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
*/

data "aws_iam_policy_document" "ebs_csi_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account}"]
    }

    principals {
      identifiers = [data.aws_iam_openid_connect_provider.eks_cluster.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "ebs_csi" {
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role_policy.json
  name               = local.iam_role_name
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn =  "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role_policy" "kms" {
  count = local.kms_key_arn != null ? 1 : 0
  name   = "kms-permissions"
  role   = aws_iam_role.ebs_csi.id
  policy = templatefile("${path.module}/policies/kms.json.tpl", {
    kms_key_arn = local.kms_key_arn
  })
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = var.cluster_name
  addon_name               = local.ebs_addon_name
  addon_version            = local.ebs_addon_version
  service_account_role_arn = aws_iam_role.ebs_csi.arn
  tags = {
    "eks_addon" = "ebs-csi-driver"
    "terraform" = "true"
  }
}
