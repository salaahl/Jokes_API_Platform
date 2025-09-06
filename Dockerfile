FROM php:8.2-fpm-alpine

# Variables d'environnement
ENV APP_ENV=prod
ENV APP_DEBUG=0

# Installation des dépendances système (incluant postgresql-client)
RUN apk add --no-cache \
    nginx \
    postgresql-dev \
    postgresql-client \
    icu-dev \
    zip \
    unzip \
    git \
    curl

# Extensions PHP
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    intl \
    opcache

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Installation du runtime Symfony
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts
RUN composer require symfony/runtime --no-update
RUN composer update symfony/runtime --with-dependencies --no-scripts --no-dev

# Configuration Nginx
RUN mkdir -p /var/log/nginx
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Copie du code source
COPY . .

# Permissions via nginx user
RUN mkdir -p /app/var \
 && chown -R nginx:nginx /app/var \
 && chmod -R 755 /app/var

# Script d'initialisation
COPY docker/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 10000
CMD ["/init.sh"]
