# TaskTamer App - Testing Guide

This document provides information on the testing setup for the TaskTamer application.

## Test Structure

The tests are structured as follows:

```
test/
├── blocs/                 # BLoC unit tests
│   ├── task_bloc_test.dart
│   └── creature_bloc_test.dart
├── models/                # Model unit tests
│   ├── task_test.dart
│   └── creature_test.dart
├── widgets/               # Widget tests
│   └── task_list_item_test.dart
├── run_all_tests.dart     # Script to run all unit tests
└── widget_test.dart       # Main app widget test
```

```
integration_test/
└── app_test.dart          # End-to-end integration tests
```

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

### Integration Tests

To run integration tests:

```bash
flutter test integration_test/app_test.dart
```

## Test Coverage

To generate test coverage report:

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

1. **Model Tests**: Test the data models (Task, Creature) and their methods
2. **BLoC Tests**: Test the BLoC classes and their event handling
3. **Widget Tests**: Test individual UI components
4. **Integration Tests**: Test full app workflows end-to-end

## Notes for Test Maintenance

- When adding new features, make sure to add corresponding tests
- Keep the mock implementations up to date with any repository/service interface changes
- Update the integration tests when UI flows change
- Keep test fixtures (sample data) in sync with model changes
