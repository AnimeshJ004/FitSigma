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

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-interaction

# Create all required Laravel directories
RUN mkdir -p storage/framework/sessions \
             storage/framework/views \
             storage/framework/cache/data \
             storage/logs \
             bootstrap/cache \
    && chmod -R 777 storage bootstrap/cache

# Create startup script that builds .env from Railway environment variables at runtime
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'cp .env.example .env' >> /start.sh && \
    echo 'sed -i "s|APP_KEY=.*|APP_KEY=${APP_KEY}|" .env' >> /start.sh && \
    echo 'sed -i "s|APP_URL=.*|APP_URL=${APP_URL}|" .env' >> /start.sh && \
    echo 'sed -i "s|APP_ENV=.*|APP_ENV=${APP_ENV:-production}|" .env' >> /start.sh && \
    echo 'sed -i "s|APP_DEBUG=.*|APP_DEBUG=${APP_DEBUG:-false}|" .env' >> /start.sh && \
    echo 'sed -i "s|DB_HOST=.*|DB_HOST=${DB_HOST}|" .env' >> /start.sh && \
    echo 'sed -i "s|DB_PORT=.*|DB_PORT=${DB_PORT:-3306}|" .env' >> /start.sh && \
    echo 'sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_DATABASE}|" .env' >> /start.sh && \
    echo 'sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USERNAME}|" .env' >> /start.sh && \
    echo 'sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASSWORD}|" .env' >> /start.sh && \
    echo 'sed -i "s|SESSION_DRIVER=.*|SESSION_DRIVER=file|" .env' >> /start.sh && \
    echo 'sed -i "s|CACHE_DRIVER=.*|CACHE_DRIVER=array|" .env' >> /start.sh && \
    echo 'php artisan key:generate --force 2>/dev/null || true' >> /start.sh && \
    echo 'php artisan config:clear' >> /start.sh && \
    echo 'php artisan migrate --force 2>/dev/null || true' >> /start.sh && \
    echo 'php -S 0.0.0.0:${PORT:-8080} -t public' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
