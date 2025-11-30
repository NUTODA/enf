FROM python:3.11-slim

# Создание non-root пользователя для безопасности
RUN groupadd -r django && useradd -r -g django django

WORKDIR /app

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    gettext \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Скачивание wait-for-it.sh для ожидания готовности базы данных
RUN wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -O /usr/local/bin/wait-for-it.sh \
    && chmod +x /usr/local/bin/wait-for-it.sh

# Копирование файла с зависимостями
COPY requirements.txt /app/requirements.txt

# Установка Python зависимостей
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /app/requirements.txt

# Копирование всего проекта
COPY . /app/

# Создание директорий для статики и медиа с правильными правами
RUN mkdir -p /app/static /app/media && \
    chown -R django:django /app

# Копирование entrypoint скрипта
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Переменные окружения для Django
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=enf.settings

# Переключение на non-root пользователя
USER django

# Открытие порта
EXPOSE 8000

# Использование entrypoint для правильной инициализации
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]