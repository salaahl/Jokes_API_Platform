#!/usr/bin/env bash
set -euo pipefail

cd /var/www/symfony

# Attendre la base de données (optionnel)
TRIES=0
until php bin/console doctrine:query:sql "SELECT 1" --env=prod --no-debug >/dev/null 2>&1; do
  TRIES=$((TRIES+1))
  if [ "$TRIES" -ge 60 ]; then
    echo "❌ Database not reachable"; exit 1
  fi
  sleep 1
done

# Migrations idempotentes
echo "🚀 Running migrations..."
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration --env=prod --no-debug

# Fixtures optionnelles
if [ "${RUN_FIXTURES:-false}" = "true" ]; then
  echo "📦 Loading fixtures..."
  php bin/console doctrine:fixtures:load --no-interaction --append --env=prod --no-debug || true
fi

# Lancer le serveur PHP
exec "$@"
