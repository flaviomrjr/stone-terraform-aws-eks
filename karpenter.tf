################################################################################
# Karpenter
################################################################################

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.11.1"

  cluster_name = module.eks.cluster_name

  enable_irsa            = true
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  enable_spot_termination = true

  create_access_entry = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    additional                   = aws_iam_policy.autoscale.arn
  }

  tags = var.tags
}
