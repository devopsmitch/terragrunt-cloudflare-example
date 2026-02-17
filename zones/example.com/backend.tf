terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "cloudflare/example.com/terraform.tfstate"
    region = "us-east-1"
  }
}
