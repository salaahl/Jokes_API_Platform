FROM php:8.2-fpm-alpine

# Variables d'environnement
ENV APP_ENV=prod
ENV APP_DEBUG=0

# Autoriser Composer à tourner en tant que root et lancer les plugins
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_ALLOW_PLUGINS=symfony/flex,symfony/runtime,php-http/discovery


# Dépendances système
RUN apk add --no-cache nginx postgresql-dev postgresql-client icu-dev zip unzip git curl

# Extensions PHP
RUN docker-php-ext-install pdo pdo_pgsql intl opcache


# S'assurer que PHP lit bien les variables d'environnement
RUN echo "variables_order=EGPCS" > /usr/local/etc/php/conf.d/env-vars.ini

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Installer toutes les dépendances, y compris symfony/runtime
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copier le code  
COPY . .

# Permissions dossier var  
RUN mkdir -p var && chown -R nginx:nginx var && chmod -R 755 var

# Config Nginx et init  
COPY docker/nginx.conf /etc/nginx/nginx.conf  
COPY docker/init.sh /init.sh  
RUN chmod +x /init.sh

EXPOSE 10000
CMD ["/init.sh"]
