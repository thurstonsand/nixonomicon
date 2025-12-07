resource "cloudflare_bot_management" "default" {
  zone_id            = var.zone_id
  ai_bots_protection = "block"
  enable_js          = true
  fight_mode         = true
}
