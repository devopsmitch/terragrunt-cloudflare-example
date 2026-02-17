variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "zone_name" {
  description = "The DNS zone name"
  type        = string
}

variable "plan" {
  description = "Cloudflare plan type"
  type        = string
  default     = "free"
}

variable "ssl" {
  description = "SSL setting"
  type        = string
  default     = "flexible"
}

variable "always_use_https" {
  description = "Always use HTTPS"
  type        = string
  default     = "on"
}

variable "automatic_https_rewrites" {
  description = "Automatic HTTPS rewrites"
  type        = string
  default     = "on"
}

variable "min_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "1.2"
}

variable "dns_records" {
  description = "DNS records to create"
  type = list(object({
    name    = string
    type    = string
    value   = string
    ttl     = optional(number, 1)
    proxied = optional(bool, false)
  }))
  default = []
}

variable "page_rules" {
  description = "Page rules to create"
  type = list(object({
    target   = string
    priority = optional(number, 1)
    status   = optional(string, "active")
    actions  = map(any)
  }))
  default = []
}
