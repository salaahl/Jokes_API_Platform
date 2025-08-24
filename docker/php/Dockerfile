FROM php:8.3-fpm-alpine

# Installer dépendances système + PostgreSQL
RUN apk add --no-cache \
    git unzip libpq libpq-dev icu-dev libzip-dev \
    libpng-dev libjpeg-turbo-dev freetype-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install intl pdo pdo_pgsql gd zip opcache exif \
 && docker-php-ext-enable exif

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer

# Définir le dossier de travail
WORKDIR /var/www/symfony

# Copier composer.* pour profiter du cache Docker
COPY composer.json composer.lock ./

# Installer dépendances Composer
RUN composer install --no-dev --optimize-autoloader --working-dir=/var/www/symfony

# Copier le reste du projet
COPY . .

# Permissions Symfony
RUN mkdir -p var vendor \
    && chown -R www-data:www-data var vendor \
    && chmod -R 775 var vendor

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
