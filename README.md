# Radiology Triage AI System

A Flask-based web application that uses AI to prioritize imaging studies based on similar historical cases.

## Features

- **Study Management**: View and filter imaging studies from the database
- **AI-Powered Triage**: Uses DeepSeek API to analyze and prioritize studies
- **Similar Case Matching**: Finds historically similar cases using TF-IDF similarity
- **Bootstrap UI**: Clean, responsive interface for radiology operations teams
- **Real-time Updates**: Live status updates and visual indicators

## Prerequisites

1. PostgreSQL database with the schema from `schema.sql`
2. DeepSeek API key
3. Python 3.11+ (if running locally)
4. Docker & Docker Compose (for containerized deployment)

## Setup

### 1. Environment Configuration

Copy the environment template:
```bash
cp .env.example .env
```

Edit `.env` with your configuration:
```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=postgres

# DeepSeek API
DEEPSEEK_API_KEY=your_api_key_here
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Database Setup

Ensure PostgreSQL is running and create the schema:
```bash
psql -h localhost -U postgres -d postgres -f schema.sql
```

### 4. Run the Application

**Locally:**
```bash
python app.py
```

**With Docker Compose (includes database):**
```bash
docker-compose -f docker-compose-full.yml up -d
```

## Usage

1. **Access the Application**: Open http://localhost:5000
2. **View Studies**: Browse all imaging studies with filtering options
3. **Study Details**: Click on any study to view detailed information
4. **AI Triage**: Click "AI Triage Analysis" to get prioritization recommendations
5. **Similar Cases**: View historically similar cases with similarity scores

## API Endpoints

- `GET /` - List all studies
- `GET /study/<study_id>` - Study detail page
- `POST /triage/<study_id>` - Perform AI triage analysis

## Triage Levels

- **HIGH**: Urgent review required (e.g., acute findings, critical conditions)
- **MEDIUM**: Standard priority (e.g., routine studies, non-acute findings)
- **LOW**: Lower priority (e.g., screening studies, stable conditions)

## Docker Services

The `docker-compose-full.yml` includes:

1. **PostgreSQL**: Database server with pre-loaded schema
2. **Flask App**: Web application on port 5000
3. **N8N**: Workflow automation on port 5678

## N8N Integration

The N8N service runs with host networking to allow connectivity to other services on your network. Access N8N at http://localhost:5678.

## Development

To run in development mode with hot reload:
```bash
flask run --host=0.0.0.0 --debug
```

## Troubleshooting

1. **Database Connection**: Ensure PostgreSQL is running and credentials are correct
2. **API Errors**: Check your DeepSeek API key in the `.env` file
3. **Similar Cases**: Ensure you have studies with findings summaries in the database
4. **Docker Issues**: Check that all ports are available and not in use

## Security Notes

- The application disables secure cookies for local development
- In production, ensure proper HTTPS/TLS configuration
- Database credentials should be securely managed in production
- API keys should be stored securely (not in version control)