#!/bin/bash

# Docker Python Framework - Linux Deploy Script
# This script builds and deploys a Python application using Docker

set -e  # Exit on any error

# Configuration
APP_NAME="${APP_NAME:-python-app}"
IMAGE_NAME="${IMAGE_NAME:-${APP_NAME}}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
CONTAINER_NAME="${CONTAINER_NAME:-${APP_NAME}-container}"
PORT="${PORT:-8000}"
HOST_PORT="${HOST_PORT:-${PORT}}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  build     Build the Docker image"
    echo "  run       Run the container"
    echo "  stop      Stop the container"
    echo "  restart   Restart the container"
    echo "  logs      Show container logs"
    echo "  shell     Open shell in container"
    echo "  clean     Remove container and image"
    echo "  deploy    Build and run (default)"
    echo ""
    echo "Environment Variables:"
    echo "  APP_NAME      Application name (default: python-app)"
    echo "  IMAGE_NAME    Docker image name (default: \$APP_NAME)"
    echo "  IMAGE_TAG     Docker image tag (default: latest)"
    echo "  CONTAINER_NAME Container name (default: \$APP_NAME-container)"
    echo "  PORT          Container port (default: 8000)"
    echo "  HOST_PORT     Host port (default: \$PORT)"
    echo ""
    echo "Examples:"
    echo "  $0 deploy"
    echo "  APP_NAME=myapp PORT=3000 $0 build"
    echo "  $0 run"
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        exit 1
    fi
}

check_requirements() {
    if [ ! -f "requirements.txt" ]; then
        log_warning "requirements.txt not found, creating a basic one"
        echo "# Add your Python dependencies here" > requirements.txt
        echo "# Example:" >> requirements.txt
        echo "# flask==2.3.3" >> requirements.txt
        echo "# requests==2.31.0" >> requirements.txt
    fi
}

check_app_directory() {
    if [ ! -d "app" ]; then
        log_warning "app/ directory not found, creating it"
        mkdir -p app
        if [ ! -f "app/main.py" ]; then
            log_warning "app/main.py not found, creating a sample one"
            cat > app/main.py << 'EOF'
#!/usr/bin/env python3
"""
Sample Python application for Docker framework
"""

def main():
    print("Hello from Docker Python Framework!")
    print("This is a sample application.")
    
    # Keep the container running
    try:
        import time
        while True:
            time.sleep(60)
            print("Application is running...")
    except KeyboardInterrupt:
        print("Application stopped.")

if __name__ == "__main__":
    main()
EOF
        fi
    fi
}

build_image() {
    log_info "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
    
    check_requirements
    check_app_directory
    
    docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
    
    if [ $? -eq 0 ]; then
        log_success "Image built successfully: ${IMAGE_NAME}:${IMAGE_TAG}"
    else
        log_error "Failed to build image"
        exit 1
    fi
}

stop_container() {
    if docker ps -q -f name="${CONTAINER_NAME}" | grep -q .; then
        log_info "Stopping container: ${CONTAINER_NAME}"
        docker stop "${CONTAINER_NAME}"
        log_success "Container stopped"
    else
        log_info "Container ${CONTAINER_NAME} is not running"
    fi
}

remove_container() {
    if docker ps -a -q -f name="${CONTAINER_NAME}" | grep -q .; then
        log_info "Removing container: ${CONTAINER_NAME}"
        docker rm "${CONTAINER_NAME}"
        log_success "Container removed"
    fi
}

run_container() {
    # Stop and remove existing container
    stop_container
    remove_container
    
    log_info "Running container: ${CONTAINER_NAME}"
    log_info "Port mapping: ${HOST_PORT}:${PORT}"
    
    docker run -d \
        --name "${CONTAINER_NAME}" \
        -p "${HOST_PORT}:${PORT}" \
        --restart unless-stopped \
        "${IMAGE_NAME}:${IMAGE_TAG}"
    
    if [ $? -eq 0 ]; then
        log_success "Container started successfully"
        log_info "Container name: ${CONTAINER_NAME}"
        log_info "Access your application at: http://localhost:${HOST_PORT}"
    else
        log_error "Failed to start container"
        exit 1
    fi
}

show_logs() {
    if docker ps -q -f name="${CONTAINER_NAME}" | grep -q .; then
        log_info "Showing logs for container: ${CONTAINER_NAME}"
        docker logs -f "${CONTAINER_NAME}"
    else
        log_error "Container ${CONTAINER_NAME} is not running"
        exit 1
    fi
}

open_shell() {
    if docker ps -q -f name="${CONTAINER_NAME}" | grep -q .; then
        log_info "Opening shell in container: ${CONTAINER_NAME}"
        docker exec -it "${CONTAINER_NAME}" /bin/bash
    else
        log_error "Container ${CONTAINER_NAME} is not running"
        exit 1
    fi
}

clean_all() {
    log_info "Cleaning up Docker resources"
    
    # Stop and remove container
    stop_container
    remove_container
    
    # Remove image
    if docker images -q "${IMAGE_NAME}:${IMAGE_TAG}" | grep -q .; then
        log_info "Removing image: ${IMAGE_NAME}:${IMAGE_TAG}"
        docker rmi "${IMAGE_NAME}:${IMAGE_TAG}"
        log_success "Image removed"
    fi
    
    log_success "Cleanup completed"
}

deploy() {
    log_info "Starting deployment process"
    build_image
    run_container
    log_success "Deployment completed successfully!"
}

# Main script logic
check_docker

COMMAND="${1:-deploy}"

case "${COMMAND}" in
    build)
        build_image
        ;;
    run)
        run_container
        ;;
    stop)
        stop_container
        ;;
    restart)
        stop_container
        run_container
        ;;
    logs)
        show_logs
        ;;
    shell)
        open_shell
        ;;
    clean)
        clean_all
        ;;
    deploy)
        deploy
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        log_error "Unknown command: ${COMMAND}"
        show_usage
        exit 1
        ;;
esac

