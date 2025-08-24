#!/usr/bin/env bash
set -euo pipefail

cd /var/www/symfony

# Attendre que la DB soit prête en utilisant Doctrine (supporte SSL)
TRIES=0
until php bin/console doctrine:query:sql "SELECT 1" --env=prod >/dev/null 2>&1; do
  TRIES=$((TRIES+1))
  if [ "$TRIES" -ge 60 ]; then
    echo "❌ Database not reachable after 60s"; exit 1
  fi
  echo "⏳ Waiting for database..."
  sleep 2
done
echo "✅ Database is up."

# Lancer les migrations idempotentes
echo "🚀 Running migrations..."
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration --env=prod --no-debug

# Charger les fixtures optionnelles
if [ "${RUN_FIXTURES:-false}" = "true" ]; then
  echo "📦 Loading fixtures..."
  php bin/console doctrine:fixtures:load --no-interaction --append --env=prod --no-debug || true
fi

# Lancer le serveur PHP
echo "✅ Starting server..."
exec "$@"
