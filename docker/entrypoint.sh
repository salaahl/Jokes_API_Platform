#!/bin/sh
set -e

echo "Checking required environment variables..."
if [ -z "$DATABASE_URL" ]; then
  echo "❌ DATABASE_URL is missing. Please check your environment variables."
  exit 1
fi

echo "Running composer install..."
composer install --no-dev --optimize-autoloader --working-dir=/var/www/symfony || { echo "Composer install failed"; exit 1; }

echo "Testing database connection..."
php -r "
try {
  \$pdo = new PDO(getenv('DATABASE_URL'));
  echo 'Database connection OK\n';
} catch (Exception \$e) {
  echo 'Database connection failed: ' . \$e->getMessage() . '\n';
  exit(1);
}"

echo "Running Symfony migrations..."
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration --env=prod --no-debug

if [ "${RUN_FIXTURES:-false}" = "true" ]; then
  echo "Loading fixtures..."
  php bin/console doctrine:fixtures:load --no-interaction --append --env=prod --no-debug || true
fi

echo "Clearing Symfony cache..."
php bin/console cache:clear --env=prod --no-debug

echo "✅ Deployment completed successfully!"

exec "$@"
