# Makefile for Docker Compose commands
include .env

# Variables
DOCKER_COMPOSE ?= $(shell command -v docker-compose 2>/dev/null || echo docker compose)  # Allows overriding the docker-compose executable
COMPOSE_FILE := deployment/docker_compose/docker-compose.dev.yaml
PROJECT_NAME := wwi_data_platform
YARN ?= yarn
UV ?= uv

# Docker Compose commands
.PHONY: up down restart build pull logs ps stop start clean deploy help

up:  ## Start services in detached mode
	@echo "Services are starting..."
	@if [ -z "$(SERVICES)" ]; then \
		$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} up -d; \
	else \
		$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} up -d $(SERVICES); \
	fi

down:  ## Stop and remove containers
	@echo "Services are stopping..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} down

pause:  ## Pause services
	@echo "Services are paused..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} pause

unpause:  ## Unpause services
	@echo "Services are unpaused..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} unpause

exec:  ## Run a command in a running container
	@echo "Running command in container..."
	@if [ -z "$(SERVICES)" ]; then \
		echo "Error: SERVICES is not set. Provide it using make exec SERVICES=<one service> [COMMAND=<command>]"; \
		exit 1; \
	else \
		echo "Executing command '$(COMMAND)' in service '$(SERVICES)'..."; \
		$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} exec $(SERVICES) $(COMMAND); \
	fi

restart:  ## Restart all services
	@echo "Services have restarted..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} down
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} up -d --build

build:  ## Build or rebuild services
	@echo "Services are being built..."
	@if [ -z "$(SERVICES)" ]; then \
		$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} build; \
	else \
		$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} build $(SERVICES); \
	fi

logs:  ## Follow logs of running services
	@echo "Tailing logs..."
	@if [ -z "$(SERVICES)" ]; then \
		$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} logs -f; \
	else \
		$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} logs -f $(SERVICES); \
	fi

ps:  ## List containers
	@echo "Listing all services..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} ps -a

status:  ## Show status of services
	@echo "Showing status of services..."
	@if [ -z "$(SERVICES)" ]; then \
		$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} ps; \
	else \
		$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} ps $(SERVICES); \
	fi

stop:  ## Stop services without removing containers
	@echo "Services are stopped..."
	@if [ -z "$(SERVICES)" ]; then \
		$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} stop; \
	else \
		$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} stop $(SERVICES); \
	fi

start:  ## Start stopped services
	@echo "Services are started..."
	@if [ -z "$(SERVICES)" ]; then \
		$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} start; \
	else \
		$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} start $(SERVICES); \
	fi

clean:  ## Stop services and remove containers and volumes
	@echo "Services and volumes have been removed..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} down -v

test:  ## TODO: not completed
	@echo "Running tests..."

shell:  ## Open a shell in a specified service
	@if [ -z "$(SERVICES)" ]; then \
		echo "Error: SERVICES is not set. Provide it using make shell SERVICES=<service>"; \
		exit 1; \
	else \
		echo "Opening a shell in service '$(SERVICES)'..."; \
		$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} exec $(SERVICES) sh; \
	fi

deploy:
	docker run --rm \
  --network wwi_data_platform_data_network \
  -e PREFECT_API_URL=http://prefect-server:4200/api \
  -e PREFECT_LOGGING_LEVEL=DEBUG \
  -v "./pipelines/:/app/pipelines/" \
  -v "./prefect.yaml:/app/prefect.yaml" \
  --platform linux/amd64 \
  wwi_data_platform-prefect-server:latest \
  uv run prefect deploy

help:  ## Show this help
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo
	@echo "Environment variables:"
	@echo "  SERVICES     List of services to start (default: all). E.g SERVICES='api-server web-server'"
	@echo "  COMMAND      Command to execute within a service (default: sh)"

%: ## Prevents make from throwing an error when a target is not found
	@:
