#!/bin/sh
set -e

SYMFONY_DIR="/var/www/symfony"

echo "Checking DATABASE_URL..."
if [ -z "$DATABASE_URL" ]; then
  echo "❌ DATABASE_URL is missing."
  exit 1
fi

# Ensure we're in the right directory
cd "$SYMFONY_DIR" || {
    echo "❌ Cannot access $SYMFONY_DIR"
    exit 1
}

# Create necessary directories
mkdir -p var vendor
chmod -R 775 var vendor 2>/dev/null || {
    echo "⚠️  Cannot set permissions on var/vendor directories"
}

# Set ownership if possible (will fail silently if not root)
chown -R www-data:www-data var vendor 2>/dev/null || true

# Check if composer is available
if ! command -v composer >/dev/null 2>&1; then
    echo "❌ Composer not found. Please install composer in your Docker image."
    exit 1
fi

echo "✅ Composer found"

echo "Running composer install..."
# Run composer as current user, avoid permission issues
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --working-dir="$SYMFONY_DIR"

# Wait for database
echo "Waiting for database connection..."
TRIES=0
until php bin/console doctrine:query:sql "SELECT 1" --env=prod >/dev/null 2>&1; do
  TRIES=$((TRIES+1))
  if [ "$TRIES" -ge 60 ]; then
    echo "❌ Database not reachable after 60s"
    exit 1
  fi
  echo "Attempt $TRIES/60 - waiting for database..."
  sleep 2
done
echo "✅ Database reachable"

# Run migrations
echo "Running database migrations..."
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration --env=prod --no-debug

# Load fixtures if requested
if [ "${RUN_FIXTURES:-false}" = "true" ]; then
  echo "Loading fixtures..."
  php bin/console doctrine:fixtures:load --no-interaction --append --env=prod --no-debug || true
fi

# Clear cache
echo "Clearing cache..."
php bin/console cache:clear --env=prod --no-debug

# Fix final permissions (will work if running as root)
chmod -R 775 var 2>/dev/null || true
chown -R www-data:www-data var 2>/dev/null || true

echo "✅ Symfony application setup complete!"

exec "$@"