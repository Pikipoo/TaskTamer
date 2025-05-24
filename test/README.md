# TaskTamer App - Testing Guide

This document provides comprehensive information on the testing setup, strategies, and guidelines for the TaskTamer application.

## Test Structure

The tests are organized into different categories to ensure comprehensive coverage:

```
test/
├── blocs/                 # BLoC unit tests
│   ├── task_bloc_test.dart       # Tests TaskBloc events and states
│   ├── creature_bloc_test.dart   # Tests CreatureBloc events and states
│   └── user_bloc_test.dart       # Tests UserBloc events and states
├── models/                # Model unit tests
│   ├── task_test.dart          # Tests Task model methods
│   ├── creature_test.dart      # Tests Creature model methods
│   └── user_profile_test.dart  # Tests UserProfile model methods
├── repositories/          # Repository tests
│   ├── task_repository_test.dart
│   ├── creature_repository_test.dart
│   └── user_repository_test.dart
├── services/              # Service tests
│   └── notification_service_test.dart
├── widgets/               # Widget tests
│   ├── task_list_item_test.dart
│   ├── creature_card_test.dart
│   └── progress_bar_test.dart
├── run_all_tests.dart     # Script to run all unit tests
└── widget_test.dart       # Main app widget test
```

```
integration_test/
└── app_test.dart          # End-to-end integration tests
```

## Testing Philosophy

Our testing strategy follows these principles:

1. **Test Isolation**: Each test should be independent and not rely on other tests.
2. **Mock External Dependencies**: Use mocks for repositories, services, and other dependencies.
3. **Complete Coverage**: Aim for high code coverage, especially for business logic.
4. **Test Edge Cases**: Include tests for error conditions and edge cases.
5. **Readable Tests**: Tests should be clearly structured and well-documented.

## Running Tests

### Unit Tests

To run all unit tests:

```bash
flutter test
```

To run a specific test file:

```bash
flutter test test/models/task_test.dart
```

To run tests with tags:

```bash
flutter test --tags="BLoC"
```

### Integration Tests

To run integration tests:

```bash
flutter test integration_test/app_test.dart
```

## Test Coverage

To generate test coverage reports:

```bash
flutter test --coverage
```

Then, to view coverage report in HTML format:

```bash
# Install lcov if not already installed
# For Ubuntu/Debian:
# sudo apt-get install lcov
# For macOS with Homebrew:
# brew install lcov

genhtml coverage/lcov.info -o coverage/html
```

Open `coverage/html/index.html` in a web browser to view the coverage report.

## Test Categories

### Model Tests

Model tests verify that the data models work as expected:

- Constructors and factory methods
- Utility methods (like `isDue()` in Task)
- Serialization/deserialization (toJson/fromJson)
- Equality comparisons

### BLoC Tests

BLoC tests verify that state management works correctly:

- Initial state
- Event handling
- State transitions
- Error handling
- Interactions with repositories and services

### Repository Tests

Repository tests verify data persistence:

- CRUD operations
- Query methods
- Error handling

### Widget Tests

Widget tests verify that UI components render and behave correctly:

- Rendering with different data
- User interactions (taps, swipes)
- Responsive layouts

### Integration Tests

Integration tests verify complete user flows:

- Task creation and management
- Creature feeding and evolution
- Navigation between screens

## Mocking Strategy

We use the Mocktail package for mocking:

- Create mock classes that extend the interface being mocked
- Use `when` to define behavior
- Use `verify` to ensure methods were called

Example:

```dart
// Mock definition
class MockTaskRepository extends Mock implements TaskRepository {}

// Test setup
final mockRepo = MockTaskRepository();
when(() => mockRepo.getAllTasks()).thenAnswer((_) async => [testTask]);

// Verification
verify(() => mockRepo.getAllTasks()).called(1);
```

## Test Fixtures

Reusable test data is defined in each test file. Consider moving common fixtures to separate files if they are used across multiple test files.

## Notes for Test Maintenance

- When adding new features, also add corresponding tests
- Keep mock implementations up to date with any interface changes
- Update integration tests when UI flows change
- Keep test fixtures in sync with model changes
- Regularly run the full test suite to catch regressions

## Continuous Integration

Tests are run automatically on GitHub Actions for every push and pull request. The CI workflow:

1. Sets up Flutter environment
2. Installs dependencies
3. Runs static analysis (`flutter analyze`)
4. Runs all unit tests
5. Generates and uploads coverage reports
