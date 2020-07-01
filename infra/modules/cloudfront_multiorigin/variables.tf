variable "env" {
  type        = string
  description = "Infrastructure environment"
}

variable "app" {
  type        = string
  description = "Application name"
}

variable "namespace" {
  type        = string
  description = "Application namespace to specify context and avoid bucket name conflicts"
}

variable "aws_region" {
  type        = string
  description = "AWS region where the infrastructure is located"
  default     = "us-east-1"
}

variable "aws_route53_zone" {
  type        = string
  description = "Route 53 zone name"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate arn"
}

variable "alb_dns" {
  type        = string
  description = "ALB DNS address"
}
