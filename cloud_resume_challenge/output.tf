# CREATES AN OUTPUT IN THE TERMINAL for the URL of the AWS API GATEWAY
output "api-gateway-url" {
  value = aws_api_gateway_deployment.example.invoke_url
}

# ✅ 7. Output CloudFront URL
output "cloudfront_url" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}