#!/bin/bash

set -e

echo "Starting WordPress container..."

echo "Waiting for MariaDB..."

until mariadb \
    -h mariadb \
    -u"${MYSQL_USER}" \
    -p"$(cat /run/secrets/db_password)" \
    "${MYSQL_DATABASE}" \
    -e "SELECT 1;" >/dev/null 2>&1
do
    sleep 1
done

echo "MariaDB is ready."

WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Creating WordPress configuration..."

    wp config create \
        --path="/var/www/html" \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root
fi

if ! wp core is-installed --path="/var/www/html" --allow-root; then
    echo "Installing WordPress..."

    wp core install \
        --path="/var/www/html" \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception WordPress" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
fi

if ! wp user get "${WP_USER}" --path="/var/www/html" --allow-root >/dev/null 2>&1; then
    echo "Creating WordPress user..."

    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=subscriber \
        --user_pass="${WP_USER_PASSWORD}" \
        --path="/var/www/html" \
        --allow-root
fi

mkdir -p /run/php

chown -R www-data:www-data /var/www/html

echo "WordPress files are ready."

exec php-fpm8.2 -F
