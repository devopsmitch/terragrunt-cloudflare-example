variable "zone_name" {
  description = "The DNS zone name"
  type        = string
}

variable "plan" {
  description = "Cloudflare plan type"
  type        = string
  default     = "free"
}
