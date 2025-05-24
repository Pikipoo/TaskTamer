# TaskTamer Architecture

This document describes the overall architecture of the TaskTamer application, explaining the design decisions, patterns, and component interactions.

## Architectural Overview

TaskTamer follows a clean architecture approach with clear separation of concerns. The application is divided into several layers:

1. **Presentation Layer**: User interface components and state management
2. **Domain Layer**: Business logic and models
3. **Data Layer**: Data access and persistence

This layering provides several benefits:

- Clear separation of concerns
- Testability of individual components
- Flexibility to change implementations
- Maintainability and scalability

## Architectural Diagram

```
┌─────────────────────────────────────┐
│               UI Layer              │
│  ┌─────────────┐    ┌─────────────┐ │
│  │   Screens   │    │   Widgets   │ │
│  └─────────────┘    └─────────────┘ │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│            Business Layer           │
│  ┌─────────────┐    ┌─────────────┐ │
│  │    BLoCs    │    │   Services  │ │
│  └─────────────┘    └─────────────┘ │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│             Data Layer              │
│  ┌─────────────┐    ┌─────────────┐ │
│  │ Repositories│    │  Data Models│ │
│  └─────────────┘    └─────────────┘ │
└───────────────┬─────────────────────┘
                │
                ▼
┌─────────────────────────────────────┐
│          External Systems           │
│  ┌─────────────┐    ┌─────────────┐ │
│  │   Hive DB   │    │Notifications│ │
│  └─────────────┘    └─────────────┘ │
└─────────────────────────────────────┘
```

## Key Components

### 1. Presentation Layer

#### UI Components

The UI is built using Flutter widgets and follows a component-based architecture:

- **Screens**: Full-page UI components (e.g., HomeScreen, TaskDetailScreen)
- **Widgets**: Reusable UI components (e.g., TaskListItem, CreatureCard)
- **Themes**: Global styling definitions

User interactions in the UI trigger events that are dispatched to BLoCs.

### 2. Business Layer

#### BLoC (Business Logic Component)

The BLoC pattern is used for state management, separating business logic from UI:

- Each BLoC manages a specific domain (tasks, user, creatures)
- BLoCs receive events from the UI
- BLoCs process events and emit states
- UI rebuilds based on emitted states

```dart
// Simplified example of TaskBloc
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;

  TaskBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    // Other event handlers...
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskRepository.getAllTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskOperationFailure(e.toString()));
    }
  }

  // Other event handlers...
}
```

#### Services

Services encapsulate interactions with platform features:

- **NotificationService**: Handles local notifications
- **AudioService**: Manages sound effects and background music
- **GameService**: Coordinates game mechanics

### 3. Data Layer

#### Repositories

Repositories implement data access logic:

- Abstract the data source from the business layer
- Provide CRUD operations for domain models
- Handle data conversion and error handling

```dart
// Simplified example of TaskRepository
class TaskRepository {
  final Box<Map> _box;

  TaskRepository(this._box);

  static Future<TaskRepository> create() async {
    final box = await Hive.openBox<Map>('tasks');
    return TaskRepository(box);
  }

  Future<List<Task>> getAllTasks() async {
    return _box.values.map((json) => Task.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  // Other repository methods...
}
```

#### Data Models

Data models represent domain entities:

- Immutable objects with value equality
- Serialization/deserialization methods
- Business logic related to the entity itself

```dart
// Simplified example of Task model
@immutable
class Task extends Equatable {
  final String id;
  final String title;
  final DateTime? dueDate;
  final bool isCompleted;

  const Task({
    required this.id,
    required this.title,
    this.dueDate,
    this.isCompleted = false,
  });

  // Factory methods, serialization, utility methods...
}
```

### 4. External Systems

- **Hive**: Local NoSQL database for persistent storage
- **Flutter Local Notifications**: Platform notifications
- **Flame Engine**: 2D game rendering and physics

## Dependency Injection

TaskTamer uses the `get_it` package to implement a service locator pattern for dependency injection:

- Services, repositories, and BLoCs are registered with the service locator
- Components request dependencies from the service locator
- This approach simplifies testing by allowing mock implementations

```dart
// Simplified example of dependency injection
final GetIt serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register services
  serviceLocator.registerSingleton<NotificationService>(NotificationService());

  // Register repositories
  final taskRepository = await TaskRepository.create();
  serviceLocator.registerSingleton<TaskRepository>(taskRepository);

  // Register BLoCs
  serviceLocator.registerFactory<TaskBloc>(
    () => TaskBloc(taskRepository: serviceLocator<TaskRepository>()),
  );
}
```

## Data Flow

1. **User Interaction**: User interacts with the UI (e.g., taps "Complete Task" button)
2. **Event Dispatch**: UI dispatches an event to the BLoC (e.g., `CompleteTask(taskId)`)
3. **Business Logic**: BLoC processes the event, calling repository methods
4. **Data Access**: Repository updates data in the database
5. **State Update**: BLoC emits a new state (e.g., `TasksLoaded(updatedTasks)`)
6. **UI Update**: UI rebuilds based on the new state

## Game Integration

The game elements (creatures, animations) are integrated using the Flame engine:

- Flame components are embedded within Flutter widgets
- Game state is managed through the CreatureBloc
- Creature sprites and animations are loaded and rendered by Flame
- User interactions with creatures are translated into Flame game events

## Conclusion

TaskTamer's architecture is designed to be:

- **Maintainable**: Clear separation of concerns
- **Testable**: Independent components with clear interfaces
- **Scalable**: Easy to add new features
- **Flexible**: Infrastructure changes don't affect business logic
- **Performant**: Efficient data flow and rendering
