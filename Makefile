SECRETS_DIR = ./secrets
STACK_NAME = karens
COMPOSE_FILE := srcs/docker-compose.yml

#Initialise Docker Swarm, create secrets, and deploy stack
all: create-secrets volume_directories up

#/dev/null is a special file on linux systems that discards anything written to it
# 2>&1 redirects file descripter 2 (standard error) to FD1 or (stdout) to /dev/null too

#Create Docker Secrets
create-secrets:
	@echo "Creating Docker Secrets"
	@if ! docker secret inspect credentials > /dev/null 2>&1; then \
		docker secret create credentials $(SECRETS_DIR)/credentials.txt; \
	else \
		echo "Secret 'credentials' already exists."; \
	fi

	@if ! docker secret inspect db_password > /dev/null 2>&1; then \
		docker secret create db_password $(SECRETS_DIR)/db_password.txt; \
	else \
		echo "Secret 'db_password' already exists."; \
	fi

	@if ! docker secret inspect db_root_password > /dev/null 2>&1; then \
		docker secret create db_root_password $(SECRETS_DIR)/db_root_password.txt; \
	else \
		echo "Secret 'db_root_password' already exists."; \
	fi

	@if ! docker secret inspect wp_admin_password > /dev/null 2>&1; then \
		docker secret create wp_admin_password $(SECRETS_DIR)/wp_admin_password.txt; \
	else \
		echo "Secret 'wp_admin_password' already exists."; \
	fi
	
	@if ! docker secret inspect wp_user_password > /dev/null 2>&1; then \
		docker secret create wp_user_password $(SECRETS_DIR)/wp_user_password.txt; \
	else \
		echo "Secret 'wp_user_password' already exists."; \
	fi

#volume_directories:
#	@mkdir -p /home/kbolon/data/mariadb
#	@mkdir -p /home/kbolon/data/wordpress

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

delete-secrets:
	@if [-d $(SECRETS_DIR)]; then \
		rm -f $(SECRETS_DIR); \
		echo "Secrets have been deleted"; \
	fi	

re:
	down clean up

clean:
	@echo "Cleaning"
#	@docker stack rm $(STACK_NAME) || echo "Stack is not running"
#stops and removes all containers defined in yaml file and any orphans
	@docker-compose -f $(COMPOSE_FILE) down --volumes --remove-orphans || echo "compose is not running"
#provides a deep clean
	@docker system prune -f volumes

.PHONY: all create-secrets delete-secrets volume_directories up down stop restart ps re clean
