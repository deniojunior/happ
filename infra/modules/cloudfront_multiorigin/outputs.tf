output "frontend_bucket" {
  value       = module.s3_bucket.this_s3_bucket_id
  description = "Frontend s3 bucket"
}
