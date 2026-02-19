# Terragrunt Cloudflare Multi-Zone Management

Manage multiple Cloudflare zones using Terragrunt with reusable Terraform modules and isolated state per zone.

## Prerequisites

- Terragrunt >= 0.50
- OpenTofu >= 1.11 (or Terraform >= 1.0)
- Cloudflare account
- Cloudflare R2 bucket for remote state

## Cloudflare R2 Backend Setup

### Creating the R2 Bucket

1. Log in to the [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Navigate to **R2 Object Storage**
3. Click **Create bucket**
4. Name your bucket (e.g., `terraform-state`)
5. Enable **Object versioning** for state rollback capability

Or use the Wrangler CLI:

```bash
wrangler r2 bucket create terraform-state
```

### Generating R2 API Tokens

1. In the Cloudflare dashboard, navigate to **R2 Object Storage**
2. Click **Manage R2 API Tokens**
3. Click **Create API token**
4. Set permissions to **Read & Write** for your bucket
5. Save the **Access Key ID** and **Secret Access Key**

### Finding Your Account ID

Your Cloudflare account ID can be found:
- In the dashboard URL: `https://dash.cloudflare.com/<account-id>/`
- On the R2 overview page
- In the right sidebar of most Cloudflare dashboard pages

### Setting Environment Variables

Export your R2 credentials and account ID:

```bash
export AWS_ACCESS_KEY_ID="your-r2-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-r2-secret-access-key"
export CLOUDFLARE_ACCOUNT_ID="your-cloudflare-account-id"
```

Or add them to `~/.aws/credentials`:

```ini
[default]
aws_access_key_id = your-r2-access-key-id
aws_secret_access_key = your-r2-secret-access-key
```

And set the account ID separately:

```bash
export CLOUDFLARE_ACCOUNT_ID="your-cloudflare-account-id"
```

## Cloudflare API Token Setup

### Creating the Token

1. Log in to the [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Go to **My Profile** → **API Tokens**
3. Click **Create Token**
4. Select **Create Custom Token**

### Required Permissions

Your API token needs the following permissions:

- **Zone** → **Zone** → **Read**
- **Zone** → **Zone Settings** → **Edit**
- **Zone** → **DNS** → **Edit**
- **Zone** → **Page Rules** → **Edit**

### Token Scope

- **Zone Resources**: Include → Specific zone → Select your zones
- Or use **All zones** if managing multiple zones

### Using the Token

Set the token as an environment variable:

```bash
export TF_VAR_cloudflare_api_token="your-token-here"
```

## Repository Structure

```
.
├── terragrunt.hcl                # Root config (S3 backend + Cloudflare provider)
├── _terraform/
│   ├── zone/                     # Parent module that calls all sub-modules
│   ├── cloudflare-zone/          # Creates Cloudflare zones
│   ├── cloudflare-dns-records/   # Manages DNS records
│   ├── cloudflare-zone-settings/ # Configures zone settings (SSL, TLS, etc)
│   └── cloudflare-page-rules/    # Manages page rules
└── zones/
    ├── common.hcl                # Common DNS records and zone settings
    ├── example.com/              # Example zone with DNS records and settings
    │   └── terragrunt.hcl        # Zone-specific configuration
    └── example.net/              # Example zone with page rule redirect
        └── terragrunt.hcl
```

## Usage

### Adding a New Zone

1. Create a new directory under `zones/`:

```bash
mkdir -p zones/yourdomain.com
```

2. Create `terragrunt.hcl`:

```hcl
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../_terraform/zone"
}

locals {
  common = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  zone_specific_records = {
    root = {
      name    = "@"
      type    = "A"
      value   = "192.0.2.1"
      proxied = true
    }
  }
}

inputs = merge(
  local.common.locals.common_zone_settings,
  {
    zone_name   = "yourdomain.com"
    dns_records = merge(local.common.locals.common_dns_records, local.zone_specific_records)
    page_rules  = {}
  }
)
```

3. Initialize and apply:

```bash
cd zones/yourdomain.com
terragrunt init
terragrunt plan
terragrunt apply
```

### Managing All Zones

Run commands across all zones at once:

```bash
# Preview changes for all zones
terragrunt run-all plan

# Apply changes to all zones
terragrunt run-all apply
```

### Managing DNS Records

DNS records are defined as a map in your zone's `terragrunt.hcl`. Common records (like MX and SPF) are inherited from `zones/common.hcl`:

```hcl
zone_specific_records = {
  root = {
    name    = "@"
    type    = "A"
    value   = "192.0.2.1"
    proxied = true
  }
  www = {
    name    = "www"
    type    = "CNAME"
    value   = "example.com"
    proxied = true
  }
  mail_mx = {
    name     = "@"
    type     = "MX"
    value    = "mail.example.com"
    ttl      = 3600
    proxied  = false
    priority = 10
  }
  spf = {
    name    = "@"
    type    = "TXT"
    value   = "\"v=spf1 include:_spf.example.com ~all\""
    ttl     = 3600
    proxied = false
  }
}
```

The map keys (e.g., `root`, `www`, `mail_mx`) are identifiers - choose meaningful names.

### Configuring Zone Settings

Zone settings are inherited from `zones/common.hcl` by default. To override for a specific zone, add them to the `merge()`:

```hcl
inputs = merge(
  local.common.locals.common_zone_settings,
  {
    zone_name        = "yourdomain.com"
    ssl              = "full"  # Override: off, flexible, full, strict
    min_tls_version  = "1.3"   # Override: 1.0, 1.1, 1.2, 1.3
    always_use_https = false   # Override: true, false
    dns_records      = merge(...)
    page_rules       = {}
  }
)
```

Common settings are defined in `zones/common.hcl` and apply to all zones unless overridden.

### Adding Page Rules

```hcl
page_rules = {
  admin_bypass = {
    target   = "example.com/admin/*"
    priority = 1
    status   = "active"
    actions = {
      cache_level = "bypass"
    }
  }
}
```

## Module Details

### zone

Parent module that orchestrates all sub-modules.

**Inputs:**
- `zone_name` - DNS zone name
- `plan` - Plan type (default: "free")
- `ssl` - SSL mode (default: "flexible")
- `always_use_https` - Force HTTPS (default: true)
- `automatic_https_rewrites` - Auto HTTPS rewrites (default: true)
- `min_tls_version` - Minimum TLS version (default: "1.2")
- `dns_records` - Map of DNS records (default: {})
- `page_rules` - Map of page rules (default: {})

**Outputs:**
- `zone_id` - The zone ID
- `name_servers` - Cloudflare nameservers

### cloudflare-zone

Creates a Cloudflare zone.

**Inputs:**
- `zone_name` - DNS zone name
- `plan` - Plan type (default: "free")

**Outputs:**
- `zone_id` - The zone ID
- `name_servers` - Cloudflare nameservers

### cloudflare-dns-records

Manages DNS records for a zone.

**Inputs:**
- `zone_id` - The zone ID
- `records` - Map of DNS records

**Outputs:**
- `record_ids` - Map of record IDs

### cloudflare-zone-settings

Configures zone settings.

**Inputs:**
- `zone_id` - The zone ID
- `ssl` - SSL mode
- `always_use_https` - Force HTTPS
- `automatic_https_rewrites` - Auto HTTPS rewrites
- `min_tls_version` - Minimum TLS version

### cloudflare-page-rules

Manages page rules.

**Inputs:**
- `zone_id` - The zone ID
- `page_rules` - Map of page rules

## Best Practices

- Each zone has isolated state - changes to one zone don't affect others
- Keep sensitive values in environment variables (`TF_VAR_cloudflare_api_token`)
- Review `terragrunt plan` output before applying changes
- Use version control for all configuration files
- Tag your S3 state bucket with appropriate access controls
