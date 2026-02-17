resource "cloudflare_page_rule" "this" {
  for_each = { for idx, rule in var.page_rules : idx => rule }

  zone_id  = var.zone_id
  target   = each.value.target
  priority = lookup(each.value, "priority", 1)
  status   = lookup(each.value, "status", "active")

  actions {
    dynamic "forwarding_url" {
      for_each = lookup(each.value.actions, "forwarding_url", null) != null ? [each.value.actions.forwarding_url] : []
      content {
        url         = forwarding_url.value.url
        status_code = forwarding_url.value.status_code
      }
    }

    dynamic "cache_level" {
      for_each = lookup(each.value.actions, "cache_level", null) != null ? [1] : []
      content {
        value = each.value.actions.cache_level
      }
    }
  }
}
