FROM php:8.2-fpm-alpine

ENV APP_ENV=prod
ENV APP_DEBUG=0

RUN apk add --no-cache nginx postgresql-dev icu-dev zip unzip git curl

# Extensions PHP
RUN docker-php-ext-install pdo pdo_pgsql intl opcache

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Nginx conf
RUN mkdir -p /var/log/nginx
COPY docker/nginx.conf /etc/nginx/nginx.conf

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

COPY . .

# Permissions via nginx user
RUN mkdir -p /app/var \
 && chown -R nginx:nginx /app/var \
 && chmod -R 755 /app/var

COPY docker/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 10000
CMD ["/init.sh"]
