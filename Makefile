COMPOSE_FILE = "srcs/docker-compose.yml"
DATA_PATH = /home/$(USER)/data

all:
	@mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mysql
	@docker compose -f $(COMPOSE_FILE) up --build -d

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

re: fclean all

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

.PHONY: all down clean fclean re logs
