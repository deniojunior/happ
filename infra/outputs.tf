 output "ecr_repository" {
  value       = module.ecr.repository_name
  description = "ECR repository name"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "ECR repository URL"
}

output "frontend_bucket" {
  value       = module.s3_bucket.this_s3_bucket_id
  description = "Frontend s3 bucket"
}
