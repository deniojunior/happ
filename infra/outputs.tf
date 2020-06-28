 output "ecr_repository" {
  value       = aws_ecr_repository.ecr_repository.name
  description = "ECR repository name"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.ecr_repository.repository_url
  description = "ECR repository URL"
}

output "frontend_bucket" {
  value       = module.s3_bucket.this_s3_bucket_id
  description = "Frontend s3 bucket"
}
