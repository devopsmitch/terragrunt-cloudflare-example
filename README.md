# Terraform Cloudflare Multi-Zone Management

Manage multiple Cloudflare zones using reusable Terraform modules with isolated state per zone.

## Prerequisites

- OpenTofu >= 1.11
- Cloudflare account
- AWS S3 bucket for remote state (or modify `backend.tf` for your backend)

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

Or create a `terraform.tfvars` file (add to `.gitignore`):

```hcl
cloudflare_api_token = "your-token-here"
```

## Repository Structure

```
.
├── modules/
│   ├── cloudflare-zone/          # Creates Cloudflare zones
│   ├── cloudflare-dns-records/   # Manages DNS records
│   ├── cloudflare-zone-settings/ # Configures zone settings (SSL, TLS, etc)
│   └── cloudflare-page-rules/    # Manages page rules
└── zones/
    ├── example.com/               # Example zone with DNS records and settings
    │   ├── main.tf                # Module calls
    │   ├── variables.tf           # Input variables
    │   ├── backend.tf             # State backend config
    │   ├── versions.tf            # Provider requirements
    │   └── terraform.tfvars       # Zone-specific values
    └── example.net/               # Example zone with page rule redirect
        ├── main.tf
        ├── variables.tf
        ├── backend.tf
        ├── versions.tf
        └── terraform.tfvars
```

## Usage

### Adding a New Zone

1. Create a new directory under `zones/`:

```bash
mkdir -p zones/yourdomain.com
```

2. Copy the example zone files:

```bash
cp zones/example.com/*.tf zones/yourdomain.com/
cp zones/example.com/terraform.tfvars zones/yourdomain.com/
```

3. Update `backend.tf` with a unique state key:

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "cloudflare/yourdomain.com/terraform.tfstate"
    region = "us-east-1"
  }
}
```

4. Edit `terraform.tfvars` with your zone configuration:

```hcl
zone_name = "yourdomain.com"

dns_records = [
  {
    name    = "@"
    type    = "A"
    value   = "192.0.2.1"
    proxied = true
  }
]
```

5. Initialize and apply:

```bash
cd zones/yourdomain.com
terraform init
terraform plan
terraform apply
```

### Managing DNS Records

Edit the `dns_records` list in `terraform.tfvars`:

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

Modify variables in `terraform.tfvars`:

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
- Keep sensitive values in environment variables or use a secrets manager
- Review `terraform plan` output before applying changes
- Use version control for all configuration files (except `terraform.tfvars` with secrets)
- Tag your S3 state bucket with appropriate access controls
