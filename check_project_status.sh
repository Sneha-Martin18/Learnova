#!/bin/bash

echo "=========================================="
echo "LEARNOVA Project Status Checker"
echo "=========================================="
echo ""

# Check if Docker is running
echo "1️⃣  Checking Docker..."
if docker info > /dev/null 2>&1; then
    echo "✅ Docker is running"
else
    echo "❌ Docker is not running"
    echo "   Start Docker Desktop or run: sudo systemctl start docker"
    exit 1
fi
echo ""

# Check monolith application
echo "2️⃣  Checking Monolith Application..."
if docker compose ps | grep -q "web"; then
    echo "✅ Monolith is running"
    docker compose ps
else
    echo "⚠️  Monolith is not running"
    echo "   Start with: docker compose up -d"
fi
echo ""

# Check microservices
echo "3️⃣  Checking Microservices..."
cd microservices
if docker compose ps | grep -q "Up"; then
    echo "✅ Some microservices are running:"
    docker compose ps
else
    echo "⚠️  No microservices are running"
    echo "   Start with: cd microservices && docker compose up -d"
fi
cd ..
echo ""

# Check ports
echo "4️⃣  Checking Application Ports..."
echo ""
echo "Monolith Application:"
if curl -s http://localhost:8000 > /dev/null 2>&1; then
    echo "  ✅ http://localhost:8000 - Accessible"
else
    echo "  ❌ http://localhost:8000 - Not accessible"
fi
echo ""

echo "Microservices:"
SERVICES=(
    "8080:API Gateway"
    "8000:User Management"
    "8001:Academic"
    "8002:Attendance"
    "8003:Notification"
    "8004:Leave Management"
    "8005:Feedback"
    "8006:Assessment"
    "8007:Financial"
    "9000:Frontend"
)

for service in "${SERVICES[@]}"; do
    PORT="${service%%:*}"
    NAME="${service##*:}"
    if curl -s http://localhost:$PORT > /dev/null 2>&1; then
        echo "  ✅ http://localhost:$PORT - $NAME"
    else
        echo "  ❌ http://localhost:$PORT - $NAME (not running)"
    fi
done
echo ""

# Summary
echo "=========================================="
echo "📋 Quick Commands"
echo "=========================================="
echo ""
echo "Start Monolith:"
echo "  docker compose up -d"
echo ""
echo "Start Microservices:"
echo "  cd microservices && docker compose up -d"
echo ""
echo "View Logs:"
echo "  docker compose logs -f"
echo "  cd microservices && docker compose logs -f"
echo ""
echo "Stop Services:"
echo "  docker compose down"
echo "  cd microservices && docker compose down"
echo ""
echo "=========================================="
