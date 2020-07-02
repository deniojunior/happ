output "ecr_repository" {
  value       = module.ecr.repository_name
  description = "ECR repository name"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "ECR repository URL"
}

output "eks_cluster_name" {
  value       = module.eks.cluster_id
  description = "EKS cluster identifier/name"
}

output "acm_certificate_arn" {
  value       = module.acm.this_acm_certificate_arn
  description = "ACM certificace arn"
}
