#!/bin/bash
set -e

echo "🚀 Démarrage de l'application Symfony sur Render.com..."

# Créer le fichier .env avec les variables d'environnement Render
echo "📝 Création du fichier .env..."
cat > .env << EOF
APP_ENV=$APP_ENV
APP_DEBUG=$APP_DEBUG
APP_SECRET=$APP_SECRET
DATABASE_URL=$DATABASE_URL
EOF

echo "✅ Fichier .env créé"

# Créer les dossiers nécessaires
mkdir -p var/cache var/log var/sessions
chmod -R 775 var 2>/dev/null || true

# Attendre que la base de données soit prête
echo "🔄 Attente de la base de données..."
TRIES=0
until php bin/console dbal:run-sql "SELECT 1" --env=prod --no-debug 2>/dev/null; do
    TRIES=$((TRIES+1))
    if [ "$TRIES" -ge 30 ]; then
        echo "❌ Base de données non accessible après 60s"
        exit 1
    fi
    echo "Tentative $TRIES/30 - en attente de la base de données..."
    sleep 2
done
echo "✅ Base de données accessible"

# Exécuter les migrations
echo "🔄 Exécution des migrations..."
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration --env=prod --no-debug

# Charger les fixtures
echo "🌱 Chargement des fixtures..."
php bin/console doctrine:fixtures:load --no-interaction --append --env=prod --no-debug || true

# Nettoyer et préchauffer le cache
echo "🔥 Nettoyage du cache..."
php bin/console cache:clear --env=prod --no-debug

echo "✅ Application Symfony prête!"

# Si des arguments sont passés, les exécuter
if [ $# -eq 0 ]; then
    # Aucun argument : démarrer le serveur par défaut
    echo "🌐 Démarrage du serveur sur le port $PORT..."
    exec php -S 0.0.0.0:$PORT -t public/
else
    # Des arguments sont passés : les exécuter
    exec "$@"
fi