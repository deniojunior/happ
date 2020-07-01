env       = "prod"
app       = "happ"
namespace = "dj"

aws_region        = "us-east-1"
aws_route53_zone  = "devsforlife.org"

vpc_cidr = "10.0.0.0/16"
vpc_private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
vpc_public_subnets = ["10.0.2.0/24", "10.0.3.0/24"]

eks_node_instance_type = "t3.small"
eks_node_asg_max_size = 1

app_health_check_path = "/healthz"
