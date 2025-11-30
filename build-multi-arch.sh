#!/bin/bash

# Скрипт для сборки multi-architecture Docker образа
# Использование: ./build-multi-arch.sh [tag] [version]
# Пример: ./build-multi-arch.sh nutoda/enf v1.0

set -e

# Параметры по умолчанию
DOCKER_USERNAME="${DOCKER_USERNAME:-nutoda}"
IMAGE_NAME="${IMAGE_NAME:-enf}"
TAG="${1:-${DOCKER_USERNAME}/${IMAGE_NAME}}"
VERSION="${2:-latest}"

echo "=========================================="
echo "Multi-Architecture Docker Build"
echo "=========================================="
echo "Image: ${TAG}:${VERSION}"
echo "Platforms: linux/amd64, linux/arm64"
echo "=========================================="

# Проверка входа в Docker Hub
if ! docker info | grep -q "Username"; then
    echo "Вход в Docker Hub..."
    docker login
fi

# Создание или использование builder
echo "Настройка Docker Buildx..."
docker buildx create --name multiarch-builder --use 2>/dev/null || docker buildx use multiarch-builder

# Проверка доступных платформ
echo "Проверка доступных платформ..."
docker buildx inspect --bootstrap

# Сборка и загрузка образа
echo "Сборка образа для всех платформ..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag "${TAG}:${VERSION}" \
  --tag "${TAG}:latest" \
  --push \
  .

echo "=========================================="
echo "Сборка завершена!"
echo "Проверка манифеста..."
docker buildx imagetools inspect "${TAG}:latest"

echo "=========================================="
echo "Образ успешно загружен на Docker Hub!"
echo "Используйте: ${TAG}:latest в docker-compose.yml"
echo "=========================================="

