resource "cloudflare_zero_trust_access_application" "truenas_app" {
  account_id                = local.account_id
  name                      = "TrueNAS App"
  domain                    = "cli-proxy-api.${local.zone_name}"
  type                      = "self_hosted"
  session_duration          = "730h"
  auto_redirect_to_identity = true
  allowed_idps              = [cloudflare_zero_trust_access_identity_provider.google.id]
  # TODO: migrate to `destinations` block when upgrading to provider v5
  # Sticking with v4.x for now as Cloudflare recommends waiting until March 2025 for v5 to stabilize
  self_hosted_domains = [
    "cli-proxy-api.${local.zone_name}",
    "anypod.${local.zone_name}/admin/*"
  ]
  policies = [cloudflare_zero_trust_access_policy.admin_access.id]
}

resource "cloudflare_zero_trust_access_policy" "admin_access" {
  account_id       = local.account_id
  name             = "Admin Access"
  decision         = "allow"
  session_duration = "24h"

  include {
    service_token = [cloudflare_zero_trust_access_service_token.onepassword.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_zero_trust_access_application" "warp_login" {
  account_id           = local.account_id
  name                 = "Warp Login App"
  domain               = "${local.team_name}.cloudflareaccess.com/warp"
  type                 = "warp"
  session_duration     = "24h"
  app_launcher_visible = false
  policies             = [cloudflare_zero_trust_access_policy.admin_access.id]
}
