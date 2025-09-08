#!/bin/sh
set -e

# Debug
echo "Debug des variables d'environnement..."
echo "APP_ENV=$APP_ENV"
echo "DATABASE_URL=$DATABASE_URL"

# Vider et précompiler le cache en production
if [ "$APP_ENV" = "prod" ]; then
  echo "Clearing Symfony cache..."
  php bin/console cache:clear --no-warmup
fi

echo "Warming up Symfony cache..."
php bin/console cache:warmup 

# Installer les assets dans public/
echo "Installing assets..."
php bin/console assets:install public --no-interaction

# Test Doctrine
php bin/console doctrine:query:sql "SELECT 1"
echo "Doctrine connection OK"

# Tester la connexion psql
echo "Testing DB connection via psql..."
if psql "$DATABASE_URL" -c "SELECT 1" > /dev/null 2>&1; then
  echo "psql connection OK"
else
  echo "psql connection FAILED"
  exit 1
fi

# Exécuter les migrations
echo "Exécution des migrations..."
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration

# Chargement des fixtures optionnel
if [ "$APP_ENV" != "prod" ] || [ "$LOAD_FIXTURES" = "1" ]; then
  echo "Chargement des fixtures..."
  php bin/console doctrine:fixtures:load --no-interaction --append || echo "Pas de fixtures à charger"
fi

# Vider le cache et optimiser
php bin/console cache:clear  --no-debug
composer dump-autoload --optimize --classmap-authoritative

# Démarrage de PHP-FPM et Nginx
php-fpm -D
exec nginx -g "daemon off;"
