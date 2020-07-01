output "frontend_bucket" {
  value       = module.s3_bucket.this_s3_bucket_id
  description = "Frontend s3 bucket"
}

output "acm_certificate_arn" {
  value       = module.acm.this_acm_certificate_arn
  description = "ACM certificace arn"
}
