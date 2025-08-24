#!/bin/sh
set -e

SYMFONY_DIR="/var/www/symfony"

# Function to check and fix permissions
fix_permissions() {
    echo "Fixing permissions for $SYMFONY_DIR..."
    
    # Create the directory if it doesn't exist
    if [ ! -d "$SYMFONY_DIR" ]; then
        echo "Creating directory $SYMFONY_DIR..."
        sudo mkdir -p "$SYMFONY_DIR"
    fi
    
    # Set proper ownership and permissions
    sudo chown -R www-data:www-data "$SYMFONY_DIR"
    sudo chmod -R 755 "$SYMFONY_DIR"
    
    # Make specific directories writable
    sudo chmod -R 775 "$SYMFONY_DIR/var" 2>/dev/null || true
    sudo chmod -R 775 "$SYMFONY_DIR/vendor" 2>/dev/null || true
}

# Check if we have write permissions, if not, try to fix them
if [ ! -w "$SYMFONY_DIR" ]; then
    echo "⚠️  Directory $SYMFONY_DIR is not writable, attempting to fix permissions..."
    fix_permissions
fi

cd "$SYMFONY_DIR"

echo "Checking DATABASE_URL..."
if [ -z "$DATABASE_URL" ]; then
  echo "❌ DATABASE_URL is missing."
  exit 1
fi

# Create necessary directories with proper permissions
mkdir -p var vendor
chmod -R 775 var vendor
chown -R www-data:www-data var vendor

# Install Composer if necessary in a writable directory
if ! command -v composer >/dev/null 2>&1; then
  echo "Composer not found. Installing..."
  TMPDIR=/tmp
  php -r "copy('https://getcomposer.org/installer', '$TMPDIR/composer-setup.php');"
  
  # Install composer globally or locally based on permissions
  if [ -w "/usr/local/bin" ]; then
    php "$TMPDIR/composer-setup.php" --install-dir=/usr/local/bin --filename=composer
  else
    php "$TMPDIR/composer-setup.php" --install-dir="$SYMFONY_DIR" --filename=composer
    export PATH="$PATH:$SYMFONY_DIR"
  fi
  
  rm -f "$TMPDIR/composer-setup.php"
fi

echo "✅ Composer installed"

echo "Running composer install..."
composer install --no-dev --optimize-autoloader --working-dir="$SYMFONY_DIR"

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

# Fix final permissions
chmod -R 775 var
chown -R www-data:www-data var

echo "✅ Symfony application setup complete!"

exec "$@"