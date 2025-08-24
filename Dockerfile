FROM php:8.3-fpm-alpine

# Installer les dépendances système
RUN apk add --no-cache \
    git \
    unzip \
    postgresql-dev \
    icu-dev \
    zip \
    libzip-dev \
    oniguruma-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev

# Installer les extensions PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo \
        pdo_pgsql \
        intl \
        zip \
        mbstring \
        gd \
        opcache

# Configuration d'OPcache pour la production
RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.enable_cli=0" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files=4000" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.revalidate_freq=2" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.fast_shutdown=1" >> /usr/local/etc/php/conf.d/opcache.ini

# Installer Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/local/bin/composer

# Créer le répertoire de travail avec les bonnes permissions
RUN mkdir -p /var/www/symfony && \
    addgroup -g 1000 www && \
    adduser -D -s /bin/sh -u 1000 -G www www && \
    chown -R www:www /var/www/symfony

WORKDIR /var/www/symfony

# Copier les fichiers de dépendances d'abord (pour le cache Docker)
COPY --chown=www:www composer.json composer.lock ./

# Installer les dépendances
USER www
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Copier le reste du code source
COPY --chown=www:www . .

# Finaliser l'installation
RUN composer dump-autoload --classmap-authoritative --no-dev

# Créer les dossiers nécessaires
RUN mkdir -p var/cache var/log var/sessions && \
    chmod -R 775 var

# Revenir en root pour l'entrypoint
USER root

# Copier et rendre exécutable l'entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Port exposé
EXPOSE 8000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public/"]