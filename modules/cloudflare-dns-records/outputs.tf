output "record_ids" {
  description = "Map of DNS record IDs"
  value       = { for k, v in cloudflare_record.this : k => v.id }
}
