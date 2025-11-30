# PowerShell скрипт для сборки multi-architecture Docker образа
# Использование: .\build-multi-arch.ps1 [tag] [version]
# Пример: .\build-multi-arch.ps1 nutoda/enf v1.0

param(
    [string]$Tag = "nutoda/enf",
    [string]$Version = "latest"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Multi-Architecture Docker Build" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Image: ${Tag}:${Version}" -ForegroundColor Yellow
Write-Host "Platforms: linux/amd64, linux/arm64" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

# Проверка входа в Docker Hub
$dockerInfo = docker info 2>&1
if ($dockerInfo -notmatch "Username") {
    Write-Host "Вход в Docker Hub..." -ForegroundColor Yellow
    docker login
}

# Создание или использование builder
Write-Host "Настройка Docker Buildx..." -ForegroundColor Yellow
docker buildx create --name multiarch-builder --use 2>$null
if ($LASTEXITCODE -ne 0) {
    docker buildx use multiarch-builder
}

# Проверка доступных платформ
Write-Host "Проверка доступных платформ..." -ForegroundColor Yellow
docker buildx inspect --bootstrap

# Сборка и загрузка образа
Write-Host "Сборка образа для всех платформ..." -ForegroundColor Yellow
docker buildx build `
  --platform linux/amd64,linux/arm64 `
  --tag "${Tag}:${Version}" `
  --tag "${Tag}:latest" `
  --push `
  .

if ($LASTEXITCODE -eq 0) {
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "Сборка завершена!" -ForegroundColor Green
    Write-Host "Проверка манифеста..." -ForegroundColor Yellow
    docker buildx imagetools inspect "${Tag}:latest"
    
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "Образ успешно загружен на Docker Hub!" -ForegroundColor Green
    Write-Host "Используйте: ${Tag}:latest в docker-compose.yml" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Green
} else {
    Write-Host "Ошибка при сборке образа!" -ForegroundColor Red
    exit 1
}

