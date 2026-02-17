variable "zone_name" {
  type = string
}

variable "plan" {
  type    = string
  default = "free"
}

variable "ssl" {
  type    = string
  default = "flexible"
}

variable "always_use_https" {
  type    = string
  default = "on"
}

variable "automatic_https_rewrites" {
  type    = string
  default = "on"
}

variable "min_tls_version" {
  type    = string
  default = "1.2"
}

variable "dns_records" {
  type    = list(any)
  default = []
}

variable "page_rules" {
  type    = list(any)
  default = []
}
