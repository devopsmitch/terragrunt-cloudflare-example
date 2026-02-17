resource "cloudflare_record" "this" {
  for_each = { for idx, record in var.records : idx => record }

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  value   = each.value.value
  ttl     = lookup(each.value, "ttl", 1)
  proxied = lookup(each.value, "proxied", false)
}
