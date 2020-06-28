 output "ecr_repository" {
  value       = aws_ecr_repository..ecr_repository.name
  description = "ECR repository name"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository..ecr_repository.repository_url
  description = "ECR repository URL"
}
