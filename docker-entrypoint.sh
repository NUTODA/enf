#!/bin/sh
set -e

echo "Waiting for database..."
/usr/local/bin/wait-for-it.sh db:5432 --timeout=30

echo "Waiting for Redis..."
/usr/local/bin/wait-for-it.sh redis:6379 --timeout=10 || echo "Redis not available, continuing..."

echo "Running migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput --clear

echo "Starting Gunicorn..."
exec gunicorn enf.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers ${GUNICORN_WORKERS:-4} \
    --worker-class sync \
    --worker-connections 1000 \
    --timeout 120 \
    --keep-alive 5 \
    --max-requests 1000 \
    --max-requests-jitter 50 \
    --access-logfile - \
    --error-logfile - \
    --log-level info

