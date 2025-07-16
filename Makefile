# Socket MCP Makefile
.PHONY: help build up down logs shell test clean health dev prod

# Default target
help:
	@echo "Socket MCP Docker Management"
	@echo "============================"
	@echo "make build    - Build Docker image"
	@echo "make up       - Start services"
	@echo "make down     - Stop services"
	@echo "make logs     - View logs"
	@echo "make shell    - Enter container shell"
	@echo "make test     - Run tests"
	@echo "make clean    - Clean up containers and images"
	@echo "make health   - Check service health"
	@echo "make dev      - Start in development mode"
	@echo "make prod     - Start in production mode"

# Build Docker image
build:
	docker-compose build --no-cache

# Start services
up:
	docker-compose up -d

# Stop services
down:
	docker-compose down

# View logs
logs:
	docker-compose logs -f socket-mcp

# Enter container shell
shell:
	docker-compose exec socket-mcp sh

# Run tests
test:
	@echo "Testing Socket MCP..."
	@docker-compose up -d
	@sleep 5
	@echo "Checking health endpoint..."
	@curl -f http://localhost:3000/health || (echo "Health check failed" && exit 1)
	@echo "Health check passed!"
	@docker-compose down

# Clean up
clean:
	docker-compose down -v
	docker image prune -f
	docker container prune -f

# Check health
health:
	@curl -s http://localhost:3000/health | jq '.' || echo "Service not running"

# Development mode (with live logs)
dev:
	docker-compose up

# Production mode (detached)
prod:
	docker-compose up -d
	@echo "Socket MCP started in production mode"
	@echo "View logs with: make logs"
	@echo "Check health with: make health"

# Additional utility targets
restart: down up

rebuild: down build up

status:
	@docker-compose ps
