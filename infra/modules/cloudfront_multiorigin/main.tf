resource "aws_cloudfront_distribution" "cf_distribution" {
  origin {
    domain_name = var.bucket_regional_domain_name
    origin_id   = var.s3_bucket_id
  }

  enabled             = true
  default_root_object = var.default_root_object

  aliases = ["${var.app_subdomain}.${var.route53_zone}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_bucket_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/frontend"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_bucket_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.lambda_edge.qualified_arn
      include_body = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(var.tags, { Name = "${var.resource}-cdn" })

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method = "sni-only"
  }

  depends_on = [
    aws_lambda_function.lambda_edge
  ]

}

resource "aws_route53_record" "cname" {
  zone_id = var.route53_zone_id
  name    = var.app_subdomain
  type    = "CNAME"
  ttl     = "5"

  records = [aws_cloudfront_distribution.cf_distribution.domain_name]

  depends_on = [
    aws_cloudfront_distribution.cf_distribution
  ]
}

resource "aws_lambda_function" "lambda_edge" {
  filename         = var.lamba_edge_payload_filename
  function_name    = "${var.resource}-lambda-edge"
  role             = aws_iam_role.lambda_edge_role.arn
  handler          = var.lamba_edge_handler
  runtime          = var.lambda_edge_runtime
  publish          = true
  
  tags             = merge(var.tags, {Name = "${var.resource}-lambda-edge"})
  source_code_hash = "filebase64sha256(${var.lamba_edge_payload_filename})"
}

resource "aws_iam_role" "lambda_edge_role" {
  name = "${var.resource}-lambda-edge-iam-role"

  tags = merge(var.tags, {Name = "${var.resource}-lambda-role"})

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name = "${var.resource}-lambda-edge-iam-policy"

  policy =  <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
  ]
} 
EOF
}

resource "aws_iam_policy_attachment" "policy_attachment" {
  name       = "attachment"
  roles      = [aws_iam_role.lambda_edge_role.name]
  policy_arn = aws_iam_policy.policy.arn
}
