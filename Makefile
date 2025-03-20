#HOME_DIR = "/home/ubuntu"
#SECRETS_DIR = "$(HOME_DIR)/Documents/Inception/secrets"
#DATA_DIR = "$(HOME_DIR)/Documents/Inception/data"

COMPOSE_FILE = srcs/docker-compose.yml
INIT_SCRIPT = ./srcs/init.sh
ENV_FILE = .env

all: init up

init:
	@echo "Creating .env file"
	@/bin/bash $(INIT_SCRIPT)

#DOCKER COMPOSE
up:
	@docker compose -f $(COMPOSE_FILE) up -d --build

down:
	
	@docker compose -f $(COMPOSE_FILE) down

stop:
	@docker compose -f $(COMPOSE_FILE) stop

restart:
	@docker compose -f $(COMPOSE_FILE) stop
	@docker compose -f $(COMPOSE_FILE) up -d

ps:
	@docker compose -f $(COMPOSE_FILE) ps

status:
	@docker images
	@docker ps -a
	@docker network ls
	@docker compose -f $(COMPOSE_FILE) logs

re:
	down clean up

clean:
	@echo "Cleaning"
	@docker compose -f $(COMPOSE_FILE) down --volumes --remove-orphans || echo "compose is not running"
#	@docker rmi $(docker images -q) --force
	@docker system prune -f

.PHONY: all up down stop restart ps re status clean
