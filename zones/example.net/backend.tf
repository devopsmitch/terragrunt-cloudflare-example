terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "cloudflare/example.net/terraform.tfstate"
    region = "us-east-1"
  }
}
