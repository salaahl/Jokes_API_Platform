#!/bin/sh

# Démarrage de PHP-FPM en arrière-plan
php-fpm -D

# Attendre que la base de données soit prête
echo "Attente de la base de données..."
until php bin/console doctrine:query:sql "SELECT 1" > /dev/null 2>&1; do
  echo "Base de données non disponible - attente 2s..."
  sleep 2
done

echo "Base de données disponible !"

# Exécution des migrations
echo "Exécution des migrations..."
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration

# Chargement des fixtures (uniquement si APP_ENV != prod ou si LOAD_FIXTURES=1)
if [ "$APP_ENV" != "prod" ] || [ "$LOAD_FIXTURES" = "1" ]; then
    echo "Chargement des fixtures..."
    php bin/console doctrine:fixtures:load --no-interaction --append || echo "Pas de fixtures à charger"
fi

# Vider le cache
echo "Vidage du cache..."
php bin/console cache:clear --env=prod --no-debug

# Optimisation des autoloads
composer dump-autoload --optimize --classmap-authoritative

# Démarrage de Nginx
echo "Démarrage de Nginx..."
exec nginx -g "daemon off;"
