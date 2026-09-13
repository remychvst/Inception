NAME = inception
COMPOSE = docker compose -f srcs/docker-compose.yml

all:
	$(COMPOSE) up -d --build

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down --rmi all

fclean:
	$(COMPOSE) down --rmi all --volumes

re: fclean all

logs:
	$(COMPOSE) logs

ps:
	$(COMPOSE) ps
