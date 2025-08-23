FROM php:8.3-fpm AS symfony_php

# Installer dépendances système
RUN apt-get update && apt-get install -y \
    git unzip libpq-dev libicu-dev libzip-dev \
    && docker-php-ext-install intl pdo pdo_pgsql opcache zip

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/symfony

# Copier uniquement composer.* pour profiter du cache Docker
COPY composer.json composer.lock ./
RUN composer install --no-scripts --no-interaction --prefer-dist --no-dev

# Copier le reste du projet
COPY . .

# Droits sur var/
RUN chown -R www-data:www-data /var/www/symfony/var

# Configurer PHP pour production (opcache)
RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.memory_consumption=256'; \
    echo 'opcache.max_accelerated_files=20000'; \
    echo 'opcache.validate_timestamps=0'; \
  } > /usr/local/etc/php/conf.d/opcache.ini
