# Grafana Logging Stack

Container log collection and alerting using Alloy, Loki, and AlertManager.

## Components

| Service | Purpose | Port | IP |
|---------|---------|------|-----|
| **Loki** | Log storage and querying | 3100 | 192.168.5.240 |
| **Alloy** | Log collection from Docker | 12345 | 192.168.5.241 |
| **AlertManager** | Alert notification routing | 9093 | 192.168.5.242 |

## Architecture

```
Docker Containers → Alloy (collector) → Loki (storage + rules) → AlertManager → Notifications
```

## Setup Instructions

### 1. Create directory structure on TrueNAS

```bash
mkdir -p /mnt/performance/docker/grafana/loki/{rules/fake,chunks,wal,compactor,rules-temp}
mkdir -p /mnt/performance/docker/grafana/alloy/data
mkdir -p /mnt/performance/docker/grafana/alertmanager/data

# Set ownership to 950:544
chown -R 950:544 /mnt/performance/docker/grafana
chmod -R 755 /mnt/performance/docker/grafana
```

### User Permissions Note

All containers run as **950:544**. Alloy uses `group_add: ["999"]` to gain docker socket access.

### 2. Deploy configuration files

```bash
# From this directory:
cp config/loki.yaml /mnt/performance/docker/grafana/loki/config.yaml
cp config/alloy.alloy /mnt/performance/docker/grafana/alloy/config.alloy
cp config/alertmanager.yaml /mnt/performance/docker/grafana/alertmanager/config.yaml
cp config/rules/container-alerts.yaml /mnt/performance/docker/grafana/loki/rules/fake/container-alerts.yaml
```

**Note:** The `fake` directory under rules is required for Loki in single-tenant mode.

### 3. Start the stack

```bash
docker compose up -d
```

### 4. Verify services

```bash
# Check all containers are healthy
docker compose ps

# Test Loki is ready
curl http://192.168.5.240:3100/ready

# Check Alloy UI
open http://192.168.5.241:12345

# Check AlertManager UI
open http://192.168.5.242:9093

# View loaded alert rules
curl http://192.168.5.240:3100/loki/api/v1/rules
```

## Configuration

### Adding Alert Notifications

Edit `/mnt/performance/docker/grafana/alertmanager/config.yaml` to configure:

- **Slack**: Add `slack_api_url` in global and configure `slack_configs`
- **Email**: Add `email_configs` with SMTP settings
- **Webhook**: Use `webhook_configs` for ntfy, Gotify, or custom endpoints

### Adding More Alert Rules

Add YAML files to `/mnt/performance/docker/grafana/loki/rules/fake/`.

Example rule structure:
```yaml
groups:
  - name: my_alerts
    interval: 1m
    rules:
      - alert: MyAlert
        expr: |
          count_over_time({job="docker", container="myapp"} |= "error" [5m]) > 10
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Error in {{ $labels.container }}"
```

### Useful LogQL Queries

```logql
# All logs from a specific container
{container="anypod"}

# Errors from all containers
{job="docker"} |~ "(?i)error"

# JSON parsed logs with level filter
{job="docker"} | json | level="error"

# Rate of errors per container
sum by (container) (rate({job="docker"} |~ "(?i)error" [5m]))
```

## Troubleshooting

### Alloy not collecting logs

1. Check Docker socket is accessible:
   ```bash
   docker exec alloy ls -la /var/run/docker.sock
   ```

2. View Alloy's internal state:
   ```
   http://192.168.5.241:12345/graph
   ```

### Rules not loading

1. Check rule syntax:
   ```bash
   curl http://192.168.5.240:3100/loki/api/v1/rules
   ```

2. Ensure rules are in `/loki/rules/fake/` (the `fake` tenant directory)

### AlertManager not receiving alerts

1. Check Loki ruler status:
   ```bash
   curl http://192.168.5.240:3100/ruler/ring
   ```

2. Check AlertManager is reachable from Loki:
   ```bash
   docker exec loki wget -qO- http://alertmanager:9093/-/healthy
   ```

## Optional: Add Grafana UI

If you later want to visualize logs, add this service to compose.yaml:

```yaml
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    user: "950:544"
    networks:
      external:
        ipv4_address: 192.168.5.243
    ports:
      - "3000:3000"
    volumes:
      - /mnt/performance/docker/grafana/grafana/data:/var/lib/grafana
      - /etc/localtime:/etc/localtime:ro
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: admin
```

Then add Loki as a data source at `http://loki:3100`.
