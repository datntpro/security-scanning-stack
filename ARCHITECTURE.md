# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Security Scanning Stack                      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                           INPUT LAYER                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │ Source Code  │  │ Docker Images│  │  IaC Files   │              │
│  │  (./source)  │  │              │  │ (Terraform)  │              │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘              │
│         │                  │                  │                       │
└─────────┼──────────────────┼──────────────────┼───────────────────────┘
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        SCANNING LAYER                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    SAST Scanners                             │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │   │
│  │  │SonarQube │  │ Semgrep  │  │  Bandit  │                  │   │
│  │  │:9000     │  │          │  │          │                  │   │
│  │  └──────────┘  └──────────┘  └──────────┘                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                  Secret Detection                            │   │
│  │  ┌──────────┐  ┌──────────┐                                 │   │
│  │  │ Gitleaks │  │TruffleHog│                                 │   │
│  │  └──────────┘  └──────────┘                                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                Container Security                            │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │   │
│  │  │  Trivy   │  │  Grype   │  │  Dockle  │                  │   │
│  │  └──────────┘  └──────────┘  └──────────┘                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                   IaC Security                               │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │   │
│  │  │ Checkov  │  │  TFSec   │  │   KICS   │                  │   │
│  │  └──────────┘  └──────────┘  └──────────┘                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                        SCA                                   │   │
│  │  ┌──────────────────┐  ┌──────────┐                         │   │
│  │  │ Dependency-Check │  │  Safety  │                         │   │
│  │  └──────────────────┘  └──────────┘                         │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                       DAST                                   │   │
│  │  ┌──────────┐  ┌──────────┐                                 │   │
│  │  │OWASP ZAP │  │  Nuclei  │                                 │   │
│  │  │:8080     │  │          │                                 │   │
│  │  └──────────┘  └──────────┘                                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
└───────────────────────────┬───────────────────────────────────────────┘
                            │
                            ▼ (JSON/XML Reports)
┌─────────────────────────────────────────────────────────────────────┐
│                        STORAGE LAYER                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    Reports Directory                         │   │
│  │                      (./reports/)                            │   │
│  │                                                              │   │
│  │  • gitleaks-report.json                                     │   │
│  │  • semgrep-report.json                                      │   │
│  │  • trivy-fs-report.json                                     │   │
│  │  • checkov-results.json                                     │   │
│  │  • dependency-check-report.json                             │   │
│  │  • ... và nhiều hơn                                         │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
└───────────────────────────┬───────────────────────────────────────────┘
                            │
                            ▼ (Import via API)
┌─────────────────────────────────────────────────────────────────────┐
│                   VULNERABILITY MANAGEMENT LAYER                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                      DefectDojo                              │   │
│  │                      (:8000)                                 │   │
│  │                                                              │   │
│  │  ┌────────────────────────────────────────────────────┐    │   │
│  │  │            DefectDojo Django App                   │    │   │
│  │  │  • Web UI                                          │    │   │
│  │  │  • REST API                                        │    │   │
│  │  │  • Import Engine (100+ formats)                   │    │   │
│  │  │  • Deduplication Engine                           │    │   │
│  │  │  • Risk Scoring                                   │    │   │
│  │  └────────────────────────────────────────────────────┘    │   │
│  │                                                              │   │
│  │  ┌────────────────────────────────────────────────────┐    │   │
│  │  │         Celery Workers (Background Tasks)          │    │   │
│  │  │  • Async import processing                         │    │   │
│  │  │  • Report generation                               │    │   │
│  │  │  • Notifications                                   │    │   │
│  │  └────────────────────────────────────────────────────┘    │   │
│  │                                                              │   │
│  │  ┌────────────────────────────────────────────────────┐    │   │
│  │  │              Celery Beat (Scheduler)               │    │   │
│  │  │  • Scheduled scans                                 │    │   │
│  │  │  • Periodic reports                                │    │   │
│  │  │  • SLA monitoring                                  │    │   │
│  │  └────────────────────────────────────────────────────┘    │   │
│  │                                                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
└───────────────────────────┬───────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        DATA LAYER                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────────┐         ┌──────────────────────┐         │
│  │   PostgreSQL         │         │       Redis          │         │
│  │   (:5432)            │         │       (:6379)        │         │
│  │                      │         │                      │         │
│  │  • Products          │         │  • Celery Queue      │         │
│  │  • Engagements       │         │  • Cache             │         │
│  │  • Findings          │         │  • Session Store     │         │
│  │  • Users             │         │                      │         │
│  │  • Metrics           │         │                      │         │
│  └──────────────────────┘         └──────────────────────┘         │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                        OUTPUT LAYER                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │   Web UI     │  │  REST API    │  │   Reports    │              │
│  │ (Dashboard)  │  │  (CI/CD)     │  │  (PDF/CSV)   │              │
│  └──────────────┘  └──────────────┘  └──────────────┘              │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Scan Phase
```
Source Code → Scanners → JSON Reports → ./reports/
```

### 2. Import Phase
```
./reports/*.json → DefectDojo API → Processing → Database
```

### 3. Management Phase
```
Database → DefectDojo UI → User Actions → Updated Database
```

### 4. Reporting Phase
```
Database → Report Generator → PDF/CSV/JSON → Export
```

## Component Details

### Scanning Layer

#### SAST (Static Application Security Testing)
- **Purpose**: Analyze source code for security vulnerabilities
- **Input**: Source code files
- **Output**: JSON reports with findings
- **Tools**: SonarQube, Semgrep, Bandit

#### Secret Detection
- **Purpose**: Find hardcoded secrets, API keys, passwords
- **Input**: Source code, git history
- **Output**: JSON reports with secret locations
- **Tools**: Gitleaks, TruffleHog

#### Container Security
- **Purpose**: Scan container images for vulnerabilities
- **Input**: Docker images, Dockerfiles
- **Output**: JSON reports with CVEs
- **Tools**: Trivy, Grype, Dockle

#### IaC Security
- **Purpose**: Scan infrastructure code for misconfigurations
- **Input**: Terraform, CloudFormation, K8s YAML
- **Output**: JSON reports with issues
- **Tools**: Checkov, TFSec, KICS

#### SCA (Software Composition Analysis)
- **Purpose**: Find vulnerabilities in dependencies
- **Input**: package.json, requirements.txt, pom.xml
- **Output**: JSON reports with vulnerable packages
- **Tools**: OWASP Dependency-Check, Safety

#### DAST (Dynamic Application Security Testing)
- **Purpose**: Test running applications for vulnerabilities
- **Input**: Running web application URL
- **Output**: JSON/XML reports with findings
- **Tools**: OWASP ZAP, Nuclei

### Vulnerability Management Layer

#### DefectDojo Components

**Django Application**
- Web interface for users
- REST API for automation
- Import engine supporting 100+ formats
- Deduplication logic
- Risk scoring algorithms

**Celery Workers**
- Async processing of imports
- Background report generation
- Email/Slack notifications
- Webhook triggers

**Celery Beat**
- Scheduled scan triggers
- Periodic report generation
- SLA monitoring and alerts
- Metrics calculation

### Data Layer

#### PostgreSQL
- Stores all application data
- Products, Engagements, Findings
- User accounts and permissions
- Metrics and historical data

#### Redis
- Celery message broker
- Session storage
- Caching layer
- Real-time data

## Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Docker Network: security-scan                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  All containers communicate via this bridge network          │
│  Internal DNS resolution by container name                   │
│                                                               │
└─────────────────────────────────────────────────────────────┘

Exposed Ports:
- 8000: DefectDojo Web UI
- 8080: OWASP ZAP Proxy
- 8090: OWASP ZAP API
- 9000: SonarQube Web UI
```

## Volume Architecture

```
Persistent Volumes:
├── sonarqube_data          # SonarQube analysis data
├── sonarqube_extensions    # SonarQube plugins
├── sonarqube_logs          # SonarQube logs
├── nuclei_templates        # Nuclei scan templates
├── trivy_cache             # Trivy vulnerability database
├── dependency_check_data   # OWASP DC vulnerability database
├── defectdojo_media        # DefectDojo uploaded files
├── postgres_data           # PostgreSQL database
└── redis_data              # Redis persistence

Bind Mounts:
├── ./source:/src           # Source code to scan (read-only)
└── ./reports:/reports      # Scan results (read-write)
```

## Security Considerations

### Network Isolation
- All services in isolated Docker network
- Only necessary ports exposed to host
- No direct internet access from scanners

### Data Protection
- PostgreSQL with strong password
- DefectDojo secret keys configured
- Redis protected by network isolation

### Access Control
- DefectDojo with user authentication
- API tokens for automation
- Role-based access control (RBAC)

### Secrets Management
- Environment variables for sensitive data
- No hardcoded credentials
- Rotate passwords regularly

## Scalability

### Horizontal Scaling
```yaml
# Scale Celery workers
docker compose up -d --scale defectdojo-celery-worker=3
```

### Resource Limits
```yaml
services:
  defectdojo:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
```

### Performance Optimization
- Redis caching for frequent queries
- PostgreSQL connection pooling
- Celery for async processing
- Nginx reverse proxy (optional)

## High Availability

### Database Backup
```bash
# Automated backup
docker exec defectdojo-postgres pg_dump -U defectdojo defectdojo > backup.sql
```

### Service Health Checks
- PostgreSQL: `pg_isready`
- Redis: `redis-cli ping`
- DefectDojo: HTTP health endpoint

### Restart Policies
```yaml
services:
  defectdojo:
    restart: unless-stopped
```

## Monitoring

### Logs
```bash
# View all logs
docker compose logs -f

# Specific service
docker compose logs -f defectdojo
```

### Metrics
- DefectDojo built-in metrics dashboard
- PostgreSQL query performance
- Celery task monitoring

### Alerts
- DefectDojo SLA alerts
- Email notifications
- Slack webhooks
- Custom webhooks

## Integration Points

### CI/CD Integration
```yaml
# GitLab CI
security_scan:
  script:
    - make scan
    - make import
```

### JIRA Integration
- Auto-create tickets for findings
- Sync status updates
- Link findings to issues

### Slack Integration
- New finding notifications
- SLA breach alerts
- Report summaries

### Webhook Integration
- Custom integrations
- Third-party tools
- Automation workflows

## Deployment Options

### Local Development
```bash
docker compose up -d
```

### Production Deployment
- Use external PostgreSQL (RDS, CloudSQL)
- Use external Redis (ElastiCache, MemoryStore)
- Add Nginx reverse proxy
- Enable SSL/TLS
- Configure backups
- Set up monitoring

### Cloud Deployment
- AWS ECS/Fargate
- Google Cloud Run
- Azure Container Instances
- Kubernetes (Helm charts available)

## Maintenance

### Updates
```bash
# Pull latest images
docker compose pull

# Restart with new images
docker compose up -d
```

### Database Migrations
```bash
# Run migrations
docker exec defectdojo python manage.py migrate
```

### Cleanup
```bash
# Remove old data
make clean-all

# Prune Docker
docker system prune -a
```

## Troubleshooting

### Common Issues

**Services won't start**
- Check logs: `docker compose logs`
- Check resources: `docker stats`
- Check ports: `netstat -tulpn`

**Import fails**
- Check file format
- Check scan type mapping
- Check Celery worker logs

**Slow performance**
- Increase resources
- Scale Celery workers
- Optimize PostgreSQL

**Database issues**
- Check PostgreSQL logs
- Verify connection string
- Check disk space

## References

- [DefectDojo Architecture](https://documentation.defectdojo.com/about/architecture/)
- [Docker Compose Best Practices](https://docs.docker.com/compose/production/)
- [PostgreSQL Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [Celery Best Practices](https://docs.celeryproject.org/en/stable/userguide/optimizing.html)
