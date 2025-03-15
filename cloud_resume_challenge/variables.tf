variable "AWS_REGION" {
  default   = "ap-southeast-1"
  type      = string
  sensitive = true
}

variable "S3_BUCKET_NAME" {

  default   = "rc-portfolio-terraform"
  type      = string
  sensitive = true

}
