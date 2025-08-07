# Scriptodon Docker Deployment Guide

This guide explains how to deploy the Scriptodon Test Automation Platform using Docker on AWS instances.

## 📋 Prerequisites

- **Docker** (version 20.10 or higher)
- **Docker Compose** (version 2.0 or higher)
- **AWS EC2 Instance** (Ubuntu 20.04+ recommended)
- **Domain Name** (for production deployment)

## 🏗️ Architecture

The application consists of three main containers:

1. **Backend Container** - FastAPI application (Python 3.11)
2. **Frontend Container** - React application (Node.js 18)
3. **Nginx Container** - Reverse proxy and SSL termination

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/Scriptodon-AI-Agent.git
cd Scriptodon-AI-Agent
```

### 2. Set Environment Variables

Create a `.env` file in the root directory:

```bash
# API Keys
OPENROUTER_API_KEY=your_openrouter_api_key_here
OPENROUTER_SITE_URL=https://your-domain.com
OPENROUTER_SITE_NAME=Scriptodon Test Automation Platform

# Jira Configuration (optional)
JIRA_SERVER_URL=your_jira_server_url
JIRA_USERNAME=your_jira_username
JIRA_API_TOKEN=your_jira_api_token

# Application URL
API_URL=https://your-domain.com
```

### 3. Deploy the Application

#### Development Deployment
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh dev
```

#### Production Deployment
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh prod
```

## 🔧 Configuration

### Docker Compose Files

- **`docker-compose.yml`** - Development configuration
- **`docker-compose.prod.yml`** - Production configuration with SSL

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `OPENROUTER_API_KEY` | OpenRouter API key for AI features | Yes |
| `OPENROUTER_SITE_URL` | Your application URL | Yes |
| `OPENROUTER_SITE_NAME` | Application name | No |
| `JIRA_SERVER_URL` | Jira server URL | No |
| `JIRA_USERNAME` | Jira username | No |
| `JIRA_API_TOKEN` | Jira API token | No |
| `API_URL` | Backend API URL | Yes |

## 🐳 Docker Commands

### Build Images
```bash
# Build all services
docker-compose -f docker-compose.prod.yml build

# Build specific service
docker-compose -f docker-compose.prod.yml build backend
```

### Start Services
```bash
# Start all services
docker-compose -f docker-compose.prod.yml up -d

# Start specific service
docker-compose -f docker-compose.prod.yml up -d backend
```

### Stop Services
```bash
# Stop all services
docker-compose -f docker-compose.prod.yml down

# Stop and remove volumes
docker-compose -f docker-compose.prod.yml down -v
```

### View Logs
```bash
# View all logs
docker-compose -f docker-compose.prod.yml logs -f

# View specific service logs
docker-compose -f docker-compose.prod.yml logs -f backend
```

### Health Checks
```bash
# Check backend health
curl http://localhost:8000/health

# Check frontend health
curl http://localhost/health
```

## 🔒 SSL Configuration

### Development (Self-signed Certificate)
The deployment script automatically generates a self-signed certificate for development.

### Production (Let's Encrypt)
For production, you need to obtain SSL certificates:

1. **Install Certbot**
```bash
sudo apt update
sudo apt install certbot
```

2. **Obtain Certificate**
```bash
sudo certbot certonly --standalone -d your-domain.com
```

3. **Copy Certificates**
```bash
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem nginx/ssl/key.pem
```

4. **Set Permissions**
```bash
sudo chown -R $USER:$USER nginx/ssl/
chmod 600 nginx/ssl/*
```

## 📊 Monitoring

### Container Status
```bash
docker-compose -f docker-compose.prod.yml ps
```

### Resource Usage
```bash
docker stats
```

### Log Monitoring
```bash
# Real-time logs
docker-compose -f docker-compose.prod.yml logs -f

# Log analysis
docker-compose -f docker-compose.prod.yml logs backend | grep ERROR
```

## 🔄 Updates

### Update Application
```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
./scripts/deploy.sh prod
```

### Update Dependencies
```bash
# Rebuild with no cache
docker-compose -f docker-compose.prod.yml build --no-cache

# Restart services
docker-compose -f docker-compose.prod.yml up -d
```

## 🛠️ Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# Check what's using the port
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Kill the process
sudo kill -9 <PID>
```

#### 2. Permission Issues
```bash
# Fix SSL certificate permissions
sudo chown -R $USER:$USER nginx/ssl/
chmod 600 nginx/ssl/*
```

#### 3. Container Won't Start
```bash
# Check container logs
docker-compose -f docker-compose.prod.yml logs backend

# Check container status
docker-compose -f docker-compose.prod.yml ps
```

#### 4. Database Issues
```bash
# Access database container
docker-compose -f docker-compose.prod.yml exec backend python

# Check database file
docker-compose -f docker-compose.prod.yml exec backend ls -la scritodon.db
```

### Debug Commands

```bash
# Enter container shell
docker-compose -f docker-compose.prod.yml exec backend bash

# Check container resources
docker stats

# View container details
docker inspect scritodon-backend-prod
```

## 📁 File Structure

```
Scriptodon-AI-Agent/
├── Dockerfile                    # Backend container
├── docker-compose.yml           # Development setup
├── docker-compose.prod.yml      # Production setup
├── .dockerignore                # Docker ignore file
├── scripts/
│   └── deploy.sh               # Deployment script
├── nginx/
│   └── nginx.conf              # Nginx configuration
├── frontend/
│   ├── Dockerfile              # Frontend container
│   └── nginx.conf              # Frontend nginx config
└── backend/
    ├── requirements.txt         # Python dependencies
    ├── main.py                 # FastAPI application
    ├── scripts/                # Generated scripts
    ├── reports/                # Test reports
    └── uploads/                # Uploaded files
```

## 🔐 Security Considerations

1. **Environment Variables** - Never commit `.env` files
2. **SSL Certificates** - Use valid certificates in production
3. **Firewall** - Configure AWS security groups properly
4. **Updates** - Keep Docker and system packages updated
5. **Backups** - Regularly backup the database and scripts

## 📞 Support

For issues and questions:

1. Check the troubleshooting section
2. Review container logs
3. Check the main README.md file
4. Open an issue on GitHub

## 🚀 AWS Deployment Checklist

- [ ] Launch EC2 instance (Ubuntu 20.04+)
- [ ] Install Docker and Docker Compose
- [ ] Configure security groups (ports 80, 443, 8000)
- [ ] Set up domain name and DNS
- [ ] Obtain SSL certificates
- [ ] Clone repository
- [ ] Configure environment variables
- [ ] Run deployment script
- [ ] Test application functionality
- [ ] Set up monitoring and backups 