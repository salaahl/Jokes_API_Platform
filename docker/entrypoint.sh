#!/bin/sh
set -e

cd /var/www/symfony

echo "Checking DATABASE_URL..."
if [ -z "$DATABASE_URL" ]; then
  echo "❌ DATABASE_URL is missing."
  exit 1
fi

# S'assurer que var/ et vendor/ sont accessibles
mkdir -p var vendor
chmod -R 775 var vendor
chown -R www-data:www-data var vendor

echo "Running migrations..."
TRIES=0
until php bin/console doctrine:query:sql "SELECT 1" --env=prod >/dev/null 2>&1; do
  TRIES=$((TRIES+1))
  if [ "$TRIES" -ge 60 ]; then
    echo "❌ Database not reachable after 60s"; exit 1
  fi
  echo "⏳ Waiting for database..."
  sleep 2
done

php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration --env=prod --no-debug

if [ "${RUN_FIXTURES:-false}" = "true" ]; then
  echo "Loading fixtures..."
  php bin/console doctrine:fixtures:load --no-interaction --append --env=prod --no-debug || true
fi

echo "Clearing Symfony cache..."
php bin/console cache:clear --env=prod --no-debug

echo "✅ Deployment completed successfully!"

exec "$@"
