remote_state {
  backend = "s3"
  config = {
    bucket = "terraform-state"
    key    = "cloudflare/${path_relative_to_include()}/terraform.tfstate"
    region = "auto"

    endpoints = { s3 = "https://${get_env("CLOUDFLARE_ACCOUNT_ID")}.r2.cloudflarestorage.com" }

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.11"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}
EOF
}
