# Documentation développeur

## Prérequis

Le projet doit être exécuté dans une machine virtuelle Debian.

Les outils nécessaires sont :

- Docker
- Docker Compose
- Git
- Make

Le projet est situé dans le dossier Inception.

## Structure du projet

La structure principale du projet est :

    Inception/
    ├── Makefile
    ├── README.md
    ├── USER_DOC.md
    ├── DEV_DOC.md
    ├── .gitignore
    ├── secrets/
    └── srcs/
        ├── .env
        ├── docker-compose.yml
        └── requirements/
            ├── mariadb/
            ├── nginx/
            └── wordpress/

## Variables d'environnement

Les variables d'environnement sont définies dans :

    srcs/.env

Les mots de passe ne sont pas stockés dans ce fichier.

Les mots de passe sont stockés dans le dossier :

    secrets/

Ce dossier est ignoré par Git.

## Docker Secrets

Les secrets utilisés par les services sont :

    secrets/db_password.txt
    secrets/db_root_password.txt
    secrets/wp_admin_password.txt
    secrets/wp_user_password.txt

Les conteneurs récupèrent ces secrets depuis `/run/secrets/`.

## Docker Compose

La configuration de l'infrastructure se trouve dans :

    srcs/docker-compose.yml

Le fichier définit les trois services :

- mariadb
- wordpress
- nginx

Les services communiquent via un réseau Docker dédié.

Deux volumes Docker sont utilisés pour conserver les données :

- mariadb_data
- wordpress_data

## Construction et lancement

Depuis la racine du projet :

    make

Cette commande construit les images personnalisées et démarre les conteneurs.

Pour construire uniquement les images :

    make build

Pour démarrer les conteneurs sans reconstruire :

    make up

## Gestion des conteneurs

Pour vérifier l'état des conteneurs :

    make ps

Pour afficher les logs :

    make logs

Pour arrêter les conteneurs :

    make down

Pour supprimer les conteneurs, les images et les volumes :

    make fclean

Attention : `make fclean` supprime les volumes et les données persistantes.

## Images Docker

Chaque service possède son propre Dockerfile :

    srcs/requirements/mariadb/Dockerfile
    srcs/requirements/wordpress/Dockerfile
    srcs/requirements/nginx/Dockerfile

Les images sont construites localement et ne reposent pas sur des images de services prêtes à l'emploi.

## MariaDB

MariaDB utilise un script d'initialisation situé dans :

    srcs/requirements/mariadb/tools/init.sh

Le script initialise la base de données, crée l'utilisateur WordPress et configure les permissions.

Les données MariaDB sont persistées dans :

    /home/remy/data/mariadb/

## WordPress

WordPress utilise PHP-FPM.

La configuration PHP-FPM se trouve dans :

    srcs/requirements/wordpress/conf/www.conf

Le script d'initialisation se trouve dans :

    srcs/requirements/wordpress/tools/init.sh

Il attend que MariaDB soit disponible, configure WordPress et crée les utilisateurs nécessaires.

Les fichiers WordPress sont persistés dans :

    /home/remy/data/wordpress/

## NGINX

NGINX est le point d'entrée de l'infrastructure.

Il écoute sur le port HTTPS 443.

Sa configuration se trouve dans :

    srcs/requirements/nginx/conf/nginx.conf

Le certificat TLS est généré lors de l'initialisation du conteneur.

Seuls TLS 1.2 et TLS 1.3 sont autorisés.

NGINX transmet les requêtes PHP à WordPress via PHP-FPM sur le port 9000.

## Réseau Docker

Les trois services utilisent le réseau Docker :

    inception

Les services peuvent communiquer entre eux grâce à leurs noms de conteneurs.

NGINX communique avec WordPress.

WordPress communique avec MariaDB.

MariaDB n'est pas exposé directement sur Internet.

## Persistance des données

Les données sont stockées sous :

    /home/remy/data/

MariaDB utilise :

    /home/remy/data/mariadb/

WordPress utilise :

    /home/remy/data/wordpress/

Les données restent disponibles après l'arrêt et le redémarrage des conteneurs.

La suppression des volumes avec `make fclean` supprime les données persistantes.

## Vérifications utiles

Vérifier les conteneurs :

    docker ps

Vérifier les volumes :

    docker volume ls

Vérifier le réseau :

    docker network ls

Afficher les logs d'un service :

    docker logs mariadb
    docker logs wordpress
    docker logs nginx

Vérifier l'installation WordPress :

    docker exec wordpress wp core is-installed --path=/var/www/html --allow-root

Vérifier le nom du site :

    docker exec wordpress wp option get blogname --path=/var/www/html --allow-root

## Nettoyage et reconstruction

Pour arrêter l'infrastructure :

    make down

Pour reconstruire les images :

    make build

Pour reconstruire et redémarrer l'ensemble :

    make re

La commande `make re` supprime les volumes avant de reconstruire l'infrastructure. Elle doit donc être utilisée uniquement lorsque la suppression des données est souhaitée.