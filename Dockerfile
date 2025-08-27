# Dockerfile example
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_pgsql

# Create symfony directory with proper permissions BEFORE copying files
RUN mkdir -p /var/www/symfony && \
    chown -R www-data:www-data /var/www/symfony && \
    chmod -R 755 /var/www/symfony

# Set working directory
WORKDIR /var/www/symfony

# Copy composer files first for better caching
COPY --chown=www-data:www-data composer.json composer.lock ./

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Install dependencies as www-data
USER www-data
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy application files
COPY --chown=www-data:www-data . .

# Create var directory with proper permissions
RUN mkdir -p var/cache var/log && \
    chmod -R 775 var

# Switch back to root for entrypoint
USER root

# Copier configs Nginx et Supervisor
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker-entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Switch back to www-data
USER www-data

CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]
