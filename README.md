# TaskTamer

TaskTamer is a cross-platform mobile app combining task management with collectible pixel-monsters. Completing real-world tasks feeds, trains, and evolves pixel pets, turning self-organization into a fun, rewarding game.

## Getting Started

This project uses Flutter with the Flame engine for 2D game development.

### Prerequisites

- Flutter SDK (3.8.0+)
- Dart SDK (3.8.0+)
- For Linux: GTK development libraries
- For Chrome: A recent Chrome browser

### Running the App

#### Using VS Code

Two launch configurations are available:

1. **TaskTamer (Linux)** - Runs the app as a native Linux application
2. **TaskTamer (Chrome)** - Runs the app in Chrome browser

To launch:

1. Open the project in VS Code
2. Press F5 or go to Run > Start Debugging
3. Select the desired configuration from the dropdown

#### Using Command Line

For Linux:

```bash
flutter run -d linux
```

For Chrome:

```bash
flutter run -d chrome --web-renderer html
```

## Development

The project follows MVVM/BLoC architecture with a clean folder structure. Key technologies include:

- **State Management:** `flutter_bloc`
- **Dependency Injection:** `get_it`
- **Local Storage:** Hive
- **Notifications:** `flutter_local_notifications`

### Setting Up Development Environment

Run the setup script to configure git hooks and project dependencies:

```bash
dart tool/setup.dart
```

This will install pre-commit hooks that:

- Format your code automatically
- Run the analyzer to check for issues
- Run tests to ensure nothing breaks

### Code Quality and Standards

The project uses:

- `dart format` with a line length of 100 characters
- `dart analyze` with fatal info level set
- Flutter tests for all functionality

Git hooks ensure these checks run before commits and pushes:

- **pre-commit**: Formats code, runs analysis and tests but allows commits even if analysis or tests fail
- **pre-push**: Enforces that all formatting, analysis, and tests pass before pushing

## CI/CD Pipeline

The project uses GitHub Actions for continuous integration and delivery:

- **On Pull Requests:** Code is formatted, analyzed, and tested
- **On Main Branch:** The app is built and an APK is generated

The pipeline workflow can be found in `.github/workflows/flutter_ci.yml`.

## Build

To build release versions:

```bash
# For Linux
flutter build linux --release

# For Web
flutter build web --release
```

Alternatively, use the VS Code tasks:

- `Flutter: Build Linux`
- `Flutter: Build Web`
- `Flutter: Build All`
