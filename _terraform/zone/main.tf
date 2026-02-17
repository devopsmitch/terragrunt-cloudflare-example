module "zone" {
  source = "../cloudflare-zone"

  zone_name = var.zone_name
  plan      = var.plan
}

module "zone_settings" {
  source = "../cloudflare-zone-settings"

  zone_id                  = module.zone.zone_id
  ssl                      = var.ssl
  always_use_https         = var.always_use_https
  automatic_https_rewrites = var.automatic_https_rewrites
  min_tls_version          = var.min_tls_version
}

module "dns_records" {
  source = "../cloudflare-dns-records"

  zone_id = module.zone.zone_id
  records = var.dns_records
}

module "page_rules" {
  source = "../cloudflare-page-rules"

  zone_id    = module.zone.zone_id
  page_rules = var.page_rules
}
