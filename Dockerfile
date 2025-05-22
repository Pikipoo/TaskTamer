# Use a recent Flutter image with Dart 3.8+
FROM ghcr.io/cirruslabs/flutter:stable

# Install dhttpd for serving web builds
RUN dart pub global activate dhttpd

# Enable desktop support
RUN flutter config --enable-linux-desktop

# Set workdir
WORKDIR /app

# Copy pubspec and lock first for caching
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the app
COPY . .

# Build both Linux desktop and web
RUN flutter build linux || true
RUN flutter build web

# Default: serve the web build
EXPOSE 8080
CMD ["sh", "-c", "dart pub global run dhttpd --path build/web --port 8080 --host 0.0.0.0"]

# To run the Linux desktop app instead, override the CMD:
# docker run --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix tasktamer /app/build/linux/x64/release/bundle/task_tamer
