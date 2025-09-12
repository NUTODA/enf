FROM python:3.10-slim

WORKDIR /app

# Обновление или установка пакетов 
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    gettext \  
    vim \
#.  Очистка кеша либ
    && rm -rf /var/lib/apt/lists/*

# Копирование файла с зависимостями
COPY requirements.txt .

# Установка зависимостей без кеша
RUN pip install --no-cache-dir -r requirements.txt



COPY . .

CMD ["sh", "-c", "python manage.py migrate && gunicorn enf.wsgi:application --bind 0.0.0.0:8000"]