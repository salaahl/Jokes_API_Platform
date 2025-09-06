FROM php:8.2-fpm-alpine

ENV APP_ENV=prod
ENV APP_DEBUG=0
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_ALLOW_PLUGINS=symfony/flex,symfony/runtime,php-http/discovery

RUN apk add --no-cache nginx postgresql-dev postgresql-client icu-dev zip unzip git curl
RUN docker-php-ext-install pdo pdo_pgsql intl opcache
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# 1. Copier le code **avant** Composer pour que bin/console existe
COPY . .

# 2. Installer les dépendances et lancer les scripts (cache:clear, etc.)
RUN composer install --no-dev --optimize-autoloader

# 3. Permissions dossier var
RUN mkdir -p var \
 && chown -R nginx:nginx var \
 && chmod -R 755 var

COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 10000
CMD ["/init.sh"]
