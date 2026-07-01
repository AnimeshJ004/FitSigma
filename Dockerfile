FROM php:7.4-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-scripts --no-interaction

# Create required Laravel directories
RUN mkdir -p storage/framework/sessions \
             storage/framework/views \
             storage/framework/cache/data \
             storage/logs \
             bootstrap/cache \
    && chmod -R 777 storage bootstrap/cache

# Write startup script
RUN cat > /start.sh << 'EOF'
#!/bin/sh
set -e

echo "=== Starting FitSigma ==="

# Build .env from environment variables
cat > /var/www/html/.env << ENVEOF
APP_NAME=FitSigma
APP_ENV=production
APP_KEY=${APP_KEY}
APP_DEBUG=true
APP_LOG_LEVEL=debug
APP_URL=${APP_URL:-http://localhost}

DB_CONNECTION=mysql
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT:-3306}
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

CACHE_DRIVER=array
SESSION_DRIVER=file
QUEUE_DRIVER=database
ENVEOF

echo "=== .env written ==="
cat /var/www/html/.env

cd /var/www/html

# Generate key if missing
php artisan key:generate --force
php artisan config:clear
php artisan cache:clear

echo "=== Running migrations ==="
php artisan migrate --force || echo "Migration failed - continuing anyway"

echo "=== Tailing log in background ==="
touch storage/logs/laravel.log
tail -f storage/logs/laravel.log &

echo "=== Starting PHP server on port ${PORT:-8080} ==="
php -S 0.0.0.0:${PORT:-8080} -t public
EOF

RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
