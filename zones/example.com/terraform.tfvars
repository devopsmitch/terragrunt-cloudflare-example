zone_name = "example.com"

ssl                      = "flexible"
always_use_https         = "on"
automatic_https_rewrites = "on"
min_tls_version          = "1.2"

dns_records = [
  {
    name    = "@"
    type    = "A"
    value   = "192.0.2.1"
    proxied = true
  },
  {
    name    = "www"
    type    = "CNAME"
    value   = "example.com"
    proxied = true
  },
  {
    name     = "@"
    type     = "MX"
    value    = "mail.example.com"
    ttl      = 3600
    proxied  = false
    priority = 10
  },
  {
    name    = "@"
    type    = "TXT"
    value   = "v=spf1 include:_spf.example.com ~all"
    ttl     = 3600
    proxied = false
  }
]

page_rules = []
