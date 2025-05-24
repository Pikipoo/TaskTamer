# TaskTamer - Comprehensive Documentation

This document provides detailed documentation for the TaskTamer application, covering architecture, design patterns, code organization, and implementation details.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Tech Stack](#tech-stack)
4. [Dependencies](#dependencies)
5. [Design Patterns](#design-patterns)
6. [Folder Structure](#folder-structure)
7. [Core Components](#core-components)
8. [Data Models](#data-models)
9. [Repositories](#repositories)
10. [State Management](#state-management)
11. [UI Components](#ui-components)
12. [Game Mechanics](#game-mechanics)
13. [Testing Strategy](#testing-strategy)
14. [Build and Deployment](#build-and-deployment)
15. [Contributing Guidelines](#contributing-guidelines)

## Project Overview

TaskTamer is a self-care app that combines task management with collectible pixel-monsters. The app helps users promote self-organization through gameplay, driving motivation with collectible progression, and delivering a strong pixel-art identity.

The application allows users to:

- Create and manage tasks with due dates and repeat schedules
- Receive notifications for upcoming tasks
- Complete tasks to earn experience points
- Feed and evolve digital pets/creatures with earned points
- Collect different creature species and evolutions

## Architecture

TaskTamer follows a clean architecture approach with separation of concerns:

1. **Presentation Layer**: UI components and BLoC state management
2. **Domain Layer**: Business logic and models
3. **Data Layer**: Repositories and external services

The application uses a unidirectional data flow where:

- User interactions trigger Events
- BLoCs process Events and emit States
- UI reacts to States

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Game Engine**: Flame
- **State Management**: BLoC pattern (flutter_bloc)
- **Dependency Injection**: get_it
- **Local Storage**: Hive
- **Notifications**: flutter_local_notifications

## Dependencies

Key dependencies used in the project:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.2
  bloc: ^8.1.1
  equatable: ^2.0.5
  get_it: ^7.6.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  uuid: ^3.0.7
  intl: ^0.18.0
  flutter_local_notifications: ^14.1.1
  flame: ^1.7.3
  path_provider: ^2.0.15
```

## Design Patterns

The application utilizes several design patterns:

1. **Repository Pattern**: Abstracts data sources from the rest of the application
2. **BLoC (Business Logic Component)**: Separates business logic from UI
3. **Dependency Injection**: Uses service locator for providing dependencies
4. **Observer Pattern**: For state changes and notifications
5. **Factory Pattern**: For creating model instances
6. **Builder Pattern**: For UI construction

## Folder Structure

```
lib/
├── main.dart                # Application entry point
├── src/
│   ├── app.dart             # Root application widget
│   ├── service_locator.dart # Dependency injection setup
│   ├── app/                 # Application-wide configurations
│   ├── blocs/               # Business Logic Components
│   │   ├── task/
│   │   ├── user/
│   │   └── creature/
│   ├── models/              # Data models
│   ├── repositories/        # Data access layer
│   ├── services/            # External services
│   ├── ui/                  # UI components
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── themes/
│   └── game/                # Flame game components
```

## Core Components

### Main Application

Located in `lib/main.dart` and `lib/src/app.dart`, these files initialize the application, set up dependency injection, and define the root widget tree.

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const TaskTamerApp());
}
```

```dart
// lib/src/app.dart
class TaskTamerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(...),
        BlocProvider<UserBloc>(...),
        BlocProvider<CreatureBloc>(...),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
```

### Service Locator

Located in `lib/src/service_locator.dart`, this file sets up dependency injection using the GetIt package.

```dart
final GetIt serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  await Hive.initFlutter();

  // Register services
  serviceLocator.registerSingleton<NotificationService>(NotificationService());

  // Register repositories
  final taskRepository = await TaskRepository.create();
  serviceLocator.registerSingleton<TaskRepository>(taskRepository);

  // Register BLoCs
  serviceLocator.registerFactory<TaskBloc>(
    () => TaskBloc(
      taskRepository: serviceLocator<TaskRepository>(),
      userRepository: serviceLocator<UserRepository>(),
      notificationService: serviceLocator<NotificationService>(),
    ),
  );
}
```

## Data Models

### Task Model

The Task model (`lib/src/models/task.dart`) represents a user task with properties like title, description, due date, and repetition settings.

Key features:

- Immutable objects with `copyWith` for modifications
- JSON serialization/deserialization
- Utility methods for formatting dates and checking task status

```dart
@immutable
class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime creationDate;
  final DateTime? dueDate;
  final RepeatFrequency? repeatFrequency;
  final int? repeatValue;
  final int? timesPerDay;
  final int completedTimes;
  final List<DateTime>? notificationTimes;
  final List<NotificationSetting>? notificationSettings;
  final bool isCompleted;

  // Methods
  Task copyWith({...}) {...}
  Map<String, dynamic> toJson() {...}
  factory Task.fromJson(Map<String, dynamic> json) {...}
  double get completionProgress {...}
}
```

### Creature Model

The Creature model (`lib/src/models/creature.dart`) represents a digital pet that users can feed and evolve.

Key features:

- Experience points and evolution tracking
- Sprite references for rendering
- JSON serialization/deserialization

### User Profile Model

The UserProfile model (`lib/src/models/user_profile.dart`) represents the user's profile and progress.

Key features:

- Experience points tracking
- Collection status
- Achievement tracking

## Repositories

Repositories handle data persistence and retrieval.

### Task Repository

The TaskRepository (`lib/src/repositories/task_repository.dart`) handles CRUD operations for tasks using Hive.

Key methods:

- `getAllTasks()`: Retrieves all tasks
- `createTask()`: Creates a new task
- `updateTask()`: Updates an existing task
- `deleteTask()`: Deletes a task
- `completeTask()`: Marks a task as completed
- `resetCompletedTasksIfNeeded()`: Resets repeating tasks

## State Management

The application uses the BLoC pattern for state management.

### Task BLoC

The TaskBloc (`lib/src/blocs/task/task_bloc.dart`) handles task-related operations and maintains task state.

Events:

- `LoadTasks`: Loads all tasks
- `AddTask`: Creates a new task
- `UpdateTask`: Updates an existing task
- `DeleteTask`: Deletes a task
- `CompleteTask`: Marks a task as completed
- `ResetTaskCompletion`: Resets task completion status
- `CheckTasksForReset`: Checks for tasks needing reset

States:

- `TaskInitial`: Initial state
- `TaskLoading`: Loading state
- `TasksLoaded`: Tasks loaded successfully
- `TaskOperationSuccess`: Operation completed successfully
- `TaskOperationFailure`: Operation failed

## UI Components

The UI is organized into screens and reusable widgets.

### Screens

Located in `lib/src/ui/screens/`.

### Themes

Defined in `lib/src/ui/themes/app_theme.dart`.

## Game Mechanics

Game mechanics are implemented using the Flame engine.

### Creature Components

Located in `lib/src/game/components/`.

## Testing Strategy

The application has comprehensive unit, widget, and integration tests:

- Unit tests for models, BLoCs, repositories, and services
- Widget tests for UI components
- Integration tests for complete user flows

See `test/README.md` for detailed testing documentation.

## Build and Deployment

### Development Build

```bash
flutter build apk --debug
```

### Production Build

```bash
flutter build apk --release
# or
flutter build appbundle
```

## Contributing Guidelines

See `CONTRIBUTING.md` for detailed contribution guidelines.
