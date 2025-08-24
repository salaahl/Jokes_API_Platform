FROM php:8.3-cli AS symfony_php

# Installer dépendances système + client PostgreSQL
RUN apt-get update && apt-get install -y \
    git unzip libpq-dev libicu-dev libzip-dev postgresql-client \
    && docker-php-ext-install intl pdo pdo_pgsql opcache zip \
    && rm -rf /var/lib/apt/lists/*

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/symfony

# Copier composer.* pour profiter du cache Docker
COPY composer.json composer.lock ./

# Installer les dépendances en root
RUN composer install --no-dev --optimize-autoloader --working-dir=/var/www/symfony

# Copier le reste du projet
COPY . .

# Créer var/ et public/ + corriger permissions
RUN mkdir -p var public \
    && chown -R www-data:www-data var public vendor

# Configurer PHP pour production (opcache)
RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.memory_consumption=256'; \
    echo 'opcache.max_accelerated_files=20000'; \
    echo 'opcache.validate_timestamps=0'; \
  } > /usr/local/etc/php/conf.d/opcache.ini

# Copier entrypoint
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Passer à www-data pour exécution
USER www-data
WORKDIR /var/www/symfony

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php", "-S", "0.0.0.0:${PORT:-8000}", "-t", "public"]
