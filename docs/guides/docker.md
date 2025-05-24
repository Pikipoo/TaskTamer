# Docker Guide for TaskTamer

This guide provides detailed information about running TaskTamer using Docker containers.

## Overview

TaskTamer includes Docker configurations for both Linux and Web platforms, allowing you to build and run the application without installing Flutter or its dependencies locally. The Docker setup includes:

1. `Dockerfile.linux` - For building and running the Linux desktop version
2. `Dockerfile.web` - For building and running the Web version
3. `docker-compose.yml` - For orchestrating both containers
4. `run-docker.sh` - A convenience script for common Docker operations

Both Dockerfiles are based on the official [Cirrus Labs Flutter Docker image](https://github.com/cirruslabs/docker-images-flutter/pkgs/container/flutter) with the stable channel, which provides a pre-configured Flutter environment.

## Prerequisites

- Docker installed and running on your host system
- Docker Compose installed
- X11 server (for Linux version) with proper permissions set

## Docker Files Explained

### Dockerfile.linux

This Dockerfile:

- Uses the official Cirrus Labs Flutter Docker image with the stable channel
- Installs required GTK development libraries for Linux desktop
- Builds the TaskTamer app for Linux
- Creates a run script to start the application

### Dockerfile.web

This Dockerfile uses a multi-stage build:

1. **Builder Stage**:
   - Uses the official Cirrus Labs Flutter Docker image with the stable channel
   - Builds the TaskTamer app for web

2. **Runtime Stage**:
   - Uses a lightweight Nginx Alpine image
   - Copies the built web application from the builder stage
   - Configures Nginx to serve the Flutter web app
   - Exposes port 80 for web access

### docker-compose.yml

The Docker Compose file defines two services:

1. **tasktamer-linux**:
   - Builds using the Dockerfile.linux file
   - Sets up X11 forwarding to display the GUI
   - Uses host networking for proper display

2. **tasktamer-web**:
   - Builds using the Dockerfile.web file
   - Maps port 8080 on the host to port 80 in the container
   - Serves the web application via Nginx

## Using the Docker Setup

### Using the Run Script

The `run-docker.sh` script provides a simplified interface for common Docker operations:

```bash
# Make the script executable (first time only)
chmod +x run-docker.sh

# Show help
./run-docker.sh --help

# Run the Linux version
./run-docker.sh linux

# Run the web version
./run-docker.sh web

# Run both versions
./run-docker.sh all

# Stop all containers
./run-docker.sh stop

# Clean up Docker resources
./run-docker.sh clean
```

### Using Docker Compose Directly

If you prefer to use Docker Compose commands directly:

```bash
# Build and run the web version
docker compose up --build -d tasktamer-web

# Build and run the Linux version
xhost +local:docker  # Allow Docker containers to use X11
docker compose up --build -d tasktamer-linux

# Run both versions
docker compose up --build -d

# View logs
docker compose logs -f

# Stop all containers
docker compose down
```

## X11 Forwarding for Linux Version

The Linux version requires X11 forwarding to display the application window on your host system. The Docker configuration handles this by:

1. Mounting the X11 socket (`/tmp/.X11-unix`)
2. Setting the DISPLAY environment variable
3. Sharing the Xauthority file for authentication

Before running the Linux container, make sure to allow X11 connections from Docker:

```bash
xhost +local:docker
```

## Accessing the Applications

- **Linux Version**: The application window should appear on your desktop automatically when the container starts.
- **Web Version**: Access the application by opening `http://localhost:8080` in your web browser.

## Troubleshooting

### Linux Version Issues

If the Linux application window doesn't appear:

1. Check X11 permissions:

   ```bash
   xhost +local:docker
   ```

2. Verify the container is running:

   ```bash
   docker ps
   ```

3. Check container logs:

   ```bash
   docker compose logs tasktamer-linux
   ```

### Web Version Issues

If the web application doesn't load:

1. Verify the container is running:

   ```bash
   docker ps
   ```

2. Check if the port is correctly mapped:

   ```bash
   docker compose ps
   ```

3. Check container logs:

   ```bash
   docker compose logs tasktamer-web
   ```

4. Try accessing with a different browser or in an incognito window

## Custom Configurations

### Changing the Web Port

To change the port for the web version, edit the `docker-compose.yml` file:

```yaml
tasktamer-web:
  # ...
  ports:
    - "YOUR_DESIRED_PORT:80"
```

### Persistent Storage

If you want to persist data between container runs, you can add volumes to the `docker-compose.yml` file:

```yaml
tasktamer-linux:
  # ...
  volumes:
    # ... existing volumes ...
    - ./data:/app/data

tasktamer-web:
  # ...
  volumes:
    - ./data:/usr/share/nginx/html/data
```

## Conclusion

Using Docker provides a consistent environment for running TaskTamer without worrying about dependency conflicts or Flutter installation issues. The provided configurations make it easy to run the application on both Linux and Web platforms. By leveraging the Cirrus Labs Flutter Docker image, we ensure that the Flutter environment is correctly set up and maintained.
