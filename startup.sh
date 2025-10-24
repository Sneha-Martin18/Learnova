#!/bin/bash

# Download database from Azure Storage if it doesn't exist
if [ ! -f "db.sqlite3" ] && [ -n "$AZURE_ACCOUNT_NAME" ] && [ -n "$AZURE_ACCOUNT_KEY" ]; then
    echo "Downloading database from Azure Storage..."
    curl -o db.sqlite3 "https://${AZURE_ACCOUNT_NAME}.blob.core.windows.net/database/db.sqlite3"
fi

# Run migrations
python manage.py migrate --noinput

# Collect static files
python manage.py collectstatic --noinput

# Start the application
gunicorn --bind=0.0.0.0:8000 --timeout 600 student_management_system.wsgi:application
