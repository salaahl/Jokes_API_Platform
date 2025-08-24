FROM php:8.3-cli-alpine

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
    libpng-dev \
    bash

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
    && echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files=4000" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.revalidate_freq=2" >> /usr/local/etc/php/conf.d/opcache.ini

# Installer Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/local/bin/composer

# Définir le répertoire de travail (chemin standard Render.com)
WORKDIR /opt/render/project/src

# Copier les fichiers de dépendances
COPY composer.json composer.lock ./

# Installer les dépendances PHP
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Copier tout le code source
COPY . .

# Finaliser l'installation de Composer
RUN composer dump-autoload --classmap-authoritative --no-dev

# Créer les dossiers nécessaires avec les bonnes permissions
RUN mkdir -p var/cache var/log var/sessions \
    && chmod -R 777 var

# Copier et rendre exécutable l'entrypoint
COPY docker-entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 10000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]