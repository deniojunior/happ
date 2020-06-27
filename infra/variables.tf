variable "env" {
  type        = string
  description = "Infrastructure environment"
}

variable "app" {
  type        = string
  description = "Application name"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name responsible to manage terraform state. Defined by TF_VAR_bucket_name."
}

variable "aws_region" {
  type        = string
  description = "AWS region where the infrastructure is located"
  default     = "us-east-1"
}