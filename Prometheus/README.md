# Prometheus & Node Exporter Monitoring Setup

This directory contains a simple yet powerful monitoring setup using Prometheus and Node Exporter in Docker containers. This setup allows you to monitor both Prometheus itself and system-level metrics from the host machine.

## 📋 Overview

The setup includes:
- **Prometheus**: Time-series database and monitoring system
- **Node Exporter**: Exports hardware and OS metrics for Unix systems
- **Docker Compose**: Orchestrates both services with proper networking

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Prometheus    │◄──►│  Node Exporter  │
│   Port: 9090    │    │   Port: 9100    │
└─────────────────┘    └─────────────────┘
        │                        │
        └────────┬─────────────────┘
                 │
        prometheus-network
```

## 🚀 Getting Started

### Prerequisites
- Docker
- Docker Compose

### Starting the Services

1. Navigate to the Prometheus directory:
   ```bash
   cd Prometheus
   ```

2. Start the services:
   ```bash
   docker-compose up -d
   ```

3. Verify the services are running:
   ```bash
   docker-compose ps
   ```

### Accessing the Services

- **Prometheus Web UI**: http://localhost:9090
- **Node Exporter Metrics**: http://localhost:9100/metrics

## 🔍 Prometheus Self-Monitoring Queries

Prometheus scrapes its own metrics. Here are useful queries for monitoring Prometheus itself:

### Basic Prometheus Metrics

1. **Prometheus Build Information**:
   ```promql
   prometheus_build_info
   ```

2. **Prometheus Server Status (Up/Down)**:
   ```promql
   up{job="prometheus"}
   ```

3. **Number of Time Series in Prometheus**:
   ```promql
   prometheus_tsdb_symbol_table_size_bytes
   ```

4. **Prometheus Configuration Reload Success**:
   ```promql
   prometheus_config_last_reload_successful
   ```

### Performance Metrics

1. **Prometheus Memory Usage**:
   ```promql
   process_resident_memory_bytes{job="prometheus"}
   ```

2. **Number of Samples Ingested per Second**:
   ```promql
   rate(prometheus_tsdb_samples_appended_total[5m])
   ```

3. **Query Duration (95th percentile)**:
   ```promql
   histogram_quantile(0.95, rate(prometheus_http_request_duration_seconds_bucket[5m]))
   ```

4. **Storage Size**:
   ```promql
   prometheus_tsdb_size_bytes
   ```

## 🖥️ Node-Level Metrics Queries

Node Exporter provides comprehensive system metrics. Here are essential queries:

### System Overview

1. **Node Uptime**:
   ```promql
   node_time_seconds - node_boot_time_seconds
   ```

2. **System Load Average (1 minute)**:
   ```promql
   node_load1
   ```

3. **Number of CPU Cores**:
   ```promql
   count without(cpu, mode) (node_cpu_seconds_total{mode="idle"})
   ```

### CPU Metrics

1. **CPU Usage Percentage (overall)**:
   ```promql
   100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
   ```

2. **CPU Usage by Mode**:
   ```promql
   rate(node_cpu_seconds_total[5m])
   ```

3. **Per-CPU Core Usage**:
   ```promql
   100 - (rate(node_cpu_seconds_total{mode="idle"}[5m]) * 100)
   ```

### Memory Metrics

1. **Memory Usage Percentage**:
   ```promql
   100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))
   ```

2. **Available Memory (GB)**:
   ```promql
   node_memory_MemAvailable_bytes / 1024 / 1024 / 1024
   ```

3. **Memory Usage by Type**:
   ```promql
   node_memory_MemTotal_bytes - node_memory_MemFree_bytes - node_memory_Buffers_bytes - node_memory_Cached_bytes
   ```

### Disk Metrics

1. **Disk Usage Percentage by Filesystem**:
   ```promql
   100 * (1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes))
   ```

2. **Disk I/O Operations per Second**:
   ```promql
   rate(node_disk_io_time_seconds_total[5m])
   ```

3. **Disk Read/Write Bytes per Second**:
   ```promql
   rate(node_disk_read_bytes_total[5m])
   rate(node_disk_written_bytes_total[5m])
   ```

### Network Metrics

1. **Network Traffic (bytes/sec)**:
   ```promql
   rate(node_network_receive_bytes_total[5m])
   rate(node_network_transmit_bytes_total[5m])
   ```

2. **Network Packets per Second**:
   ```promql
   rate(node_network_receive_packets_total[5m])
   rate(node_network_transmit_packets_total[5m])
   ```

3. **Network Errors**:
   ```promql
   rate(node_network_receive_errs_total[5m])
   rate(node_network_transmit_errs_total[5m])
   ```

## 📊 Useful Dashboard Queries

### Combined System Health
```promql
# Overall system health score (0-1, where 1 is healthy)
(
  min(up{job="node"}) *
  min(up{job="prometheus"}) *
  (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes > 0.1) *
  (100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) < 90)
)
```

### Alert Examples
```promql
# High CPU Usage Alert (>90% for 5 minutes)
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90

# Low Memory Alert (<10% available)
(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) < 0.1

# High Disk Usage Alert (>85% used)
100 * (1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) > 85
```

## 🛠️ Troubleshooting

### Common Issues

1. **Services not starting**:
   ```bash
   docker-compose logs prometheus
   docker-compose logs node-exporter
   ```

2. **Prometheus can't scrape Node Exporter**:
   - Check if both services are on the same network
   - Verify the targets in `configurations/prometheus.yml`

3. **No metrics showing up**:
   - Ensure services are running: `docker-compose ps`
   - Check Prometheus targets: http://localhost:9090/targets

### Service Management

```bash
# Stop services
docker-compose down

# Restart services
docker-compose restart

# View logs
docker-compose logs -f prometheus
docker-compose logs -f node-exporter

# Update services
docker-compose pull
docker-compose up -d
```

## 📂 Configuration Files

- `docker-compose.yml`: Service definitions and networking
- `configurations/prometheus.yml`: Prometheus scraping configuration

## 🔗 Useful Links

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Node Exporter Documentation](https://github.com/prometheus/node_exporter)
- [PromQL Query Language](https://prometheus.io/docs/prometheus/latest/querying/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)

## 📈 Next Steps

Consider extending this setup with:
- **Grafana**: For better visualization dashboards
- **Alertmanager**: For alerting and notifications
- **Additional Exporters**: Database, application-specific metrics
- **Service Discovery**: For dynamic target discovery

---

**Happy Monitoring!** 🚀 