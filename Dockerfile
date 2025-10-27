FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    netcat-openbsd \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt requirements-dev.txt ./
RUN pip install --no-cache-dir -r requirements.txt -r requirements-dev.txt razorpay psycopg2-binary gunicorn

# Copy project files
COPY . .

# Create necessary directories
RUN mkdir -p staticfiles media

# Collect static files
RUN python manage.py collectstatic --noinput || true

# Expose port
EXPOSE 8000

# Run migrations, create admin, and start gunicorn
CMD python manage.py migrate --noinput && \
    python manage.py createadmin && \
    gunicorn student_management_system.wsgi:application --bind 0.0.0.0:8000 --workers 2 --timeout 120 --access-logfile - --error-logfile -
