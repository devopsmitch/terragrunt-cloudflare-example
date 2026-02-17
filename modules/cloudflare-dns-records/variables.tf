variable "zone_id" {
  description = "The zone ID"
  type        = string
}

variable "records" {
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
