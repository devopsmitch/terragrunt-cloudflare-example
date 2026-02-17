resource "cloudflare_page_rule" "this" {
  for_each = { for idx, rule in var.page_rules : idx => rule }

  zone_id  = var.zone_id
  target   = each.value.target
  priority = lookup(each.value, "priority", 1)
  status   = lookup(each.value, "status", "active")

  actions {
    dynamic "cache_level" {
      for_each = lookup(each.value.actions, "cache_level", null) != null ? [1] : []
      content {
        value = each.value.actions.cache_level
      }
    }
  }
}
