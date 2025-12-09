COMPOSE_FILE = "srcs/docker-compose.yml"
DATA_PATH = /home/$(USER)/data
SETUP_SCRIPT = srcs/setup.sh

all: requirements
	@mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mysql
	@docker compose -f $(COMPOSE_FILE) up --build -d

requirements:
	@mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mysql
	@# Check if script exists and run it; otherwise warn (or fail)
	@if [ -f $(SETUP_SCRIPT) ]; then \
		bash $(SETUP_SCRIPT); \
	else \
		echo "Warning: setup.sh not found. Skipping secret generation."; \
	fi

down:
	@docker compose -f $(COMPOSE_FILE) down

clean:
	@docker compose -f $(COMPOSE_FILE) down --volumes
	@sudo rm -rf $(DATA_PATH)/wordpress
	@sudo rm -rf $(DATA_PATH)/mysql

fclean: clean
	@docker compose -f $(COMPOSE_FILE) down --rmi all
	@docker network prune --force
	@docker volume prune --force
	@rm -rf secrets/

re: fclean all

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

.PHONY: all down clean fclean re logs
