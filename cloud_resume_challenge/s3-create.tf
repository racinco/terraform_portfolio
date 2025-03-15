# ✅ 1. Create a Private S3 Bucket
resource "aws_s3_bucket" "terraform_static_web" {
  bucket = var.S3_BUCKET_NAME
}

# ✅ 2. Block Public Access (No Public ACLs)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_static_web.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ✅ 3. Enable S3 Bucket Policy for CloudFront Only
resource "aws_s3_bucket_policy" "allow_cloudfront_and_github" {
  bucket = aws_s3_bucket.terraform_static_web.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Allow CloudFront to access the S3 bucket
      {
        Sid    = "AllowCloudFrontAccess",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.terraform_static_web.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "${aws_cloudfront_distribution.s3_distribution.arn}"
          }
        }
      },

      # Allow GitHub user full access to the S3 bucket
      {
        Sid    = "AllowGitHubUserFullAccess",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::#account_number:user/github_user"
        },
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "${aws_s3_bucket.terraform_static_web.arn}",
          "${aws_s3_bucket.terraform_static_web.arn}/*"
        ]
      }
    ]
  })
}

# ✅ 4. Upload Website Files to S3
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.terraform_static_web.id
  key          = "index.html"
  content      = <<-EOT
    <html>
      <head><title>My Secure CloudFront Website</title></head>
      <body><h1>Welcome to My Private Static Website!</h1></body>
    </html>
  EOT
  content_type = "text/html"
}

# ✅ 5. Create CloudFront Origin Access Control (OAC)
# ALWAYS sign requess since S3 is coming from private bucket. 
resource "aws_cloudfront_origin_access_control" "terraform_oac" {
  name                              = "terraform_oac"
  description                       = "Terraform Origin Access Control for Connecting Cloud Front to S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ✅ 6. Create CloudFront Distribution (CDN)
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {

    # Set the orgin domain 
    domain_name = aws_s3_bucket.terraform_static_web.bucket_regional_domain_name

    # provide the OAC
    origin_access_control_id = aws_cloudfront_origin_access_control.terraform_oac.id
    origin_id                = "terraform_s3_origin"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "terraform_s3_origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # Uses default CloudFront SSL
  }
}

