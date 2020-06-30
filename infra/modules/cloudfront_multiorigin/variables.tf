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

variable "acm_certificate_arn" {
  type        = string
  description = "ACM Certificate ARN"
}

variable "app_subdomain" {
  type        = string
  description = "Application subdomain"
  default     = ""
}

variable "default_root_object" {
  type        = string
  description = "Default root object"
  default     = "index.html"
}

variable "lamba_edge_payload_filename" {
  type        = string
  description = "Lambda Edge payload file path"
  default     = "./resources/lambda_edge_payload.zip"
}

variable "lamba_edge_handler" {
  type        = string
  description = "Lambda Edge handler function"
  default     = "lambda_edge_function.handler"
}

variable "lambda_edge_runtime" {
  type        = string
  description = "Lambda Edge function runtime"
  default     = "nodejs12.x"
}
 