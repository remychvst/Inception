
*This activity has been created as part of the 42 curriculum by rchavast.*

# Inception

## Description

Inception is a system administration activity whose goal is to build a small, secure web
infrastructure entirely with Docker, using **Docker Compose** to orchestrate it. Each service
runs in its own dedicated container, built from a custom `Dockerfile`, on the penultimate
stable version of Debian.

The infrastructure is made of three services:

- **NGINX** — the only entry point of the infrastructure, exposed on port 443 and configured
  to accept TLSv1.2 / TLSv1.3 connections only.
- **WordPress + php-fpm** — the WordPress application, installed and configured, served
  through php-fpm (no web server inside this container).
- **MariaDB** — the database used by WordPress, running without nginx.

Two Docker named volumes persist data on the host, under `/home/rchavast/data`:

- one for the WordPress database (MariaDB data),
- one for the WordPress website files.

All three containers communicate through a dedicated Docker bridge network (`inception`) and
restart automatically in case of a crash.

## Instructions

### Requirements

- A virtual machine (Debian-based recommended)
- Docker
- Docker Compose (v2 plugin)
- `make`

### Setup

1. Clone the repository.
2. Add your domain to `/etc/hosts` (or configure your local DNS) so it points to your
   machine's IP address:
   ```
   127.0.0.1   rchavast.42.fr
   ```
3. Fill in the `.env` file located in `srcs/` with your own values (domain name, database
   name, WordPress site title, etc.).
4. Make sure the secret files are present and filled under `secrets/`
   (`db_password.txt`, `db_root_password.txt`, `credentials.txt`,
   `wp_admin_password.txt`, `wp_user_password.txt`). These files are ignored by git and
   must never be committed.

### Build and run

From the root of the repository:

```bash
make
```

This builds the Docker images (`nginx`, `wordpress`, `mariadb`) and starts the containers
in detached mode using `docker-compose.yml`.

### Stop / clean

```bash
make down    # stop and remove containers
make clean   # remove containers, images and networks
make fclean  # also remove volumes and persisted data
make re      # fclean + full rebuild
```

*(adjust the target names above to match your actual Makefile)*

### Access

Once the stack is running, the website is available at:

```
https://rchavast.42.fr
```

The WordPress administration panel is available at:

```
https://rchavast.42.fr/wp-admin
```

## Project description

### Docker usage and sources

Every service is built from its own `Dockerfile` located under
`srcs/requirements/<service>/`. No pre-built image is pulled from Docker Hub (except the
base Debian image, which is explicitly allowed). Configuration files and startup scripts
for each service live in the `conf/` and `tools/` subfolders next to each `Dockerfile`.
The `docker-compose.yml` file, located in `srcs/`, declares the three services, the shared
network, and the two named volumes, and is invoked by the `Makefile` at the root of the
repository.

### Design choices and comparisons

**Virtual Machines vs Docker**
A virtual machine virtualizes an entire operating system (its own kernel, drivers, and full
init system), which makes it heavier to run and slower to start. A Docker container shares
the host's kernel and only isolates processes and the filesystem, which makes it much
lighter, faster to start, and easier to reproduce consistently across machines. This
activity uses Docker (inside a VM, as required) because it lets each service run in an
isolated, minimal, disposable environment without the overhead of a full OS per service.

**Secrets vs Environment Variables**
Environment variables (declared in `.env` and referenced in `docker-compose.yml`) are
convenient for non-sensitive configuration values (domain name, database name, WordPress
title, etc.), but they can leak more easily — they appear in `docker inspect`, in process
listings, and can end up in logs. Docker secrets, on the other hand, are mounted as files
inside the container (typically under `/run/secrets/`) and are never exposed through
environment inspection. For this reason, actual credentials (database passwords, WordPress
admin/user passwords) are stored as files under `secrets/` and read at container startup,
while `.env` is reserved for non-confidential configuration.

**Docker Network vs Host Network**
Using `network_mode: host` would make the containers share the host's network stack
directly, removing the isolation between the container and the host, and risking port
collisions with services already running on the host. A dedicated Docker bridge network
(`inception`), declared in `docker-compose.yml`, keeps the containers isolated from the
host's network while allowing them to communicate with each other through container names
resolved by Docker's internal DNS. Only NGINX's port 443 is exposed to the host, which
keeps WordPress and MariaDB unreachable from the outside.

**Docker Volumes vs Bind Mounts**
A bind mount links a container path directly to an arbitrary path on the host filesystem,
managed entirely outside of Docker. A Docker named volume is managed by Docker itself,
which makes it more portable, easier to back up, and independent of the exact host
directory layout. In this project, named volumes are used for the WordPress files and the
MariaDB database, but configured with the `local` driver's bind options (`type: none`,
`o: bind`, `device: /home/rchavast/data/...`) so that the data physically lives under
`/home/rchavast/data` on the host, as required by the subject, while remaining true Docker
named volumes rather than plain bind mounts declared in the compose file.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [WordPress documentation](https://wordpress.org/documentation/)
- [WP-CLI documentation](https://wp-cli.org/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [Docker secrets documentation](https://docs.docker.com/engine/swarm/secrets/)

### AI usage

AI was used during this project to help clarify Docker/Compose concepts (named volumes vs
bind mounts, PID 1 best practices, TLS configuration for NGINX) and to review the
`docker-compose.yml` and `Dockerfile`s for mistakes. All configuration files, scripts, and
this documentation were written and understood by the author; AI-generated suggestions were
verified, tested, and adapted before being used.
EOF
```
