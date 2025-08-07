#!/bin/bash

# Scriptodon AWS EC2 Deployment Script
# This script deploys the Scriptodon application to AWS EC2

set -e

echo "🚀 Starting Scriptodon AWS EC2 Deployment..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker and Docker Compose
echo "🐳 Installing Docker and Docker Compose..."
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add current user to docker group
sudo usermod -aG docker $USER

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Create application directory
echo "📁 Setting up application directory..."
sudo mkdir -p /opt/scritodon
sudo chown $USER:$USER /opt/scritodon
cd /opt/scritodon

# Clone or copy application files (assuming files are already uploaded)
echo "📋 Setting up application files..."

# Create environment file
echo "🔧 Creating environment configuration..."
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

# Create systemd service for auto-restart
echo "🔧 Creating systemd service..."
sudo tee /etc/systemd/system/scritodon.service > /dev/null << EOF
[Unit]
Description=Scriptodon Test Automation Platform
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/scritodon
ExecStart=/usr/local/bin/docker compose -f docker-compose.prod.yml up -d
ExecStop=/usr/local/bin/docker compose -f docker-compose.prod.yml down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl enable scritodon.service

# Build and deploy the application
echo "🏗️ Building and deploying application..."
docker compose -f docker-compose.prod.yml up --build -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 30

# Check service status
echo "🔍 Checking service status..."
docker compose -f docker-compose.prod.yml ps

# Test the application
echo "🧪 Testing application..."
curl -f http://localhost:8000/health || echo "Backend health check failed"
curl -f http://localhost:80 || echo "Frontend health check failed"

echo "✅ Deployment completed successfully!"
echo "🌐 Application URLs:"
echo "   Frontend: http://13.232.134.97"
echo "   Backend API: http://13.232.134.97:8000"
echo "   Health Check: http://13.232.134.97:8000/health"

echo ""
echo "📋 Next steps:"
echo "1. Update the OPENROUTER_API_KEY in /opt/scritodon/.env"
echo "2. Configure your firewall to allow ports 80 and 8000"
echo "3. Test the application at http://13.232.134.97"
echo ""
echo "🔧 Useful commands:"
echo "   View logs: docker compose -f /opt/scritodon/docker-compose.prod.yml logs -f"
echo "   Restart: sudo systemctl restart scritodon"
echo "   Stop: sudo systemctl stop scritodon" 