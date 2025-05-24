# Contributing to TaskTamer

Thank you for your interest in contributing to TaskTamer! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md) to maintain a welcoming and inclusive community.

## How Can I Contribute?

### Reporting Bugs

- **Check Existing Issues**: Before creating a new bug report, check if the issue has already been reported.
- **Use the Bug Report Template**: When creating a new issue, use the bug report template.
- **Include Details**: Include as much information as possible, such as:
  - Steps to reproduce
  - Expected behavior
  - Actual behavior
  - Screenshots if applicable
  - Device information (OS, Flutter version, etc.)

### Suggesting Features

- **Check Existing Issues**: Before suggesting a new feature, check if it has already been suggested.
- **Use the Feature Request Template**: When creating a new feature request, use the feature request template.
- **Be Specific**: Clearly describe the feature and its benefits.

### Pull Requests

1. **Fork the Repository**: Fork the TaskTamer repository to your GitHub account.
2. **Clone Your Fork**: Clone your fork to your local machine.
3. **Create a Branch**: Create a branch for your changes.
4. **Make Changes**: Make your changes following the coding standards.
5. **Run Tests**: Ensure all tests pass.
6. **Commit Changes**: Commit your changes with a clear and descriptive commit message.
7. **Push Changes**: Push your changes to your fork.
8. **Create Pull Request**: Create a pull request from your branch to the main repository.
9. **Review Process**: Wait for the review process and address any feedback.

## Development Process

### Setting Up the Development Environment

1. **Clone the Repository**:

```bash
git clone https://github.com/yourusername/TaskTamer.git
cd TaskTamer
```

2. **Install Dependencies**:

```bash
flutter pub get
```

3. **Run the Setup Script**:

```bash
dart tool/setup.dart
```

### Branch Strategy

- **main**: Production-ready code
- **feature/[feature-name]**: New features or enhancements
- **bugfix/[bug-name]**: Bug fixes
- **hotfix/[issue-name]**: Critical fixes for production

### Commit Message Guidelines

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **test**: Adding or modifying tests
- **chore**: Changes to the build process or tools

Example:

```
feat(task): add recurring task functionality

- Added weekly and monthly recurrence options
- Implemented notification scheduling for recurring tasks

Closes #123
```

### Code Style

TaskTamer follows the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) with some project-specific rules:

- Use `dart format --line-length=100` for formatting
- Follow the [Flutter Style Guide](https://flutter.dev/docs/development/tools/formatting)
- Use `camelCase` for variables and functions
- Use `PascalCase` for classes and types
- Use `snake_case` for file names

### Testing

- Write tests for all new features and bug fixes
- Maintain or improve code coverage
- Run tests before submitting a pull request:

```bash
flutter test
```

## Documentation

- Document all public APIs with dartdoc comments
- Update README and other documentation when necessary
- Include screenshots or GIFs for UI changes

## Review Process

1. **Automated Checks**: GitHub Actions will run automated checks on your pull request.
2. **Code Review**: A project maintainer will review your code.
3. **Feedback**: Address any feedback from the code review.
4. **Approval**: Once approved, your pull request will be merged.

## License

By contributing to TaskTamer, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).
