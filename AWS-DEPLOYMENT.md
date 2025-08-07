# Scriptodon AWS EC2 Deployment Guide

This guide will help you deploy the Scriptodon Test Automation Platform on your AWS EC2 instance at `13.232.134.97`.

## 🚀 Quick Start

### Prerequisites
- AWS EC2 instance running Ubuntu 20.04 or later
- SSH access to your EC2 instance
- Ports 80 and 8000 open in your security group

### Step 1: Connect to Your EC2 Instance
```bash
ssh -i your-key.pem ubuntu@13.232.134.97
```

### Step 2: Upload Application Files
Upload all project files to your EC2 instance:
```bash
# From your local machine
scp -r -i your-key.pem . ubuntu@13.232.134.97:/opt/scritodon/
```

### Step 3: Run the Deployment Script
```bash
# On your EC2 instance
cd /opt/scritodon
chmod +x deploy-aws.sh
./deploy-aws.sh
```

## 📋 Manual Deployment Steps

If you prefer to deploy manually, follow these steps:

### 1. Update System Packages
```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 2. Install Docker and Docker Compose
```bash
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker
```

### 3. Set Up Application Directory
```bash
sudo mkdir -p /opt/scritodon
sudo chown $USER:$USER /opt/scritodon
cd /opt/scritodon
```

### 4. Create Environment File
```bash
cat > .env << EOF
# OpenRouter API Configuration
OPENROUTER_API_KEY=your_openrouter_api_key_here
OPENROUTER_SITE_URL=http://13.232.134.97:8000
OPENROUTER_SITE_NAME=Scriptodon Test Automation Platform

# Jira Configuration (optional)
JIRA_SERVER_URL=your_jira_server_url_here
JIRA_USERNAME=your_jira_username_here
JIRA_API_TOKEN=your_jira_api_token_here

# API URL for frontend
API_URL=http://13.232.134.97:8000
EOF
```

### 5. Deploy Application
```bash
docker compose -f docker-compose.prod.yml up --build -d
```

## 🔧 Configuration

### Environment Variables
Update the `.env` file with your actual API keys:

```bash
# Required: Get your OpenRouter API key from https://openrouter.ai/
OPENROUTER_API_KEY=your_actual_openrouter_api_key_here

# Optional: Jira integration
JIRA_SERVER_URL=https://your-domain.atlassian.net
JIRA_USERNAME=your-jira-email@domain.com
JIRA_API_TOKEN=your-jira-api-token
```

### Security Group Configuration
Ensure your AWS security group allows:
- Port 80 (HTTP) - for frontend access
- Port 8000 (Backend API) - for API access
- Port 22 (SSH) - for server access

## 🌐 Application URLs

After deployment, your application will be available at:

- **Frontend**: http://13.232.134.97
- **Backend API**: http://13.232.134.97:8000
- **Health Check**: http://13.232.134.97:8000/health
- **API Documentation**: http://13.232.134.97:8000/docs

## 📊 Monitoring and Management

### View Application Logs
```bash
# View all logs
docker compose -f /opt/scritodon/docker-compose.prod.yml logs -f

# View specific service logs
docker compose -f /opt/scritodon/docker-compose.prod.yml logs -f backend
docker compose -f /opt/scritodon/docker-compose.prod.yml logs -f frontend
```

### Check Service Status
```bash
docker compose -f /opt/scritodon/docker-compose.prod.yml ps
```

### Restart Services
```bash
# Restart all services
docker compose -f /opt/scritodon/docker-compose.prod.yml restart

# Restart specific service
docker compose -f /opt/scritodon/docker-compose.prod.yml restart backend
```

### Update Application
```bash
cd /opt/scritodon
git pull  # if using git
docker compose -f docker-compose.prod.yml up --build -d
```

## 🔒 Security Considerations

### 1. Firewall Configuration
```bash
# Allow only necessary ports
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 8000/tcp # Backend API
sudo ufw enable
```

### 2. SSL/HTTPS Setup (Recommended)
For production use, consider setting up SSL certificates:

```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Get SSL certificate (if you have a domain)
sudo certbot --nginx -d your-domain.com
```

### 3. Regular Updates
```bash
# Update system packages
sudo apt-get update && sudo apt-get upgrade -y

# Update Docker images
docker compose -f /opt/scritodon/docker-compose.prod.yml pull
docker compose -f /opt/scritodon/docker-compose.prod.yml up -d
```

## 🐛 Troubleshooting

### Common Issues

1. **Port 80 not accessible**
   - Check AWS security group settings
   - Verify firewall configuration: `sudo ufw status`

2. **Docker permission denied**
   - Add user to docker group: `sudo usermod -aG docker $USER`
   - Log out and log back in

3. **Application not starting**
   - Check logs: `docker compose -f /opt/scritodon/docker-compose.prod.yml logs`
   - Verify environment variables in `.env` file

4. **Memory issues**
   - Check available memory: `free -h`
   - Consider upgrading to a larger instance type

### Health Checks
```bash
# Test backend
curl http://13.232.134.97:8000/health

# Test frontend
curl http://13.232.134.97

# Check container status
docker ps
```

## 📈 Performance Optimization

### For t3.micro instances:
1. **Memory Management**
   ```bash
   # Monitor memory usage
   htop
   docker stats
   ```

2. **Swap Space** (if needed)
   ```bash
   sudo fallocate -l 1G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

3. **Docker Cleanup**
   ```bash
   # Remove unused containers and images
   docker system prune -a
   ```

## 🔄 Backup and Recovery

### Backup Database
```bash
# Create backup directory
mkdir -p /opt/scritodon/backups

# Backup SQLite database
cp /opt/scritodon/backend/scritodon.db /opt/scritodon/backups/scritodon_$(date +%Y%m%d_%H%M%S).db
```

### Restore from Backup
```bash
# Stop services
docker compose -f /opt/scritodon/docker-compose.prod.yml down

# Restore database
cp /opt/scritodon/backups/scritodon_YYYYMMDD_HHMMSS.db /opt/scritodon/backend/scritodon.db

# Restart services
docker compose -f /opt/scritodon/docker-compose.prod.yml up -d
```

## 📞 Support

If you encounter issues:
1. Check the logs: `docker compose -f /opt/scritodon/docker-compose.prod.yml logs`
2. Verify your AWS security group settings
3. Ensure all environment variables are properly set
4. Check system resources: `htop`, `df -h`, `free -h`

---

**Happy Testing! 🚀** 