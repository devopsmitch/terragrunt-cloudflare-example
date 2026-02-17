variable "zone_id" {
  description = "The zone ID"
  type        = string
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
