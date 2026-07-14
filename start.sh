#!/bin/sh
set -e

echo "=== Starting FitSigma ==="

cd /var/www/html

# Build a runtime .env only when the deployment has not provided one.
# Do not overwrite database or app settings on every boot; that makes deploys
# look unchanged because the app falls back to fresh seeded SQLite data.
if [ ! -f /var/www/html/.env ]; then
    cat > /var/www/html/.env << ENVEOF
APP_NAME=FitSigma
APP_ENV=${APP_ENV:-production}
APP_KEY=${APP_KEY}
APP_DEBUG=${APP_DEBUG:-false}
APP_LOG_LEVEL=${APP_LOG_LEVEL:-debug}
APP_URL=${APP_URL:-http://localhost}

DB_CONNECTION=${DB_CONNECTION:-sqlite}
DB_DATABASE=${DB_DATABASE:-/var/www/html/database/database.sqlite}
DB_HOST=${DB_HOST:-127.0.0.1}
DB_PORT=${DB_PORT:-3306}
DB_USERNAME=${DB_USERNAME:-}
DB_PASSWORD=${DB_PASSWORD:-}

CACHE_DRIVER=${CACHE_DRIVER:-array}
SESSION_DRIVER=${SESSION_DRIVER:-file}
QUEUE_DRIVER=${QUEUE_DRIVER:-sync}
ENVEOF
    echo "=== .env written ==="
else
    echo "=== Using existing .env ==="
fi

chmod 777 /var/www/html/database || true

if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ]; then
    touch "${DB_DATABASE:-/var/www/html/database/database.sqlite}"
    chmod 777 "${DB_DATABASE:-/var/www/html/database/database.sqlite}"
fi

# Force clear ALL caches
echo "=== Clearing all caches ==="
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Remove all cached views manually to ensure they regenerate
rm -rf storage/framework/views/*
rm -rf storage/framework/cache/*
rm -rf storage/framework/sessions/*
rm -rf bootstrap/cache/*

# Recreate cache folders
mkdir -p storage/framework/views
mkdir -p storage/framework/cache/data
mkdir -p storage/framework/sessions
mkdir -p bootstrap/cache

echo "=== Cache cleared successfully ==="

if ! grep -q '^APP_KEY=base64:' /var/www/html/.env; then
    php artisan key:generate --force
fi

echo "=== Running migrations ==="
php artisan migrate --force || echo "Migration failed - continuing anyway"

echo "=== Running seeders ==="
php artisan db:seed --force || echo "Seeding failed - continuing anyway"

echo "=== Tailing log in background ==="
touch storage/logs/laravel.log
tail -f storage/logs/laravel.log &

echo "=== Starting PHP server on port ${PORT:-8080} ==="
exec php artisan serve --host=0.0.0.0 --port=${PORT:-8080} 2>&1
