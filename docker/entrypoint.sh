#!/bin/sh
set -e

cd /var/www/symfony

echo "Checking DATABASE_URL..."
if [ -z "$DATABASE_URL" ]; then
  echo "❌ DATABASE_URL is missing."
  exit 1
fi

# Créer les dossiers nécessaires et permissions
mkdir -p var vendor
chmod -R 775 var vendor
chown -R www-data:www-data var vendor

# Installer Composer si nécessaire dans un dossier writable
if ! command -v composer >/dev/null 2>&1; then
  echo "Composer not found. Installing..."
  TMPDIR=/tmp
  php -r "copy('https://getcomposer.org/installer', '$TMPDIR/composer-setup.php');"
  php $TMPDIR/composer-setup.php --install-dir=/var/www/symfony --filename=composer
  rm -f $TMPDIR/composer-setup.php
fi
export PATH="$PATH:/var/www/symfony"

echo "✅ Composer installed"

echo "Running composer install..."
composer install --no-dev --optimize-autoloader --working-dir=/var/www/symfony

# Attendre la base de données
TRIES=0
until php bin/console doctrine:query:sql "SELECT 1" --env=prod >/dev/null 2>&1; do
  TRIES=$((TRIES+1))
  if [ "$TRIES" -ge 60 ]; then
    echo "❌ Database not reachable after 60s"
    exit 1
  fi
  sleep 2
done
echo "✅ Database reachable"

# Migrations
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration --env=prod --no-debug

# Fixtures optionnelles
if [ "${RUN_FIXTURES:-false}" = "true" ]; then
  echo "Loading fixtures..."
  php bin/console doctrine:fixtures:load --no-interaction --append --env=prod --no-debug || true
fi

# Cache
php bin/console cache:clear --env=prod --no-debug

exec "$@"
