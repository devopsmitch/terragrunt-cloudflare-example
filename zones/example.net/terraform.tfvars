zone_name = "example.net"

dns_records = [
  {
    name    = "@"
    type    = "A"
    value   = "192.0.2.1"
    proxied = true
  }
]

page_rules = [
  {
    target   = "*example.net/*"
    priority = 1
    status   = "active"
    actions = {
      forwarding_url = {
        url         = "https://example.com/$2"
        status_code = 301
      }
    }
  }
]
