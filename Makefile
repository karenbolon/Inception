#Linux:
#SECRETS_DIR = "/home/kbolon/Documents/Inception/secrets"
#DATA_DIR = "/home/kbolon/data"
#MACOS:
SECRETS_DIR = "/Users/karenbolon/Documents/Inception/secrets"
DATA_DIR = "/Users/karenbolon/data"

COMPOSE_FILE = srcs/docker-compose.yml
INIT_SCRIPT = ./srcs/init.sh
ENV_FILE = ./srcs/.env

all: init up

init:
	@echo "Creating .env file..."
	@bash $(INIT_SCRIPT)

#Docker compose
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
#	@if [ ! -f $(ENV_FILE) ]; then touch $(ENV_FILE); fi
	@docker compose -f $(COMPOSE_FILE) logs

re:
	down clean up

clean:
	@echo "Cleaning"
	@docker compose -f $(COMPOSE_FILE) down --volumes --remove-orphans || echo "compose is not running"
	@docker system prune -f volumes
#	|| prevents errors in makefile, means execute RH CMD if LH CMD fails
#	@rm -fr $(SECRETS_DIR) || true
#	@rm -fr $(DATA_DIR) || true
#	@rm -fr $(ENV_FILE) || true

.PHONY: all up down stop restart ps re status clean
