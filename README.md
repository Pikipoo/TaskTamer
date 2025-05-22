# TaskTamer

[![CI](https://github.com/pikipoo/TaskTamer/actions/workflows/test.yml/badge.svg)](https://github.com/pikipoo/TaskTamer/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-ready-blue?logo=docker)](https://hub.docker.com/r/pikipoo/tasktamer)

A cross-platform Flutter app for self-organization, inspired by Finch and Pokémon, with pixel art, gamification, and persistent task management.

## Features
- Collectible creatures and gamified self-organization
- Persistent tasks and XP (using Hive)
- Task creation, editing, deletion, and completion
- Repeat schedules and times-per-day logic
- Local notifications (Android, iOS, Linux, macOS)
- XP rewards for task completion, shown on the home screen
- Pixel art-ready UI
- Full test suite (unit and integration)
- GitHub Actions CI pipeline for regression testing

## Getting Started
1. Install [Flutter](https://flutter.dev/docs/get-started/install)
2. Run `flutter pub get`
3. Run the app: `flutter run`

## Running with Docker
1. Build the Docker image:
   ```sh
   docker build -t tasktamer .
   ```
2. **Run the web app (default):**
   ```sh
   docker run --rm -p 8080:8080 tasktamer
   ```
   Then open [http://localhost:8080](http://localhost:8080) in your browser.
3. **Run the Linux desktop app:**
   ```sh
   docker run --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix tasktamer /app/build/linux/x64/release/bundle/task_tamer
   ```
   (Requires X11 forwarding for GUI)

## Testing
- Run all tests: `flutter test`
- Tests cover:
  - Task model (creation, editing, completion, notifications, Hive persistence)
  - Tasks screen (UI, add/edit/delete, XP, times per day)
- CI: All tests run automatically on push and pull request via GitHub Actions

## Notifications
- Local notifications are supported on Android, iOS, Linux, and macOS
- Not supported on web

## Persistence
- Tasks and XP are saved using Hive and restored on app launch

## Contributing
- Pull requests and issues are welcome!

---
MIT License
