variable "zone_id" {
  description = "Cloudflare Zone ID for thurstons.house"
  type        = string
  sensitive   = true
}

variable "api_token" {
  description = "Cloudflare API token with Zone/DNS edit permissions"
  type        = string
  sensitive   = true
}
