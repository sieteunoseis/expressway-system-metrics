# Graphite with Collectd Network Plugin

This container runs Graphite with StatsD and includes collectd configured to receive metrics via the network plugin on UDP port 25826.

## Quick Start

```bash
# Start the container
docker-compose up -d

# Enable collectd network plugin (only needed once after container creation)
./enable-collectd-network.sh

# Check status
docker-compose ps
docker exec graphite-collectd sv status collectd
```

## Docker Compose Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild after Dockerfile changes
docker-compose build && docker-compose up -d

# Restart services
docker-compose restart
```

## Ports

- **8081**: Graphite Web UI
- **2003**: Carbon line receiver (TCP)
- **8125**: StatsD (UDP)
- **8126**: StatsD admin (TCP)
- **25826**: Collectd network plugin (UDP)

## Accessing the Web UI

Open http://localhost:8081 in your browser to access the Graphite web interface.

## Sending Metrics

### Via Collectd Network Plugin

Configure your collectd clients to send metrics to this server on port 25826:

```
LoadPlugin network
<Plugin network>
  <Server "your-graphite-host" "25826">
  </Server>
</Plugin>
```

### Via StatsD

Send StatsD metrics to UDP port 8125:

```bash
echo "test.metric:1|c" | nc -u -w0 localhost 8125
```

### Via Carbon

Send metrics directly to Carbon on TCP port 2003:

```bash
echo "test.metric 42 $(date +%s)" | nc localhost 2003
```

## Troubleshooting

### Check if collectd is running

```bash
docker exec graphite-collectd sv status collectd
```

### View collectd logs

```bash
docker exec graphite-collectd tail -f /var/log/supervisor/collectd.log
```

### Verify network plugin is listening

```bash
docker exec graphite-collectd netstat -lunp | grep 25826
```

### Check for metrics in Graphite

```bash
curl "http://localhost:8081/metrics/find?query=collectd.*&format=json"
```

## Data Persistence

The following directories are persisted:
- `./data/graphite/storage` - Whisper database files
- `./data/graphite/conf` - Graphite configuration
- `./data/statsd` - StatsD configuration

## Docker Run Alternative

If you prefer using docker run instead of docker-compose:

```bash
docker run -d \
  --name graphite-collectd \
  -p 8081:80 \
  -p 2003:2003 \
  -p 8125:8125/udp \
  -p 8126:8126 \
  -p 25826:25826/udp \
  -e STATSD_INTERFACE=udp \
  -e GRAPHITE_TIME_ZONE=America/Los_Angeles \
  -e COLLECTD=1 \
  -v $(pwd)/data/graphite/storage:/opt/graphite/storage \
  -v $(pwd)/data/graphite/conf:/opt/graphite/conf \
  -v $(pwd)/data/statsd:/opt/statsd/config \
  --network nginx_default \
  --restart always \
  graphite_graphite
```