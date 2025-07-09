# Student Management System - Microservices Architecture

This project has been converted from a Django monolith into a microservices architecture with 7 distinct services.

## 🏗️ Architecture Overview

### Services Breakdown:

1. **User Service (Port: 8001)** - Core authentication and user management
2. **Academic Service (Port: 8002)** - Course and subject management
3. **Attendance Service (Port: 8003)** - Attendance tracking and reporting
4. **Assessment Service (Port: 8004)** - Grades, assignments, and results
5. **Communication Service (Port: 8005)** - Feedback and notifications
6. **Leave Service (Port: 8006)** - Leave applications and approvals
7. **Financial Service (Port: 8007)** - Fines and payment processing
8. **API Gateway (Port: 8000)** - Central routing and authentication

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Python 3.9+
- Git

### Installation & Setup

1. **Clone and Navigate:**
```bash
cd microservices
```

2. **Start All Services:**
```bash
docker-compose up --build
```

3. **Access Services:**
- API Gateway: http://localhost:8000
- User Service: http://localhost:8001
- Academic Service: http://localhost:8002
- Attendance Service: http://localhost:8003
- Assessment Service: http://localhost:8004
- Communication Service: http://localhost:8005
- Leave Service: http://localhost:8006
- Financial Service: http://localhost:8007

## 📁 Service Structure

```
microservices/
├── user_service/           # User management & authentication
├── academic_service/       # Courses, subjects, sessions
├── attendance_service/     # Attendance tracking
├── assessment_service/     # Grades & assignments
├── communication_service/  # Feedback & notifications
├── leave_service/         # Leave management
├── financial_service/     # Fines & payments
├── api_gateway/          # Central API gateway
├── shared/               # Shared utilities
└── docker-compose.yml    # Service orchestration
```

## 🔧 Service Details

### User Service (Core)
**Models:** CustomUser, AdminHOD, Staffs, Students
**APIs:**
- `POST /api/auth/login/` - User authentication
- `GET /api/users/` - List all users
- `GET /api/users/{id}/` - Get user details
- `POST /api/users/create/` - Create new user
- `GET /api/auth/validate/` - Validate JWT token

### Academic Service
**Models:** Courses, Subjects, SessionYearModel
**APIs:**
- `GET /api/courses/` - List courses
- `POST /api/courses/` - Create course
- `GET /api/subjects/` - List subjects
- `POST /api/subjects/` - Create subject
- `GET /api/sessions/` - List sessions

### Attendance Service
**Models:** Attendance, AttendanceReport
**APIs:**
- `POST /api/attendance/mark/` - Mark attendance
- `GET /api/attendance/report/` - Get attendance report
- `GET /api/attendance/student/{id}/` - Student attendance

### Assessment Service
**Models:** StudentResult, Assignment, AssignmentSubmission
**APIs:**
- `POST /api/results/add/` - Add student results
- `GET /api/results/` - List results
- `POST /api/assignments/` - Create assignment
- `POST /api/assignments/{id}/submit/` - Submit assignment

### Communication Service
**Models:** FeedBackStudent, FeedBackStaffs, NotificationStudent, NotificationStaffs
**APIs:**
- `POST /api/feedback/submit/` - Submit feedback
- `GET /api/feedback/` - List feedback
- `POST /api/notifications/send/` - Send notification
- `GET /api/notifications/` - List notifications

### Leave Service
**Models:** LeaveReportStudent, LeaveReportStaff
**APIs:**
- `POST /api/leaves/apply/` - Apply for leave
- `GET /api/leaves/` - List leave requests
- `POST /api/leaves/{id}/approve/` - Approve leave
- `POST /api/leaves/{id}/reject/` - Reject leave

### Financial Service
**Models:** Fine, FinePayment
**APIs:**
- `POST /api/fines/` - Create fine
- `GET /api/fines/` - List fines
- `POST /api/fines/{id}/pay/` - Pay fine
- `GET /api/payments/` - List payments

## 🔐 Authentication

All services use JWT tokens for authentication. The User Service is responsible for:
- User authentication
- JWT token generation
- Token validation

### Authentication Flow:
1. User sends credentials to User Service
2. User Service validates and returns JWT token
3. Other services validate JWT token for protected endpoints

## 📊 Database Strategy

Each service has its own database:
- **User Service:** SQLite (user_service.db)
- **Academic Service:** SQLite (academic_service.db)
- **Attendance Service:** SQLite (attendance_service.db)
- **Assessment Service:** SQLite (assessment_service.db)
- **Communication Service:** SQLite (communication_service.db)
- **Leave Service:** SQLite (leave_service.db)
- **Financial Service:** SQLite (financial_service.db)

## 🔄 Inter-Service Communication

### Synchronous Communication (REST APIs)
Services communicate via HTTP requests for real-time operations.

### Data Consistency
- Each service maintains its own data
- Cross-service references use IDs
- Event-driven updates for data synchronization

## 🛠️ Development

### Running Individual Services

```bash
# User Service
cd user_service
python manage.py runserver 8001

# Academic Service
cd academic_service
python manage.py runserver 8002

# Continue for other services...
```

### Database Migrations

```bash
# For each service
python manage.py makemigrations
python manage.py migrate
```

### Creating Superuser

```bash
# For each service
python manage.py createsuperuser
```

## 🧪 Testing

### Health Checks
Each service provides a health check endpoint:
- `GET /api/health/` - Service health status

### API Testing
Use tools like Postman or curl to test the APIs:

```bash
# Login example
curl -X POST http://localhost:8001/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "password"}'
```

## 📈 Monitoring

### Service Status
- API Gateway: http://localhost:8000/health/
- User Service: http://localhost:8001/api/health/
- Academic Service: http://localhost:8002/api/health/
- etc.

### Logs
```bash
# View all service logs
docker-compose logs

# View specific service logs
docker-compose logs user_service
```

## 🚀 Deployment

### Production Considerations
1. **Database:** Use PostgreSQL for production
2. **Security:** Change default secret keys
3. **Environment Variables:** Use proper environment configuration
4. **SSL/TLS:** Enable HTTPS
5. **Load Balancing:** Use nginx or similar
6. **Monitoring:** Implement proper logging and monitoring

### Environment Variables
```bash
# Example production environment
DEBUG=False
SECRET_KEY=your-secure-secret-key
DATABASE_URL=postgresql://user:pass@host:port/db
```

## 🔧 Troubleshooting

### Common Issues

1. **Port Conflicts:** Ensure ports 8000-8007 are available
2. **Database Issues:** Check database migrations
3. **Network Issues:** Verify Docker network configuration
4. **Authentication Issues:** Check JWT token configuration

### Debug Mode
```bash
# Run with debug output
docker-compose up --build -d
docker-compose logs -f
```

## 📚 API Documentation

### Authentication Headers
```bash
Authorization: Bearer <jwt_token>
```

### Response Format
```json
{
  "status": "success",
  "data": {...},
  "message": "Operation completed"
}
```

### Error Format
```json
{
  "status": "error",
  "error": "Error message",
  "code": 400
}
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

---

## 🎯 Migration Strategy

### Phase 1: Setup Infrastructure
- ✅ Create service structure
- ✅ Setup Docker configuration
- ✅ Implement basic APIs

### Phase 2: Data Migration
- [ ] Migrate user data to User Service
- [ ] Migrate academic data to Academic Service
- [ ] Migrate attendance data to Attendance Service
- [ ] Continue for other services

### Phase 3: Frontend Integration
- [ ] Update frontend to use new APIs
- [ ] Implement proper error handling
- [ ] Add loading states

### Phase 4: Testing & Optimization
- [ ] Comprehensive testing
- [ ] Performance optimization
- [ ] Security hardening

### Phase 5: Production Deployment
- [ ] Production environment setup
- [ ] Monitoring implementation
- [ ] Documentation completion 