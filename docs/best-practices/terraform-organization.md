# Terraform best practices (single-deployment Cloudflare homelab)

This is an opinionated guide for keeping a single Terraform deployment clean, low-ceremony, and easy to change over time—without introducing multi-environment dev/prod structure.

## 1) Core organizing principle: one root module, split into human-friendly files

Terraform operates on a _directory_, not a “main file”: it will evaluate all `.tf` files in the working directory “as if they were in a single document.” ([Cloudflare Docs][1])
So your file structure is for humans: optimize for “where do I change X?” and “what breaks if I rename Y?”

### Recommended top-level layout

Keep it flat and boring:

```text
infra/
  README.md
  versions.tf
  providers.tf
  backend.tf            # optional but recommended
  variables.tf
  locals.tf
  data.tf               # optional lookups
  dns.tf
  tunnel.tf
  access.tf
  outputs.tf
  templates/
    cloudflared.yml.tftpl
    worker.js.tftpl
  homelab.auto.tfvars   # non-secret config (committable)
  secrets.auto.tfvars   # secrets (encrypted in-repo via your mechanism)
  .gitignore
```

Why this works well for a homelab:

- You avoid “environment” folders and workspaces entirely.
- You still get clear separation by concern (DNS vs Tunnel vs Access).
- A single state file keeps cross-references trivial.

## 2) File roles (what goes where)

Use consistent conventions so future-you doesn’t hunt.

- **`versions.tf`**: `terraform { required_version … required_providers … }` with pinned major version(s). Cloudflare docs show materially different provider major versions in the wild (for example `~> 4.0` in one guide and `>= 5.8.2` in another), so pinning avoids surprise renames and diffs. ([Cloudflare Docs][2])
- **`providers.tf`**: provider config (auth via variables/env).
- **`backend.tf`**: backend config only (remote state, locking, etc.).
- **`variables.tf`**: inputs and types (the interface).
- **`locals.tf`**: naming conventions, derived strings, and “configuration as data” transforms (the implementation glue). Locals are intended for naming/reusing expressions without repeating them. ([HashiCorp Developer][3])
- **`dns.tf` / `tunnel.tf` / `access.tf`**: resources grouped by subsystem.
- **`templates/`**: `.tftpl` templates used by `templatefile()`. ([HashiCorp Developer][4])
- **`outputs.tf`**: non-secret outputs that you actually use (URLs, IDs), with `sensitive = true` where appropriate.

## 3) Put “homelab inventory” in one place (kill copy/paste)

The most maintainable pattern for a single deployment is: **define your apps once as data**, then drive DNS, tunnel ingress, and Access from that map.

### Example: a single `apps` map as your source of truth

In `variables.tf`:

```hcl
variable "zone_name" { type = string }
variable "zone_id"   { type = string }
variable "account_id" { type = string }

variable "apps" {
  description = "Homelab services exposed via Cloudflare."
  type = map(object({
    hostname = string                 # "grafana" -> grafana.<zone_name>
    service  = string                 # "http://10.0.0.10:3000"

    access = optional(object({
      enabled        = bool
      allowed_emails = set(string)
    }), { enabled = false, allowed_emails = [] })
  }))
}
```

In `locals.tf`:

```hcl
locals {
  fqdns = { for name, app in var.apps : name => "${app.hostname}.${var.zone_name}" }
  access_apps = { for name, app in var.apps : name => app if app.access.enabled }
}
```

Benefits:

- One edit updates everything.
- Standardized naming becomes automatic.
- Adding an app is a data entry task, not a resource-copy task.

### Use `.auto.tfvars` for config files

Terraform auto-loads variable definition files ending in `.auto.tfvars`/`.auto.tfvars.json`, plus `terraform.tfvars` and `terraform.tfvars.json`. ([HashiCorp Developer][5])
For a single homelab, this is ideal:

- `homelab.auto.tfvars`: non-secret inventory (hostnames, internal URLs, etc.)
- `secrets.auto.tfvars`: secrets (encrypted in-repo via your approach)

## 4) Variables vs locals (what to parameterize)

A clean rule set:

- **Use input variables** for values that are truly “inputs” (zone/account IDs, base domain, your app inventory).
- **Use locals** for anything _derivable_ (FQDNs, ingress rule lists, shared labels/comments).
- Avoid “stringly-typed duplication”: if the same string appears 3+ times, it probably belongs in a local or computed from structure.

## 5) Loops: where they pay off most

Terraform’s `for_each` is specifically meant to manage “several similar objects…without writing a separate block for each object.” ([HashiCorp Developer][6])

### Prefer `for_each` over copy/paste (and usually over `count`)

Guidance from Terraform docs:

- Use `count` for nearly identical instances.
- Use `for_each` when instances need distinct values not easily derived from an integer index. ([HashiCorp Developer][7])

Homelab apps almost always vary (hostname/service/access), so `for_each` is the default.

### Example: DNS records from the app map

Cloudflare’s newer examples show DNS records using `content`, `type`, `ttl`, and `proxied`. ([Cloudflare Docs][1])

```hcl
resource "cloudflare_dns_record" "app" {
  for_each = var.apps

  zone_id  = var.zone_id
  name     = each.value.hostname
  type     = "CNAME"
  proxied  = true
  content  = "${cloudflare_zero_trust_tunnel_cloudflared.homelab.id}.cfargotunnel.com"
}
```

### Tunnel ingress rules: always add the catch-all rule

Cloudflare’s Tunnel example explicitly requires a catch-all ingress rule at the bottom. ([Cloudflare Docs][2])

In `locals.tf`:

```hcl
locals {
  ingress_rules = concat(
    [for name, app in var.apps : {
      hostname = local.fqdns[name]
      service  = app.service
    }],
    [{ service = "http_status:404" }]
  )
}
```

Then render ingress rules using either:

- a provider schema that accepts a list/object config, or
- **dynamic blocks** when the resource requires nested `ingress_rule {}` blocks.

### Dynamic blocks (for nested blocks that must repeat)

Dynamic blocks exist to “automatically construct multi-level, nested block structures.” ([HashiCorp Developer][8])
Cloudflare’s v4-style example uses nested `ingress_rule` blocks in `cloudflare_tunnel_config`. ([Cloudflare Docs][2])

```hcl
resource "cloudflare_tunnel_config" "this" {
  tunnel_id  = var.tunnel_id
  account_id = var.account_id

  config {
    dynamic "ingress_rule" {
      for_each = local.ingress_rules
      content {
        hostname = try(ingress_rule.value.hostname, null)
        service  = ingress_rule.value.service
      }
    }
  }
}
```

Key cleanliness tip: keep the “rules as data” (`local.ingress_rules`) separate from the “provider schema ceremony” (the `dynamic` block).

## 6) Templates: when and how to use them effectively

### Prefer `jsonencode`/`yamlencode` over hand-rolled JSON/YAML

Terraform explicitly recommends: don’t use heredoc strings to generate JSON/YAML; use `jsonencode` or `yamlencode` so Terraform guarantees valid syntax. ([HashiCorp Developer][9])

### Use `templatefile()` for longer scripts/configs

`templatefile(path, vars)` reads a file and renders it using provided variables. ([HashiCorp Developer][4])
Cloudflare’s own guide uses `templatefile` to render a startup script and pass in `tunnel_token`. ([Cloudflare Docs][1])

Pattern:

- Put templates in `templates/`
- Pass a single map of values
- Keep templates dumb; do logic in HCL (locals), not inside the template

```hcl
locals {
  cloudflared_config = templatefile("${path.module}/templates/cloudflared.yml.tftpl", {
    tunnel_id = var.tunnel_id
    rules     = local.ingress_rules
  })
}
```

## 7) Provider version churn: treat as a first-class maintenance concern

Cloudflare examples show materially different resource sets between major provider versions (for example, `cloudflare_tunnel_config`/`cloudflare_access_application` in one doc vs `cloudflare_zero_trust_*`/`cloudflare_dns_record` in another). ([Cloudflare Docs][2])
Best practice for a homelab: **pick a major version and pin it**.

When you _do_ refactor (rename resources, split blocks, etc.), use `moved` blocks to change resource addresses without destroy/recreate. ([HashiCorp Developer][10])

## 8) Keep state and drift boring

- Avoid dashboard-driven changes once Terraform is authoritative. Cloudflare explicitly notes dashboard changes can break Terraform state, and suggests making the dashboard read-only to prevent drift. ([Cloudflare Docs][2])
- Treat state as sensitive even if you encrypt secrets in-repo; state can still contain values you don’t want leaked.

## 9) Minimal “clean workflow” checklist

- `terraform fmt` enforced (pre-commit or CI).
- `terraform validate` in CI.
- Commit `.terraform.lock.hcl`.
- Keep “inventory” small and centralized (`apps` map), and keep “plumbing” (dynamic blocks/templates) isolated to a few files.

---

If you want, I can also include a concrete “starter repo” skeleton (all the `.tf` files with placeholders) aligned to either Cloudflare provider v4-style resources (`cloudflare_tunnel_config`, `cloudflare_access_*`) or v5-style resources (`cloudflare_zero_trust_*`, `cloudflare_dns_record`) so you can paste it in and fill values.

[1]: https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/deployment-guides/terraform/ "Deploy Tunnels with Terraform · Cloudflare One docs"
[2]: https://developers.cloudflare.com/learning-paths/clientless-access/terraform/publish-apps-with-terraform/ "Publish applications with Terraform · Cloudflare Learning Paths"
[3]: https://developer.hashicorp.com/terraform/language/block/locals?utm_source=chatgpt.com "Locals block reference - Terraform"
[4]: https://developer.hashicorp.com/terraform/language/functions/templatefile?utm_source=chatgpt.com "templatefile - Functions - Configuration Language | Terraform"
[5]: https://developer.hashicorp.com/terraform/language/values/variables?utm_source=chatgpt.com "Use input variables to add module arguments | Terraform"
[6]: https://developer.hashicorp.com/terraform/language/meta-arguments/for_each?utm_source=chatgpt.com "for_each meta-argument reference | Terraform"
[7]: https://developer.hashicorp.com/terraform/language/meta-arguments/count?utm_source=chatgpt.com "count meta-argument reference | Terraform"
[8]: https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks?utm_source=chatgpt.com "Dynamic Blocks - Configuration Language | Terraform"
[9]: https://developer.hashicorp.com/terraform/language/expressions/strings?utm_source=chatgpt.com "Strings and Templates - Configuration Language | Terraform"
[10]: https://developer.hashicorp.com/terraform/language/block/moved?utm_source=chatgpt.com "moved block reference - Terraform"
