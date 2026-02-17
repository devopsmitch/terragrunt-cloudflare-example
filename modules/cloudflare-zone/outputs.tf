output "zone_id" {
  description = "The zone ID"
  value       = cloudflare_zone.this.id
}

output "name_servers" {
  description = "Cloudflare name servers for the zone"
  value       = cloudflare_zone.this.name_servers
}
