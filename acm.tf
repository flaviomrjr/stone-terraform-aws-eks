resource "aws_acm_certificate" "cert" {
  count                     = var.create_cert_acm == true ? 1 : 0
  domain_name               = var.domain
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}