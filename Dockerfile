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

# Création de l'utilisateur www-data
RUN addgroup -g 82 -S www-data && adduser -u 82 -D -S -G www-data www-data

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

# Installation des dépendances PHP
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copie du code source
COPY . .

# Création du dossier var s'il n'existe pas et permissions
RUN mkdir -p /app/var
RUN chown -R www-data:www-data /app/var
RUN chmod -R 755 /app/var

# Script d'initialisation
COPY docker/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 10000

CMD ["/init.sh"]
