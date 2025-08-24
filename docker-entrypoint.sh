#!/bin/bash
set -e

echo "🚀 Démarrage Symfony API sur Render.com..."

# Vérifier les variables d'environnement obligatoires
if [ -z "$DATABASE_URL" ]; then
    echo "❌ DATABASE_URL manquante"
    exit 1
fi

# Créer le fichier .env avec les variables d'environnement
echo "📝 Configuration de l'environnement..."
cat > .env << EOF
APP_ENV=${APP_ENV:-prod}
APP_DEBUG=${APP_DEBUG:-0}
APP_SECRET=${APP_SECRET}
DATABASE_URL=${DATABASE_URL}
CORS_ALLOW_ORIGIN=${CORS_ALLOW_ORIGIN:-*}
EOF

echo "✅ Fichier .env créé"

# Créer les dossiers nécessaires avec les bonnes permissions
mkdir -p var/cache var/log var/sessions
chmod -R 777 var

# Attendre que la base de données soit disponible
echo "🔄 Attente de la base de données..."
for i in {1..30}; do
    if php bin/console dbal:run-sql "SELECT 1" --env=prod --no-debug 2>/dev/null; then
        echo "✅ Base de données accessible"
        break
    fi
    echo "Tentative $i/30 - en attente..."
    sleep 2
    if [ $i -eq 30 ]; then
        echo "❌ Timeout - base de données inaccessible après 60s"
        exit 1
    fi
done

# Exécuter les migrations
echo "🔄 Exécution des migrations de base de données..."
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration --env=prod --no-debug

# Charger les fixtures si demandé (utile pour les démos)
if [ "${LOAD_FIXTURES:-false}" = "true" ]; then
    echo "🌱 Chargement des fixtures..."
    php bin/console doctrine:fixtures:load --no-interaction --append --env=prod --no-debug || echo "⚠️ Pas de fixtures à charger"
fi

# Nettoyer et réchauffer le cache
echo "🔥 Optimisation du cache..."
php bin/console cache:clear --env=prod --no-debug 2>/dev/null || true

echo "✅ Application Symfony API prête!"

# Exécuter la commande passée en paramètre ou démarrer le serveur
if [ $# -eq 0 ]; then
    # Aucun argument : démarrer le serveur intégré PHP
    echo "🌐 Démarrage du serveur sur le port ${PORT:-10000}..."
    exec php -S 0.0.0.0:${PORT:-10000} -t public/
else
    # Des arguments sont fournis : les exécuter
    exec "$@"
fi