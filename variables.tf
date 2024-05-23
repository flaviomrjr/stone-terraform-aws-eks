variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
}

variable "node_version" {
  description = "The version of the nodes in the EKS cluster"
  type        = string
}

variable "cidr_blocks" {
  description = "The CIDR blocks for the EKS cluster"
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Whether the EKS cluster has public access"
  type        = bool
}

variable "endpoint_private_access" {
  description = "Whether the EKS cluster has private access"
  type        = bool
}

variable "domain" {
  description = "The domain for the EKS cluster"
  type        = string
}

variable "create_cert_acm" {
  description = "Whether to create a certificate in ACM"
  type        = bool
}

variable "environment" {
  description = "The environment for the EKS cluster"
  type        = string
}

variable "aws_account" {
  description = "The AWS account for the EKS cluster"
  type        = string
}

variable "tags" {
  description = "The Resource tags"
  type        = map(string)
}

variable "vpc_name" {
  description = "The VPC for the EKS cluster"
  type        = string
}