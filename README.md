# Terragrunt Cloudflare Multi-Zone Management

Manage multiple Cloudflare zones using Terragrunt with reusable Terraform modules and isolated state per zone.

## Prerequisites

- Terragrunt >= 0.50
- OpenTofu >= 1.11 (or Terraform >= 1.0)
- Cloudflare account
- AWS S3 bucket for remote state

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

inputs = {
  zone_name = "yourdomain.com"

  ssl                      = "flexible"
  always_use_https         = "on"
  automatic_https_rewrites = "on"
  min_tls_version          = "1.2"

  dns_records = [
    {
      name    = "@"
      type    = "A"
      value   = "192.0.2.1"
      proxied = true
    }
  ]

  page_rules = []
}
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

Edit the `dns_records` list in your zone's `terragrunt.hcl`:

```hcl
dns_records = [
  {
    name    = "@"
    type    = "A"
    value   = "192.0.2.1"
    proxied = true
  },
  {
    name    = "www"
    type    = "CNAME"
    value   = "example.com"
    proxied = true
  },
  {
    name     = "@"
    type     = "MX"
    value    = "mail.example.com"
    ttl      = 3600
    proxied  = false
    priority = 10
  },
  {
    name    = "@"
    type    = "TXT"
    value   = "v=spf1 include:_spf.example.com ~all"
    ttl     = 3600
    proxied = false
  }
]
```

### Configuring Zone Settings

Modify settings in your zone's `terragrunt.hcl`:

```hcl
ssl                      = "flexible"  # off, flexible, full, strict
always_use_https         = "on"        # on, off
automatic_https_rewrites = "on"        # on, off
min_tls_version          = "1.2"       # 1.0, 1.1, 1.2, 1.3
```

### Adding Page Rules

```hcl
page_rules = [
  {
    target   = "example.com/admin/*"
    priority = 1
    status   = "active"
    actions = {
      cache_level = "bypass"
    }
  }
]
```

## Module Details

### zone

Parent module that orchestrates all sub-modules.

**Inputs:**
- `zone_name` - DNS zone name
- `plan` - Plan type (default: "free")
- `ssl` - SSL mode (default: "flexible")
- `always_use_https` - Force HTTPS (default: "on")
- `automatic_https_rewrites` - Auto HTTPS rewrites (default: "on")
- `min_tls_version` - Minimum TLS version (default: "1.2")
- `dns_records` - List of DNS records (default: [])
- `page_rules` - List of page rules (default: [])

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
- `records` - List of DNS records

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
- `page_rules` - List of page rules

## Best Practices

- Each zone has isolated state - changes to one zone don't affect others
- Keep sensitive values in environment variables (`TF_VAR_cloudflare_api_token`)
- Review `terragrunt plan` output before applying changes
- Use version control for all configuration files
- Tag your S3 state bucket with appropriate access controls
