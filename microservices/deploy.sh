#!/bin/bash

echo "🚀 Deploying Student Management System Microservices..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Create necessary directories
echo "📁 Creating service directories..."
mkdir -p {user_service,academic_service,attendance_service,assessment_service,communication_service,leave_service,financial_service,api_gateway}/logs

# Build and start services
echo "🔨 Building and starting services..."
docker-compose up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check service health
echo "🏥 Checking service health..."
services=("user_service:8001" "academic_service:8002" "attendance_service:8003" "assessment_service:8004" "communication_service:8005" "leave_service:8006" "financial_service:8007" "api_gateway:8000")

for service in "${services[@]}"; do
    service_name=$(echo $service | cut -d: -f1)
    port=$(echo $service | cut -d: -f2)
    
    if curl -s http://localhost:$port/api/health/ > /dev/null 2>&1; then
        echo "✅ $service_name is healthy"
    else
        echo "❌ $service_name is not responding"
    fi
done

echo "🎉 Deployment completed!"
echo ""
echo "📋 Service URLs:"
echo "  API Gateway: http://localhost:8000"
echo "  User Service: http://localhost:8001"
echo "  Academic Service: http://localhost:8002"
echo "  Attendance Service: http://localhost:8003"
echo "  Assessment Service: http://localhost:8004"
echo "  Communication Service: http://localhost:8005"
echo "  Leave Service: http://localhost:8006"
echo "  Financial Service: http://localhost:8007"
echo ""
echo "📚 View logs: docker-compose logs -f"
echo "🛑 Stop services: docker-compose down" 