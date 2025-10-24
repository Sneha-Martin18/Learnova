#!/bin/bash
set -e

echo "Starting Django application..."

# Run collectstatic
echo "Collecting static files..."
python manage.py collectstatic --noinput --clear

# Start gunicorn
echo "Starting Gunicorn..."
exec gunicorn --bind=0.0.0.0:8000 --timeout 600 --workers 2 student_management_system.wsgi:application
