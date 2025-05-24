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

## X11 and Wayland Support

The Linux version supports both X11 and Wayland display servers. The Docker configuration detects your display server type and sets up the appropriate environment:

### X11 Configuration

If you're using X11, the Docker configuration handles this by:

1. Mounting the X11 socket (`/tmp/.X11-unix`)
2. Setting the DISPLAY environment variable
3. Sharing the Xauthority file for authentication
4. Setting up IPC namespace sharing with `ipc: host`
5. Setting up a shared runtime directory with `XDG_RUNTIME_DIR`
6. Using the `privileged` flag to allow access to system devices

Before running the Linux container, the `run-docker.sh` script automatically sets up X11 permissions with:

```bash
# Allow X11 connections from root and Docker
xhost +local:root
xhost +local:docker
```

### Wayland Configuration

If you're using Wayland, the Docker configuration handles this by:

1. Setting up Wayland-specific environment variables:
   - `XDG_SESSION_TYPE=wayland`
   - `WAYLAND_DISPLAY=${WAYLAND_DISPLAY}`
   - `GDK_BACKEND=wayland,x11` (fallback to X11 if needed)
2. Mounting the Wayland socket from your host to the container
3. Installing necessary Wayland libraries in the container
4. Using software rendering with `LIBGL_ALWAYS_SOFTWARE=1`

## Troubleshooting Display Issues

### Black Screen Issues

If you see a black screen in the application window:

1. Try forcing a rebuild of the container:

   ```bash
   docker compose build --no-cache tasktamer-linux
   ./run-docker.sh linux
   ```

2. Check if you're running Wayland or X11:

   ```bash
   echo $XDG_SESSION_TYPE
   ```

3. If using Wayland, ensure the socket is properly mounted:

   ```bash
   ls -la $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY
   docker compose exec tasktamer-linux ls -la /tmp/$WAYLAND_DISPLAY
   ```

4. Try running with `LIBGL_ALWAYS_SOFTWARE=1` explicitly:

   ```bash
   LIBGL_ALWAYS_SOFTWARE=1 ./run-docker.sh linux
   ```

5. Check for graphics driver issues by examining the container logs:

   ```bash
   docker compose logs tasktamer-linux
   ```

### X11-specific Troubleshooting

If the Linux application window doesn't appear when using X11:

1. Manually set X11 permissions:

   ```bash
   xhost +local:root
   xhost +local:docker
   ```

2. Check if the DISPLAY environment variable is set correctly:

   ```bash
   echo $DISPLAY
   ```

   It should typically be `:0` or similar. Make sure it matches what's in the container:

   ```bash
   docker compose exec tasktamer-linux echo $DISPLAY
   ```

3. Ensure the X11 socket is mounted correctly:

   ```bash
   ls -la /tmp/.X11-unix
   docker compose exec tasktamer-linux ls -la /tmp/.X11-unix
   ```

4. Check the container logs for error messages:

   ```bash
   docker compose logs tasktamer-linux
   ```

5. Try running the container with a simple X11 test application:

   ```bash
   docker run --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix ubuntu:22.04 apt-get update && apt-get install -y x11-apps && xeyes
   ```

6. Check if your system has any firewall or SELinux rules blocking X11 connections:

   ```bash
   # For systems with firewalld
   sudo firewall-cmd --list-all

   # For systems with SELinux
   sudo getenforce
   ```

7. If using Wayland instead of X11, try switching to X11 or use additional Wayland configurations.

### Wayland-specific Troubleshooting

If you're having issues with Wayland:

1. Make sure the Wayland socket exists and is accessible:

   ```bash
   ls -la $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY
   ```

2. Check if the Flutter app has the necessary Wayland dependencies:

   ```bash
   docker compose exec tasktamer-linux ldd /app/build/linux/x64/release/bundle/task_tamer | grep wayland
   ```

3. Try falling back to X11 mode even on Wayland by setting:

   ```bash
   docker compose exec tasktamer-linux export GDK_BACKEND=x11
   ```

4. Check if your Wayland compositor is compatible (some like Weston or GNOME Wayland work better than others)

5. For NVIDIA GPUs, you may need additional configurations for Wayland support

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

4. For display rendering issues on Wayland:

   The application is configured to work with both X11 and Wayland display servers. If you're using Wayland (which is the default on many modern Linux distributions), the Docker configuration automatically sets up Wayland socket forwarding and enables software rendering with:

   ```
   LIBGL_ALWAYS_SOFTWARE=1
   FLUTTER_ENABLE_SOFTWARE_RENDERING=true
   ```

5. For notification service issues:

   The Linux version of the application currently disables notification services to ensure compatibility in the Docker environment. This is a temporary solution to avoid initialization errors when running in a container.

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
