#!/bin/bash

# Script to run TaskTamer in Docker containers
# This script provides an easy way to build and run TaskTamer in Docker

show_help() {
  echo "TaskTamer Docker Runner"
  echo ""
  echo "Usage: $0 [options] [command]"
  echo ""
  echo "Commands:"
  echo "  linux    Build and run the Linux version of TaskTamer"
  echo "  web      Build and run the Web version of TaskTamer"
  echo "  all      Build and run both versions"
  echo "  stop     Stop all running containers"
  echo "  clean    Remove all containers and images"
  echo ""
  echo "Options:"
  echo "  -h, --help    Show this help message"
  echo ""
  echo "Example: $0 web"
}

# If no arguments provided, show help
if [ $# -eq 0 ]; then
  show_help
  exit 1
fi

# Parse command line arguments
case "$1" in
  -h|--help)
    show_help
    exit 0
    ;;
  linux)
    echo "Building and running TaskTamer Linux version..."
    xhost +local:docker
    docker compose up --build -d tasktamer-linux
    echo "TaskTamer Linux version is running."
    echo "You should see the application window appear shortly."
    ;;
  web)
    echo "Building and running TaskTamer Web version..."
    docker compose up --build -d tasktamer-web
    echo "TaskTamer Web version is running at http://localhost:8080"
    ;;
  all)
    echo "Building and running all TaskTamer versions..."
    xhost +local:docker
    docker compose up --build -d
    echo "TaskTamer Linux version is running."
    echo "TaskTamer Web version is running at http://localhost:8080"
    ;;
  stop)
    echo "Stopping all TaskTamer containers..."
    docker compose down
    echo "All containers stopped."
    ;;
  clean)
    echo "Cleaning up TaskTamer Docker resources..."
    docker compose down
    docker rmi tasktamer-linux tasktamer-web
    echo "Cleanup complete."
    ;;
  *)
    echo "Unknown command: $1"
    show_help
    exit 1
    ;;
esac

exit 0
