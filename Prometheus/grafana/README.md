![grafana-icon](grafana.jpg)
# Setting up Grafana Dashboard Using Volume Provisioning

This directory contains the configuration for automatically provisioning Grafana datasources and dashboards using Docker volume mounts.

## 📁 Directory Structure

```
grafana/
├── provisioning/
│   ├── datasources/
│   │   └── datasource.yml      # Prometheus datasource configuration
│   └── dashboards/
│       ├── dashboard.yml       # Dashboard provider configuration
│       └── node_exporter_full_dashboard.json  # Node Exporter dashboard
└── README.md                   # This file
```

## 🚀 How It Works

### Volume Provisioning
The Docker Compose setup uses two key volume mounts:

```yaml
volumes:
  - grafana-data:/var/lib/grafana                    # Persistent data storage
  - ./grafana/provisioning:/etc/grafana/provisioning # Auto-provisioning configs
```

### Automatic Configuration
When Grafana starts, it automatically:
1. **Configures Prometheus datasource** from `datasources/datasource.yml`
2. **Imports dashboards** from `dashboards/` directory
3. **Persists data** in the Docker volume

## ⚙️ Configuration Files

### Datasource Configuration (`datasources/datasource.yml`)
```yaml
apiVersion: 1

datasources:
  - name: prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
```

### Dashboard Provider (`dashboards/dashboard.yml`)
```yaml
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    options:
      path: /etc/grafana/provisioning/dashboards
```

## 📊 Adding New Dashboards

### Method 1: Place JSON files directly
1. Download or export a dashboard as JSON
2. Place the `.json` file in `provisioning/dashboards/`
3. Restart Grafana container: `docker-compose restart grafana`

### Method 2: Update dashboard provider
1. Create subdirectories in `provisioning/dashboards/`
2. Update `dashboard.yml` to include additional providers
3. Restart containers

Example for multiple dashboard sources:
```yaml
providers:
  - name: 'node-exporter'
    folder: 'Node Exporter'
    type: file
    options:
      path: /etc/grafana/provisioning/dashboards/node-exporter
  - name: 'application'
    folder: 'Applications'
    type: file
    options:
      path: /etc/grafana/provisioning/dashboards/apps
```

## 🔧 Adding New Datasources

Create additional `.yml` files in `datasources/` directory:

### Example: Adding InfluxDB
```yaml
# datasources/influxdb.yml
apiVersion: 1

datasources:
  - name: influxdb
    type: influxdb
    access: proxy
    url: http://influxdb:8086
    database: mydb
    user: admin
    password: admin123
```

### Example: Adding Loki for Logs
```yaml
# datasources/loki.yml
apiVersion: 1

datasources:
  - name: loki
    type: loki
    access: proxy
    url: http://loki:3100
```

## 🏗️ Benefits of Volume Provisioning

### ✅ Advantages
- **Automatic Setup**: No manual configuration needed
- **Version Control**: All configs stored in Git
- **Reproducible**: Identical setup across environments
- **Easy Maintenance**: Update configs without UI clicks
- **Backup-Friendly**: Configuration is code

### ⚡ Quick Start
1. Ensure your dashboard JSON files are in `provisioning/dashboards/`
2. Update datasource configs in `provisioning/datasources/`
3. Run: `docker-compose up -d`
4. Access Grafana: http://localhost:3000 (admin/admin)

## 🔄 Making Changes

### To Update Existing Dashboards:
1. Edit the `.json` file in `provisioning/dashboards/`
2. Restart Grafana: `docker-compose restart grafana`
3. Changes appear within 10 seconds (updateIntervalSeconds)

### To Add Environment-Specific Configs:
1. Use environment variables in `docker-compose.yml`
2. Template your YAML files with environment-specific values
3. Override datasource URLs per environment

## 🛠️ Troubleshooting

### Dashboard Not Loading
- Check file permissions on JSON files
- Verify JSON syntax is valid
- Check Grafana logs: `docker-compose logs grafana`

### Datasource Connection Issues
- Verify service names match Docker network
- Check port configurations
- Ensure services are accessible from Grafana container

### Permission Errors
- Ensure Docker has read access to provisioning directory
- Check that volume mounts are correct in docker-compose.yml

## 📝 Best Practices

1. **Keep JSON Clean**: Remove `id` fields from exported dashboards
2. **Use Variables**: Make dashboards flexible with template variables
3. **Document Changes**: Add comments to configuration files
4. **Test Locally**: Always test provisioning changes locally first
5. **Backup**: Keep original dashboard exports as backup

## 🚀 Next Steps

- Add more monitoring dashboards (Docker, Kubernetes, etc.)
- Configure alert rules and notification channels
- Set up different datasources for various metrics
- Implement dashboard folders for better organization
- Configure user authentication and permissions

---

**Note**: This setup uses the official Grafana Docker image with volume provisioning for maximum compatibility and ease of use. 
