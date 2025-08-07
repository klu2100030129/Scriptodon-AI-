#!/bin/bash

# Scriptodon Docker Deployment Script for AWS
# Usage: ./scripts/deploy.sh [dev|prod]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-prod}
COMPOSE_FILE="docker-compose.yml"
if [ "$ENVIRONMENT" = "prod" ]; then
    COMPOSE_FILE="docker-compose.prod.yml"
fi

echo -e "${GREEN}🚀 Starting Scriptodon deployment...${NC}"
echo -e "${YELLOW}Environment: $ENVIRONMENT${NC}"
echo -e "${YELLOW}Compose file: $COMPOSE_FILE${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

# Create necessary directories
echo -e "${YELLOW}📁 Creating necessary directories...${NC}"
mkdir -p nginx/ssl
mkdir -p backend/scripts
mkdir -p backend/reports
mkdir -p backend/uploads

# Generate self-signed SSL certificate for development
if [ "$ENVIRONMENT" = "dev" ]; then
    echo -e "${YELLOW}🔐 Generating self-signed SSL certificate...${NC}"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout nginx/ssl/key.pem \
        -out nginx/ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
fi

# Stop existing containers
echo -e "${YELLOW}🛑 Stopping existing containers...${NC}"
docker-compose -f $COMPOSE_FILE down --remove-orphans

# Remove old images
echo -e "${YELLOW}🧹 Cleaning up old images...${NC}"
docker system prune -f

# Build and start containers
echo -e "${YELLOW}🔨 Building and starting containers...${NC}"
docker-compose -f $COMPOSE_FILE up --build -d

# Wait for services to be ready
echo -e "${YELLOW}⏳ Waiting for services to be ready...${NC}"
sleep 30

# Check service health
echo -e "${YELLOW}🏥 Checking service health...${NC}"
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend is healthy${NC}"
else
    echo -e "${RED}❌ Backend health check failed${NC}"
fi

if curl -f http://localhost/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Frontend is healthy${NC}"
else
    echo -e "${RED}❌ Frontend health check failed${NC}"
fi

# Show running containers
echo -e "${YELLOW}📋 Running containers:${NC}"
docker-compose -f $COMPOSE_FILE ps

# Show logs
echo -e "${YELLOW}📝 Recent logs:${NC}"
docker-compose -f $COMPOSE_FILE logs --tail=20

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${GREEN}🌐 Access the application at:${NC}"
if [ "$ENVIRONMENT" = "prod" ]; then
    echo -e "${GREEN}   https://your-domain.com${NC}"
else
    echo -e "${GREEN}   http://localhost:3000${NC}"
fi

echo -e "${YELLOW}📊 Monitor logs with: docker-compose -f $COMPOSE_FILE logs -f${NC}"
echo -e "${YELLOW}🛑 Stop services with: docker-compose -f $COMPOSE_FILE down${NC}" 