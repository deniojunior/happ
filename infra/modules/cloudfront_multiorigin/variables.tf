variable "resource" {
  type        = string
  description = "Infrastructure environment"
}

variable "tags" {
  type        = map
  description = "Application name"
}

variable "route53_zone" {
  type        = string
  description = "Route 53 zone name"
}

variable "route53_zone_id" {
  type        = string
  description = "Route 53 zone identifier"
}

variable "bucket_regional_domain_name" {
  type        = string
  description = "S3 Bucket origin regional domain name"
}

variable "s3_bucket_id" {
  type        = string
  description = "S3 Bucket origin identifier"
}

variable "app_subdomain" {
  type        = string
  description = "Application subdomain"
}

variable "frontend_context" {
  type        = string
  description = "Frontend context"
}

variable "default_root_object" {
  type        = string
  description = "Default root object"
  default     = "index.html"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM Certificate ARN"
}
