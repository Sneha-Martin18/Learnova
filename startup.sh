#!/bin/bash

# Install required packages
pip install razorpay==1.3.8

# Run migrations
python manage.py migrate

# Start the application
gunicorn --bind=0.0.0.0:8000 student_management_system.wsgi:application
