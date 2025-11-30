# ENF - E-commerce Django Project

#django #e-commerce #docker #postgresql #stripe

## Описание проекта

Интернет-магазин на Django с функционалом:
- Каталог товаров с категориями и фильтрацией
- Корзина покупок (сессионная)
- Система заказов
- Интеграция с Stripe для платежей
- Регистрация и авторизация пользователей
- Админ-панель Django

**Технологии:**
- Django 5.2.4
- PostgreSQL
- Docker & Docker Compose
- Nginx
- Gunicorn
- WhiteNoise (статические файлы)
- Stripe API

---

## Структура проекта

```
enf/
├── enf/                    # Основные настройки Django проекта
│   ├── settings.py         # Конфигурация приложения
│   ├── urls.py             # Главный URL роутинг
│   ├── wsgi.py             # WSGI конфигурация
│   └── asgi.py             # ASGI конфигурация
│
├── main/                   # Главное приложение (каталог товаров)
│   ├── models.py           # Модели: Product, Category, Size, ProductImage
│   ├── views.py            # Представления: каталог, детали товара
│   ├── urls.py             # URL маршруты каталога
│   ├── admin.py            # Админ-панель для товаров
│   └── templates/          # Шаблоны: каталог, детали товара, главная
│
├── cart/                   # Приложение корзины
│   ├── models.py           # Модели: Cart, CartItem
│   ├── views.py            # API для работы с корзиной
│   ├── middleware.py       # Middleware для автоматической корзины
│   ├── context_processors.py  # Контекстный процессор корзины
│   └── templates/          # Шаблоны корзины (модальные окна)
│
├── users/                   # Приложение пользователей
│   ├── models.py           # Модель CustomUser
│   ├── views.py            # Регистрация, авторизация, профиль
│   ├── forms.py            # Формы регистрации и профиля
│   └── templates/          # Шаблоны: login, register, profile
│
├── orders/                  # Приложение заказов
│   ├── models.py           # Модели: Order, OrderItem
│   ├── views.py            # Оформление заказа, история
│   ├── forms.py            # Форма оформления заказа
│   └── templates/          # Шаблоны: checkout, история заказов
│
├── payment/                 # Приложение платежей
│   ├── views.py            # Обработка Stripe платежей
│   └── templates/          # Шаблоны: success, cancel
│
├── media/                   # Загруженные файлы (изображения товаров)
│   └── products/
│       ├── main/           # Основные изображения товаров
│       └── extra/         # Дополнительные изображения
│
├── static/                  # Статические файлы (собираются автоматически)
│
├── manage.py                # Django management скрипт
├── requirements.txt        # Python зависимости
│
├── Dockerfile              # Docker образ приложения
├── docker-compose.yml      # Docker Compose конфигурация
├── docker-entrypoint.sh    # Скрипт инициализации контейнера
├── nginx.conf              # Конфигурация Nginx
├── .dockerignore           # Исключения для Docker
└── .env                    # Переменные окружения (не в репозитории)
```

---

## Запуск проекта

### Локальная разработка (без Docker)

1. **Установка зависимостей:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/macOS
   # или
   venv\Scripts\activate     # Windows
   
   pip install -r requirements.txt
   ```

2. **Настройка базы данных:**
   - Создайте PostgreSQL базу данных
   - Создайте файл `.env` с переменными:
     ```env
     SECRET_KEY=your-secret-key
     POSTGRES_DB=enf_db
     POSTGRES_USER=your_user
     POSTGRES_PASSWORD=your_password
     POSTGRES_HOST=localhost
     POSTGRES_PORT=5432
     STRIPE_SECRET_KEY=your_stripe_key
     STRIPE_WEBHOOK_SECRET=your_webhook_secret
     ```

3. **Миграции и создание суперпользователя:**
   ```bash
   python manage.py migrate
   python manage.py createsuperuser
   python manage.py collectstatic
   ```

4. **Запуск сервера:**
   ```bash
   python manage.py runserver
   ```

### Запуск через Docker

1. **Создайте `.env` файл:**
   ```env
   SECRET_KEY=your-secret-key
   POSTGRES_DB=enf_db
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=postgres
   DOCKER_IMAGE=nutoda/enf:latest
   APP_PORT=8000
   STRIPE_SECRET_KEY=your_stripe_key
   STRIPE_WEBHOOK_SECRET=your_webhook_secret
   ```

2. **Запуск контейнеров:**
   ```bash
   docker-compose up -d
   ```

3. **Создание суперпользователя:**
   ```bash
   docker exec -it enf_web python manage.py createsuperuser
   ```

4. **Доступ к приложению:**
   - Прямой доступ: `http://localhost:8000`
   - Через Nginx: `http://localhost`
   - Админ-панель: `http://localhost:8000/admin/`

### Полезные команды Docker

```bash
# Просмотр логов
docker-compose logs -f web

# Остановка контейнеров
docker-compose down

# Перезапуск
docker-compose restart

# Выполнение команд в контейнере
docker exec -it enf_web python manage.py <команда>

# Сбор статики
docker exec -it enf_web python manage.py collectstatic --noinput
```

---

## Сборка Docker образа для разных платформ

Для сборки образа, работающего на macOS, Windows и Linux:

```bash
# Вход в Docker Hub
docker login

# Сборка для всех платформ
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag nutoda/enf:latest \
  --push \
  .
```

Или используйте готовые скрипты:
- **Linux/macOS:** `./build-multi-arch.sh nutoda/enf v1.0`
- **Windows:** `.\build-multi-arch.ps1 nutoda/enf v1.0`

---

## Основные модели данных

### Product (Товар)
- Название, slug, категория
- Цена, цвет, описание
- Основное изображение
- Связь с размерами через ProductSize

### Cart (Корзина)
- Привязана к сессии пользователя
- Содержит CartItem (товары с размерами и количеством)

### Order (Заказ)
- Информация о покупателе
- Связь с Stripe Payment Intent
- Статус заказа
- Содержит OrderItem

### CustomUser (Пользователь)
- Расширенная модель пользователя Django
- Связь с заказами

---

## Переменные окружения

Обязательные переменные в `.env`:

```env
# Django
SECRET_KEY=...

# База данных
POSTGRES_DB=enf_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=...
POSTGRES_HOST=db
POSTGRES_PORT=5432

# Docker
DOCKER_IMAGE=nutoda/enf:latest
APP_PORT=8000

# Stripe
STRIPE_SECRET_KEY=sk_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

---

## Архитектура

- **Frontend:** Django Templates (HTML)
- **Backend:** Django 5.2.4
- **Database:** PostgreSQL 16
- **Web Server:** Nginx (reverse proxy)
- **WSGI Server:** Gunicorn
- **Static Files:** WhiteNoise + Nginx
- **Payment:** Stripe API

---

## Теги

#django #e-commerce #docker #postgresql #stripe #python #web-development

