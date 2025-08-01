FROM graphiteapp/graphite-statsd:latest

# Install collectd network plugin (Alpine-based)
RUN apk add --no-cache collectd-network

# Create the collectd.conf.d directory
RUN mkdir -p /etc/collectd/collectd.conf.d

# Add network plugin configuration
RUN echo 'LoadPlugin network' > /etc/collectd/collectd.conf.d/network.conf && \
    echo '<Plugin network>' >> /etc/collectd/collectd.conf.d/network.conf && \
    echo '  Listen "0.0.0.0" "25826"' >> /etc/collectd/collectd.conf.d/network.conf && \
    echo '</Plugin>' >> /etc/collectd/collectd.conf.d/network.conf

EXPOSE 25826/udp

CMD ["/entrypoint"]