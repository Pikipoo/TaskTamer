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
  echo "  debug    Run diagnostic checks for display server compatibility"
  echo "  test-display  Run a simple display test in the container"
  echo ""
  echo "Options:"
  echo "  -h, --help    Show this help message"
  echo ""
  echo "Example: $0 web"
}

# Function to check Wayland compatibility
check_wayland_compatibility() {
  echo "Checking Wayland compatibility..."

  # Check if Wayland is running
  if [ "$XDG_SESSION_TYPE" = "wayland" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    echo "✅ Wayland session detected"
  else
    echo "❌ Not running in a Wayland session"
    return 1
  fi

  # Check if XDG_RUNTIME_DIR is set
  if [ -n "$XDG_RUNTIME_DIR" ]; then
    echo "✅ XDG_RUNTIME_DIR is set to $XDG_RUNTIME_DIR"
  else
    echo "❌ XDG_RUNTIME_DIR is not set"
    return 1
  fi

  # Check if WAYLAND_DISPLAY is set
  if [ -n "$WAYLAND_DISPLAY" ]; then
    echo "✅ WAYLAND_DISPLAY is set to $WAYLAND_DISPLAY"
  else
    echo "❌ WAYLAND_DISPLAY is not set"
    export WAYLAND_DISPLAY=wayland-0
    echo "   Setting WAYLAND_DISPLAY to wayland-0"
  fi

  # Check if Wayland socket exists
  if [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
    echo "✅ Wayland socket found at $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
  else
    echo "❌ Wayland socket not found at $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
    return 1
  fi

  # Check if runtime directory exists
  if [ -d "/tmp/runtime-root" ]; then
    echo "✅ Temporary runtime directory exists"
  else
    echo "❌ Temporary runtime directory doesn't exist"
    mkdir -p /tmp/runtime-root
    chmod 0700 /tmp/runtime-root
    echo "   Created /tmp/runtime-root"
  fi

  # Check system graphics capabilities
  echo "Testing graphics capabilities..."
  if command -v glxinfo > /dev/null; then
    glxinfo | grep -i "direct rendering"
    glxinfo | grep -i "OpenGL renderer"
  else
    echo "❌ glxinfo not found. Install mesa-utils package for better diagnostics."
  fi

  echo "Wayland compatibility check complete."
  return 0
}

test_x11_display() {
  echo "Testing X11 display access..."

  # Try running a simple X11 application
  docker run --rm \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $HOME/.Xauthority:/root/.Xauthority \
    --net=host \
    jess/xeyes

  if [ $? -eq 0 ]; then
    echo "✅ X11 display test successful"
    return 0
  else
    echo "❌ X11 display test failed"
    return 1
  fi
}

test_wayland_display() {
  echo "Testing Wayland display access..."

  # Create a test container for Wayland
  docker run --rm \
    -e XDG_RUNTIME_DIR=/tmp/runtime-root \
    -e XDG_SESSION_TYPE=wayland \
    -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
    -e GDK_BACKEND=wayland \
    -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/runtime-root/$WAYLAND_DISPLAY \
    -v /tmp/runtime-root:/tmp/runtime-root \
    --privileged \
    --net=host \
    ubuntu:22.04 bash -c "echo 'Testing Wayland connection' && ls -la /tmp/runtime-root"

  if [ $? -eq 0 ]; then
    echo "✅ Wayland socket access test successful"
    return 0
  else
    echo "❌ Wayland socket access test failed"
    return 1
  fi
}

setup_display_server() {
  # Detect display server type
  SESSION_TYPE="x11"
  if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    SESSION_TYPE="wayland"
  elif [ "$WAYLAND_DISPLAY" != "" ]; then
    SESSION_TYPE="wayland"
  fi

  echo "Detected session type: $SESSION_TYPE"

  # Ensure runtime directories exist
  mkdir -p /tmp/runtime-root
  chmod 0700 /tmp/runtime-root

  if [ "$SESSION_TYPE" = "wayland" ]; then
    echo "Setting up Wayland permissions..."
    # If user ID is not 1000, need to adjust the path
    USER_ID=$(id -u)

    # Create XDG_RUNTIME_DIR if it doesn't exist
    mkdir -p /run/user/$USER_ID
    chmod 0700 /run/user/$USER_ID

    # Check if the Wayland socket exists
    if [ -z "$WAYLAND_DISPLAY" ]; then
      export WAYLAND_DISPLAY=wayland-0
    fi

    echo "Using Wayland display: $WAYLAND_DISPLAY"
    echo "XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"

    # Create directory for Wayland socket
    mkdir -p /tmp

    # Test Wayland access
    if [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
      echo "Wayland socket found at $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
    else
      echo "Warning: Wayland socket not found at $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
    fi
  else
    echo "Setting up X11 permissions..."
    # Set X11 permissions
    xhost +local:root
    xhost +local:docker

    # Show current X11 permissions
    echo "Current X11 permissions:"
    xhost
  fi
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
    setup_display_server

    # Add --no-cache to force rebuild if needed
    #docker compose build --no-cache tasktamer-linux

    # Start in interactive mode to be able to select options
    docker compose run --rm tasktamer-linux
    ;;
  web)
    echo "Building and running TaskTamer Web version..."
    docker compose up --build -d tasktamer-web
    echo "TaskTamer Web version is running at http://localhost:8080"
    ;;
  all)
    echo "Building and running all TaskTamer versions..."
    setup_display_server
    docker compose up --build -d
    echo "TaskTamer Linux version is running."
    echo "TaskTamer Web version is running at http://localhost:8080"
    ;;
  debug)
    echo "Running diagnostic checks..."
    if [ "$XDG_SESSION_TYPE" = "wayland" ] || [ -n "$WAYLAND_DISPLAY" ]; then
      check_wayland_compatibility
    else
      echo "X11 session detected."
      echo "DISPLAY: $DISPLAY"
      xhost
    fi
    echo "Diagnostic checks complete."
    ;;
  test-display)
    echo "Testing display server connection..."
    if [ "$XDG_SESSION_TYPE" = "wayland" ] || [ -n "$WAYLAND_DISPLAY" ]; then
      test_wayland_display
    else
      test_x11_display
    fi
    echo "Display test complete."
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
