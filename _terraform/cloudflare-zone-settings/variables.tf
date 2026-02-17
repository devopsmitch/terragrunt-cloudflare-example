variable "zone_id" {
  description = "The zone ID"
  type        = string
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
