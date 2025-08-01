#!/bin/bash

# Enable collectd network plugin in the running container

docker exec graphite-collectd bash -c '
cat > /etc/collectd/collectd.conf.d/network.conf << EOF
LoadPlugin network
<Plugin network>
  Listen "0.0.0.0" "25826"
</Plugin>
EOF
'

# Restart collectd
docker exec graphite-collectd sv restart collectd

# Check status
echo "Checking collectd status..."
sleep 2
docker exec graphite-collectd sv status collectd

# Check if port is listening
echo "Checking if port 25826 is listening..."
docker exec graphite-collectd netstat -lunp | grep 25826 || echo "Port 25826 not listening yet"