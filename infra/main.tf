locals {
  resource = "${var.app}-${var.namespace}-${var.env}"
  app_name = var.env == "prod" ? "${var.app}" : "${var.app}-${var.env}"
  tags = {
    Application = var.app
    Environment = var.env
  }
}

module "terraform_state_backend" {
  source                             = "git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git?ref=master"
  namespace                          = "${var.app}-${var.namespace}"
  name                               = "terraform"
  environment                        = var.env
  attributes                         = ["state"]
  region                             = "us-east-1"
  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = true
  prevent_unencrypted_uploads        = false
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = "${local.resource}-frontend"
  acl           = "private"
  force_destroy = true

  website = {
    index_document = "index.html"
  }

  tags = merge(local.tags, { Name = "${local.resource}-frontend_bucket" })

  attach_policy = true
  policy        = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicReadAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${local.resource}-frontend/*"
      ]
    }
  ]
}
POLICY
}

module "ecr" {
  source          = "git::https://github.com/cloudposse/terraform-aws-ecr.git?ref=master"
  name            = local.resource
  max_image_count = 5
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name = var.aws_route53_zone
  zone_id     = data.aws_route53_zone.selected.id

  subject_alternative_names = [
    "*.${var.aws_route53_zone}"
  ]

  tags = merge(local.tags, { Name = "${local.resource}-certificate" })
}

module "cloufront_multiorigin" {
  source = "./modules/cloudfront_multiorigin"

  lamba_edge_payload_filename = "./modules/cloudfront_multiorigin/resources/lambda_edge_payload.zip"
  lamba_edge_handler          = "lambda_edge_function.handler"

  bucket_regional_domain_name = module.s3_bucket.this_s3_bucket_bucket_regional_domain_name
  s3_bucket_id                = module.s3_bucket.this_s3_bucket_id
  app_subdomain               = local.app_name
  acm_certificate_arn         = module.acm.this_acm_certificate_arn
  route53_zone                = var.aws_route53_zone
  route53_zone_id             = data.aws_route53_zone.selected.id

  module_depends_on = [
    module.acm,
    module.alb,
    module.s3_bucket
  ]

  resource = local.resource
  tags     = local.tags
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.resource}-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  
  private_subnets = var.vpc_private_subnets
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.resource}-eks" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnets  = var.vpc_public_subnets
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.resource}-eks" = "shared"
    "kubernetes.io/role/elb" = "1"
  }

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = merge(local.tags, { Name = "${local.resource}-vpc" })
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "${local.resource}-eks"
  cluster_version = "1.16"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true

  worker_groups = [
    {
      instance_type = var.eks_node_instance_type
      asg_max_size  = var.eks_node_asg_max_size
    }
  ]

  tags = merge(local.tags, { Name = "${local.resource}-eks" })
}

module "alb_ingress_controller" {
  source  = "iplabs/alb-ingress-controller/kubernetes"
  version = "3.4.0"

  providers = {
    kubernetes = "kubernetes"
  }

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = var.aws_region
  k8s_cluster_name = data.aws_eks_cluster.cluster.name
}

module "alb" {
  source                            = "git::https://github.com/cloudposse/terraform-aws-alb.git?ref=tags/0.7.0"
  name                              = local.resource
  vpc_id                            = module.vpc.vpc_id
  security_group_ids                = [module.vpc.default_security_group_id]
  subnet_ids                        = module.vpc.public_subnets
  http_enabled                      = true
  cross_zone_load_balancing_enabled = true
  ip_address_type                   = "ipv4"
  target_group_port                 = 80
  target_group_target_type          = "ip"
  access_logs_enabled               = false
  health_check_path                 = var.app_health_check_path
  tags                              = merge(local.tags, { Name = "${local.resource}-alb" })
}


module "alb_ingress" {
  source                              = "git::https://github.com/cloudposse/terraform-aws-alb-ingress.git?ref=master"
  name                                = local.resource
  vpc_id                              = module.vpc.vpc_id
  default_target_group_enabled        = false
  authentication_type                 = ""
  unauthenticated_priority            = 100
  unauthenticated_paths               = ["/", "/status"]
  target_group_arn                    = module.alb.default_target_group_arn
  unauthenticated_listener_arns       = [module.alb.http_listener_arn]
  unauthenticated_listener_arns_count = 1

  tags = merge(local.tags, { Name = "${local.resource}-alb-ingress" })
}
