# Dockerfile
FROM php:8.2-fpm-alpine

# Variables d'environnement
ENV APP_ENV=prod
ENV APP_DEBUG=0

# Installation des dépendances système
RUN apk add --no-cache \
    nginx \
    postgresql-dev \
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

# Configuration Nginx
RUN mkdir -p /var/log/nginx
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Répertoire de travail
WORKDIR /app

# Copie des fichiers de dépendances
COPY composer.json composer.lock ./

# Installation des dépendances PHP (sans dev en production)
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copie du code source
COPY . .

# Permissions
RUN chown -R www-data:www-data /app/var
RUN chmod -R 755 /app/var

# Installation des assets (si vous utilisez Webpack Encore)
# RUN npm install && npm run build

# Script d'initialisation
COPY docker/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 10000

# Commande de démarrage
CMD ["/init.sh"]
