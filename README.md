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
