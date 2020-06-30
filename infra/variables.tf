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

variable "vpc_cidr" {
  type        = string
  description = "AWS VPC cidr"
  default     = "10.0.0.0/16"
}

variable "vpc_private_subnets" {
  type        = list
  description = "EKS node instance type"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "vpc_public_subnets" {
  type        = list
  description = "EKS node instance type"
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "eks_node_instance_type" {
  type        = string
  description = "EKS node instance type"
  default     = "t3.small"
}

variable "eks_node_asg_max_size" {
  type        = number
  description = "Max auto scaling group size for EKS cluster nodes"
  default     = 1
}

variable "app_health_check_path" {
  type        = string
  description = "App health check endpoint"
  default     = "/healthz"
}
