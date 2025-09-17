COMPOSE_FILE = "srcs/docker-compose.yml"

all:
	@docker compose -f $(COMPOSE_FILE) up --build -d

down:
	@docker compose -f $(COMPOSE_FILE) down

clean:
	@docker compose -f $(COMPOSE_FILE) down --volumes

fclean: clean
	@docker compose -f $(COMPOSE_FILE) down --rmi all

re: fclean all

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

.PHONY: all down clean fclean re logs
