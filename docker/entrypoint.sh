#!/usr/bin/env bash
set -euo pipefail

cd /var/www/symfony

# Extraire hostname et port de DATABASE_URL
DB_URL=${DATABASE_URL}
DB_HOST=$(echo $DB_URL | sed -E 's/.*@([^:/]+).*/\1/')
DB_PORT=$(echo $DB_URL | sed -E 's/.*:([0-9]+)\?.*/\1/')

# Attendre que la DB soit prête
echo "⏳ Waiting for database $DB_HOST:$DB_PORT ..."
TRIES=0
until pg_isready -h "$DB_HOST" -p "$DB_PORT" >/dev/null 2>&1; do
  TRIES=$((TRIES+1))
  if [ "$TRIES" -ge 60 ]; then
    echo "❌ Database not reachable after 60s"; exit 1
  fi
  sleep 1
done
echo "✅ Database is up."

# Migrations
echo "🚀 Running migrations..."
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration --env=prod --no-debug

# Fixtures optionnelles
if [ "${RUN_FIXTURES:-false}" = "true" ]; then
  echo "📦 Loading fixtures..."
  php bin/console doctrine:fixtures:load --no-interaction --append --env=prod --no-debug || true
fi

# Lancer le serveur PHP
echo "✅ Starting server..."
exec "$@"
