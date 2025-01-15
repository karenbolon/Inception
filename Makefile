SECRETS_DIR = ./secrets/
#BUILD_PATH = ./srcs/requirements/nginx
COMPOSE_FILE = ./srcs/docker-compose.yml
#INIT_SCRIPT = ./srcs/init.sh

#build:
#removes any secret directory if exists and creates a new one
#	rm -rf $(BUILD_PATH)/secrets/
#	mkdir -p $(BUILD_PATH)/secrets/

#copy .key and .crt files (ssl)
#	cp $(SECRETS_DIR)/nginx_cert.key $(BUILD_PATH)/secrets/
#	cp $(SECRETS_DIR)/nginx_cert.crt $(BUILD_PATH)/secrets/

#build and run the container
#	docker compose -f $(COMPOSE_FILE) up -d --build
#	rm -rf $(BUILD_PATH)/secrets

all: up

#/dev/null is a special file on linux systems that discards anything written to it
# 2>&1 redirects file descripter 2 (standard error) to FD1 or (stdout) to /dev/null too

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

re:
	down clean up

clean:
	@echo "Cleaning"
#stops and removes all containers defined in yaml file and any orphans
	@docker-compose -f $(COMPOSE_FILE) down --volumes --remove-orphans || echo "compose is not running"
#provides a deep clean
	@docker system prune -f --volumes

.PHONY: all up down stop restart ps re clean
