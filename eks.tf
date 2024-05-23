module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.11.1"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_public_access  = var.endpoint_public_access
  cluster_endpoint_private_access = var.endpoint_private_access
  kms_key_administrators          = ["arn:aws:iam::${var.aws_account}:root"]
  kms_key_aliases                 = ["${var.cluster_name}-${var.environment}"]

  authentication_mode = "API_AND_CONFIG_MAP"

  enable_cluster_creator_admin_permissions = true

  # access_entries = {
  #   fullAccess = {
  #     kubernetes_groups = []
  #     principal_arn     = var.cluster_admin

  #     policy_associations = {
  #       clusterAdmin = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  #         access_scope = {
  #           type = "cluster"
  #         }
  #       }
  #     }
  #   }
  # }

  cluster_security_group_additional_rules = {
    ingress_private_access = {
      description = "Private Access to EKS"
      protocol    = "-1"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = var.cidr_blocks
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_controlplane = {
      description                   = "Controlplane to node"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  vpc_id     = data.aws_vpc.vpc.id
  subnet_ids = data.aws_subnets.subnets.ids

  eks_managed_node_group_defaults = {
    cluster_version            = var.node_version
    use_name_prefix            = false
    platform                   = "bottlerocket"
    ami_type                   = "BOTTLEROCKET_ARM_64"
    subnet_ids                 = data.aws_subnets.subnets.ids
    iam_role_attach_cni_policy = true
    iam_role_additional_policies = {
      additional                    = aws_iam_policy.autoscale.arn
      "CloudWatchAgentServerPolicy" = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    }
  }

  eks_managed_node_groups = {
    node-addons = {
      name            = "addons"
      create_iam_role = true

      min_size     = 1
      max_size     = 2
      desired_size = 1

      capacity_type = "SPOT"

      instance_types = ["m6g.medium", "m7g.medium", "t4g.medium"]

      taints = {
        dedicated = {
          key    = "CriticalAddonsOnly"
          effect = "NO_SCHEDULE"
        }
      }

      labels = {
        node = "addons"
      }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 5
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
        xvdb = {
          device_name = "/dev/xvdb"
          ebs = {
            volume_size           = 30
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      tags = var.tags
    }
  }

  tags = var.tags
}