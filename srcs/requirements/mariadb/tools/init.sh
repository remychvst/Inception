#!/bin/bash

set -e

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ ! -f "/var/lib/mysql/.inception_initialized" ]; then

    if [ ! -d "/var/lib/mysql/mysql" ]; then
        mariadb-install-db \
            --user=mysql \
            --datadir=/var/lib/mysql \
            --auth-root-authentication-method=normal
    fi

    mariadbd \
        --user=mysql \
        --datadir=/var/lib/mysql \
        --skip-networking &

    MYSQL_PID=$!

    until mariadb -uroot -e "SELECT 1;" >/dev/null 2>&1; do
        sleep 1
    done

mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    mariadb-admin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait $MYSQL_PID
    touch /var/lib/mysql/.inception_initialized
fi

exec mariadbd --user=mysql --bind-address=0.0.0.0