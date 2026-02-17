output "page_rule_ids" {
  description = "Map of page rule IDs"
  value       = { for k, v in cloudflare_page_rule.this : k => v.id }
}
