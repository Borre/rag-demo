# Radiology Triage AI System

A Flask-based web application that uses AI to prioritize imaging studies based on similar historical cases, deployed on Huawei Cloud ECS.

## 🏥 Overview

The Radiology Triage AI System helps radiology operations teams prioritize imaging studies using:
- AI-powered triage recommendations via DeepSeek API
- Historical case similarity matching
- Operational workflow optimization
- Real-time study management dashboard

## ✨ Features

- **Study Management**: View and filter imaging studies from PostgreSQL database
- **AI-Powered Triage**: Uses DeepSeek API to analyze and prioritize studies
- **Similar Case Matching**: TF-IDF based similarity search to find relevant historical cases
- **Bootstrap UI**: Clean, responsive interface optimized for radiology operations
- **Real-time Updates**: Live status updates and visual priority indicators
- **Docker Deployment**: Containerized application for easy deployment
- **Huawei Cloud Ready**: Terraform scripts for ECS deployment

## 🚀 Quick Start on Huawei Cloud

### Prerequisites

1. **Huawei Cloud Account** with ECS and VPC services enabled
2. **Terraform** (>= 1.0) installed locally
3. **Huawei Cloud CLI** configured with credentials
4. **PostgreSQL database** (can be on RDS or self-hosted)
5. **DeepSeek API Key**

### 1. Clone the Repository

```bash
git clone <repository-url>
cd radiology-triage-ai
```

### 2. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit with your configuration
nano .env
```

Required configuration:
```env
# Database Configuration
DB_HOST=your_postgres_host
DB_PORT=5432
DB_NAME=radiology_db
DB_USER=postgres
DB_PASSWORD=your_password

# DeepSeek API Configuration
DEEPSEEK_API_KEY=sk-your-deepseek-api-key
DEEPSEEK_BASE_URL=https://api.deepseek.com

# Huawei Cloud (optional, for deployment)
HUAWEI_ACCESS_KEY=your_access_key
HUAWEI_SECRET_KEY=your_secret_key
HUAWEI_REGION=cn-north-4
```

### 3. Deploy with Terraform

```bash
# Initialize Terraform
cd terraform
terraform init

# Review the execution plan
terraform plan

# Deploy to Huawei Cloud
terraform apply

# Note the ECS public IP from the output
```

### 4. Access the Application

Once deployed, access the application at:
```
http://<ECS-PUBLIC-IP>:5000
```

## 📋 Database Setup

Your PostgreSQL database needs the following tables:

```sql
-- Create tables for the Radiology Triage System
CREATE TABLE IF NOT EXISTS study_triage_ai (
    id BIGSERIAL PRIMARY KEY,
    study_id VARCHAR(64),
    triage_level VARCHAR(16),
    triage_score DECIMAL(5,2),
    ai_explanation VARCHAR(2000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS imaging_studies (
    study_id           VARCHAR(64)   PRIMARY KEY,
    patient_id         VARCHAR(64),
    modality           VARCHAR(16),      -- CT, MRI, XR, US, etc.
    body_part          VARCHAR(64),      -- Chest, Abdomen, Brain, etc.
    indication         VARCHAR(256),     -- Clinical indication
    report_text        VARCHAR(4000),    -- Full radiology report
    findings_summary   VARCHAR(1000),    -- Summary for AI analysis
    exam_datetime      TIMESTAMP,
    site               VARCHAR(64),      -- Hospital/Clinic
    sla_seconds        INT,              -- Service level agreement
    current_status     VARCHAR(32),      -- NEW, REPORTED, IN_REVIEW
    priority_flag      VARCHAR(16)       -- HIGH, MEDIUM, LOW
);

-- Performance indexes
CREATE INDEX IF NOT EXISTS idx_studies_status ON imaging_studies(current_status);
CREATE INDEX IF NOT EXISTS idx_studies_modality ON imaging_studies(modality);
CREATE INDEX IF NOT EXISTS idx_studies_datetime ON imaging_studies(exam_datetime);
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Browser   │◄──►│  Huawei ECS     │◄──►│  PostgreSQL DB  │
│                 │    │  (Flask App)    │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │  DeepSeek API   │
                       │  (AI Triage)    │
                       └─────────────────┘
```

## 📊 Usage Guide

### 1. Viewing Studies
- Browse all imaging studies on the main dashboard
- Filter by modality, status, or priority level
- Search by study ID, patient ID, or clinical indications

### 2. Study Details
- Click any study to view comprehensive information
- See clinical indications, findings, and full reports
- View previous AI triage results (if any)

### 3. AI Triage Analysis
- Click "AI Triage Analysis" on any study detail page
- System finds similar historical cases using text similarity
- DeepSeek API provides triage recommendation (HIGH/MEDIUM/LOW)
- Results include priority score and operational justification

### 4. Understanding Triage Levels
- **HIGH**: Urgent review required (acute findings, critical conditions)
- **MEDIUM**: Standard priority (routine studies, non-acute findings)
- **LOW**: Lower priority (screening studies, stable conditions)

## 🔧 Development

### Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export DB_HOST=localhost
export DEEPSEEK_API_KEY=your_key

# Run the application
python app.py
```

Access at http://localhost:5000

### Docker Development

```bash
# Build and run locally
docker-compose up --build

# Run with production configuration
docker-compose -f docker-compose-full.yml up --build
```

## 🐳 Docker Configuration

The application includes three Docker configurations:

1. **`docker-compose.yml`**: Basic Flask app only
2. **`docker-compose-full.yml`**: Flask app + N8N for workflow automation
3. **`Dockerfile`**: Multi-stage build for production deployment

## 🔒 Security Considerations

### Production Deployment
- Enable HTTPS/TLS with proper certificates
- Use environment variables for all sensitive configuration
- Implement proper database connection security
- Configure firewall rules on Huawei Cloud
- Regular security updates and vulnerability scanning

### Network Security
- Only expose necessary ports (5000 for Flask, 5678 for N8N)
- Use Huawei Cloud security groups for access control
- Implement rate limiting for API endpoints
- Monitor and log all access attempts

## 📈 Monitoring and Logging

### Application Metrics
- Response time and error rates
- Database connection health
- API usage statistics
- Triage processing times

### Logs
- Application logs available via Docker logs
- Gunicorn access and error logs
- Database query logs (configurable)

```bash
# View application logs
docker logs -f radiology_triage_app

# View N8N logs (if using)
docker logs -f n8n
```

## 🔧 Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Verify database credentials in `.env`
   - Check network connectivity from ECS to database
   - Ensure database allows connections from ECS IP

2. **DeepSeek API Errors**
   - Verify API key is correct and active
   - Check API quota and rate limits
   - Confirm network access to DeepSeek endpoints

3. **CSS/Static Files Not Loading**
   - Check security headers configuration
   - Verify CDN access from Huawei Cloud
   - Check Flask static file configuration

4. **Permission Issues**
   - Ensure Docker has proper file permissions
   - Check volume mount configurations
   - Verify user permissions in container

### Getting Help

```bash
# Check container status
docker-compose ps

# View detailed logs
docker logs radiology_triage_app --tail 100

# Test database connectivity
docker exec -it radiology_triage_app python -c "import psycopg2; print('DB OK')"
```

## 📝 API Documentation

### Endpoints

- `GET /` - Studies dashboard
- `GET /study/<study_id>` - Study detail page
- `POST /triage/<study_id>` - AI triage analysis

### Response Format

Triage API Response:
```json
{
  "triage_level": "HIGH|MEDIUM|LOW",
  "triage_score": 0.0-1.0,
  "explanation": "Operational justification text"
}
```

## 🚀 Scaling Considerations

### Horizontal Scaling
- Use Huawei Cloud ECS Auto Scaling
- Implement load balancer for multiple instances
- Use shared session storage (Redis)
- Database read replicas for read-heavy workloads

### Performance Optimization
- Implement caching for similar case searches
- Use CDN for static assets
- Optimize database queries with proper indexing
- Consider async processing for AI triage

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For issues and questions:
- Create an issue in the repository
- Contact the development team
- Check the troubleshooting section above

---

**Note**: This system is designed to assist radiology operations teams with prioritization, not to replace medical judgment. Always follow proper clinical protocols and regulatory requirements.