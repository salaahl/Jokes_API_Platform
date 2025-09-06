#!/bin/sh

echo "DATABASE_URL=${DATABASE_URL}"

# Tester la connexion Doctrine
echo "Testing DB connection via Doctrine..."
if php bin/console doctrine:query:sql "SELECT 1" > /dev/null 2>&1; then
  echo "Doctrine connection OK"
else
  echo "Doctrine connection FAILED"
  exit 1
fi

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
php bin/console cache:clear --env=prod --no-debug
composer dump-autoload --optimize --classmap-authoritative

# Démarrage de PHP-FPM et Nginx
php-fpm -D
exec nginx -g "daemon off;"
