#!/bin/sh
set -e

# Passer temporairement à root pour installer Composer
USER root

cd /var/www/symfony

# Installer Composer si nécessaire
if ! command -v composer >/dev/null 2>&1; then
  echo "Composer not found. Installing..."
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
fi

# Vérifier que Composer est bien installé
composer --version

# Permissions
mkdir -p var vendor
chmod -R 775 var vendor
chown -R www-data:www-data var vendor

# Attendre la base
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

# Passer à www-data pour exécution sécurisée
USER www-data

# Installer dépendances PHP si besoin
composer install --no-dev --optimize-autoloader --working-dir=/var/www/symfony

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
