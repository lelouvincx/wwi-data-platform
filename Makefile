# Makefile for Docker Compose commands

# Variables
DOCKER_COMPOSE ?= $(shell command -v docker-compose 2>/dev/null || echo docker compose)  # Allows overriding the docker-compose executable
COMPOSE_FILE := deployment/docker_compose/docker-compose.dev.yaml
YARN ?= yarn
UV ?= uv

# Docker Compose commands
.PHONY: up down restart build pull logs ps stop start clean help

up:  ## Start services in detached mode
	@echo "Services are starting..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} up -d

down:  ## Stop and remove containers
	@echo "Services are stopping..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} down

restart:  ## Restart services
	@echo "Services have restarted..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} down
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} up -d

build:  ## Build or rebuild services
	@echo "Services are being built..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} build

pull:  ## Pull service images
	@echo "Pulling images..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} pull

logs:  ## Follow logs of running services
	@echo "Tailing logs..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} logs -f

ps:  ## List containers
	@echo "Listing all services..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} ps -a

stop:  ## Stop services without removing containers
	@echo "Services are stopped..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} stop

start:  ## Start stopped services
	@echo "Services are started..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} start

clean:  ## Stop services and remove containers and volumes
	@echo "Services and volumes have been removed..."
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) -p ${PROJECT_NAME} down -v

help:  ## Show this help
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
