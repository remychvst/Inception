# Documentation utilisateur

## Services

L'infrastructure contient trois services :

- NGINX
- WordPress avec PHP-FPM
- MariaDB

## Démarrer l'infrastructure

Depuis la racine du projet :

    make

Cette commande construit les images Docker et démarre les conteneurs.

## Arrêter l'infrastructure

Pour arrêter les conteneurs :

    make down

Les volumes et les données persistantes sont conservés.

Pour supprimer les conteneurs, les images et les volumes :

    make fclean

Attention : cette commande supprime les volumes Docker et donc les données persistantes.

## Accéder au site

Le site WordPress est accessible à :

https://remy.42.fr

Le site utilise HTTPS sur le port 443.

Le certificat TLS est auto-signé. Le navigateur peut donc afficher un avertissement de sécurité lors de la première connexion.

## Administration WordPress

L'interface d'administration est accessible à :

https://remy.42.fr/wp-admin/

Le nom d'utilisateur administrateur est défini par WP_ADMIN_USER dans srcs/.env.

Le mot de passe administrateur est stocké dans :

    secrets/wp_admin_password.txt

## Utilisateur WordPress

Un utilisateur WordPress standard est créé automatiquement lors de l'initialisation.

Son nom d'utilisateur est défini par WP_USER dans srcs/.env.

Son mot de passe est stocké dans :

    secrets/wp_user_password.txt

## Identifiants MariaDB

Les mots de passe utilisés par MariaDB sont stockés dans :

    secrets/db_password.txt
    secrets/db_root_password.txt

Ces fichiers contiennent des informations sensibles et ne doivent pas être versionnés dans Git.

## Vérifier les services

Pour vérifier l'état des conteneurs :

    make ps

Pour afficher les logs :

    make logs

Il est également possible d'utiliser :

    docker ps

Les trois conteneurs attendus sont :

- mariadb
- wordpress
- nginx

## Persistance des données

Les données persistantes sont stockées sous :

    /home/remy/data/

Les données MariaDB sont stockées dans :

    /home/remy/data/mariadb/

Les fichiers WordPress sont stockés dans :

    /home/remy/data/wordpress/

Les données sont conservées lorsque les conteneurs sont arrêtés avec :

    make down

Elles sont supprimées lorsque les volumes Docker sont supprimés avec :

    make fclean

## Réseau

Les trois services communiquent via le réseau Docker interne du projet.

NGINX est le seul service accessible depuis l'extérieur et écoute sur le port HTTPS 443.

WordPress communique avec MariaDB via le réseau Docker interne.