#!/bin/bash

# Test Local Deployment with AWS Configuration
# This script tests the deployment locally with AWS URLs

echo "🧪 Testing local deployment with AWS configuration..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker compose down 2>/dev/null || true

# Build and start the production configuration
echo "🏗️ Building and starting production containers..."
docker compose -f docker-compose.prod.yml up --build -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 30

# Test the services
echo "🧪 Testing services..."

# Test backend health
echo "Testing backend health..."
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ Backend is healthy"
else
    echo "❌ Backend health check failed"
fi

# Test frontend
echo "Testing frontend..."
if curl -f http://localhost:80 > /dev/null 2>&1; then
    echo "✅ Frontend is accessible"
else
    echo "❌ Frontend is not accessible"
fi

# Show container status
echo "📊 Container status:"
docker compose -f docker-compose.prod.yml ps

# Show logs
echo "📋 Recent logs:"
docker compose -f docker-compose.prod.yml logs --tail=20

echo ""
echo "🌐 Test URLs:"
echo "   Frontend: http://localhost:80"
echo "   Backend API: http://localhost:8000"
echo "   Health Check: http://localhost:8000/health"
echo "   API Docs: http://localhost:8000/docs"

echo ""
echo "📋 Next steps for AWS deployment:"
echo "1. Upload all files to your EC2 instance"
echo "2. Run the deploy-aws.sh script on the EC2 instance"
echo "3. Update the OPENROUTER_API_KEY in the .env file"
echo "4. Configure AWS security group to allow ports 80 and 8000" 