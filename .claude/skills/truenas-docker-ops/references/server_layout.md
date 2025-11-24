# TrueNAS Server Layout

## SSH Access

Access the TrueNAS server using the pre-configured SSH alias:

```bash
ssh truenas
```

Authentication is already configured on the host machine.

## Directory Structure

### Docker Compose Files
All container compose files are located at:
```
/mnt/performance/home/admin/Develop/nixonomicon/nas/stacks/
```

This is the **source of truth** for container configurations, volume mappings, and network settings.

### Configuration Files
Container-specific configurations are stored at:
```
/mnt/performance/docker/
```

Typically organized as `/mnt/performance/docker/<container-name>/`.

### Data Storage
Large data files (downloads, media, etc.) are stored at:
```
/mnt/capacity/watch/
```

## Discovering Container Information

### List Running Containers
```bash
ssh truenas docker ps
```

### Find Container Configuration
To understand a container's volume mappings, networks, and settings:
```bash
ssh truenas cat /mnt/performance/home/admin/Develop/nixonomicon/nas/stacks/<container-name>/docker-compose.yml
```

### Common Container Pattern
Most containers follow this structure:
- **Config**: `/mnt/performance/docker/<container-name>/`
- **Data**: Varies by container, check compose file for volume mappings
- **Large files**: Often mapped to `/mnt/capacity/watch/<container-name>/`

## Working with Containers

### Execute Commands in Container
```bash
ssh truenas docker exec -i <container-name> <command>
```

### View Container Logs
```bash
ssh truenas docker logs <container-name>
```

### Inspect Container Details
```bash
ssh truenas docker inspect <container-name>
```

## Examples

### Check if anypod container is running
```bash
ssh truenas docker ps | grep anypod
```

### View anypod compose configuration
```bash
ssh truenas cat /mnt/performance/home/admin/Develop/nixonomicon/nas/stacks/anypod/docker-compose.yml
```

### Access anypod database
```bash
# Database is typically at /data/db/anypod.db inside the container
ssh truenas docker exec -i anypod sqlite3 /data/db/anypod.db "SELECT * FROM feed;"
```
