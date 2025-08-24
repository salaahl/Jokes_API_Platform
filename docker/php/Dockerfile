FROM php:8.3-fpm-alpine

# Installer dépendances pour PHP et PostgreSQL
RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    zip \
    unzip \
    git \
    libpq \
    libpq-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd pdo pdo_pgsql pgsql exif \
 && docker-php-ext-enable exif

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Définir le dossier de travail
WORKDIR /var/www/html

# Copier le projet Laravel
COPY . .

# Copier le build frontend
COPY --from=node_build /app/public/build /var/www/html/public/build

# Permissions
RUN chown -R www-data:www-data var bootstrap/cache \
    && chmod -R 775 var bootstrap/cache

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php", "-S", "0.0.0.0:80", "-t", "public"]
