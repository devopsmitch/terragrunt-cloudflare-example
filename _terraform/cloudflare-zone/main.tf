resource "cloudflare_zone" "this" {
  zone = var.zone_name
  plan = var.plan
}
