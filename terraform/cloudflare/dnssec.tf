resource "cloudflare_zone_dnssec" "default" {
  zone_id = var.zone_id
}
