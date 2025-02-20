SECRETS_DIR = ./secrets
COMPOSE_FILE = srcs/docker-compose.yml
INIT_SCRIPT = ./srcs/init.sh
DATA_DIR = ../../data
ENV_FILE = ./srcs/.env

all: init up

#/dev/null is a special file on linux systems that discards anything written to it
# 2>&1 redirects file descripter 2 (standard error) to FD1 or (stdout) to /dev/null too

#-p flag creates a parent DIR if needed & avoids errors if it exists
make_directories:
	@mkdir -p /home/kbolon/data/mariadb
	@mkdir -p /home/kbolon/data/wordpress
	@mkdir -p "/home/kbolon/Documents/Inception/secrets"
	@mkdir -m 775 secrets

init:
	@echo "Creating .env file..."
	@bash $(INIT_SCRIPT)
	@echo ".env file created successfully!"

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
	@rm -fr $(SECRETS_DIR) || true
	@rm -fr $(DATA_DIR) || true
	@rm -fr $(ENV_FILE) || true

.PHONY: all up down stop restart ps re status clean
