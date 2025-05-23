import 'dart:io';

void main() async {
  print('TaskTamer Setup Tool');
  print('====================');

  // Install git hooks
  await _installGitHooks();

  print('\nSetup completed successfully!');
}

Future<void> _installGitHooks() async {
  print('\nSetting up git hooks...');

  // Make sure the .git/hooks directory exists
  final gitHooksDir = Directory('.git/hooks');
  if (!await gitHooksDir.exists()) {
    print(
      'Error: .git/hooks directory not found. Make sure you are in the root of the git repository.',
    );
    exit(1);
  }

  // Make hooks executable
  await _makeHooksExecutable();

  // Copy hooks to .git/hooks
  final preCommitSource = File('.githooks/pre-commit');
  final preCommitDest = File('.git/hooks/pre-commit');
  final prePushSource = File('.githooks/pre-push');
  final prePushDest = File('.git/hooks/pre-push');

  if (await preCommitSource.exists()) {
    await preCommitSource.copy(preCommitDest.path);
    print('✅ pre-commit hook installed');
  } else {
    print('❌ pre-commit hook source not found');
    exit(1);
  }

  if (await prePushSource.exists()) {
    await prePushSource.copy(prePushDest.path);
    print('✅ pre-push hook installed');
  } else {
    print('❌ pre-push hook source not found');
    exit(1);
  }

  print('✅ Git hooks installed successfully');
}

Future<void> _makeHooksExecutable() async {
  final result = await Process.run('chmod', [
    '+x',
    '.githooks/pre-commit',
    '.githooks/pre-push',
  ]);
  if (result.exitCode != 0) {
    print('Warning: Failed to make hooks executable: ${result.stderr}');
    // Continue despite the warning
  }
}
