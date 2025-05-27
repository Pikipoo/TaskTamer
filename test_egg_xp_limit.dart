import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_tamer/src/models/hive_adapters.dart';
import 'package:task_tamer/src/repositories/egg_repository.dart';

void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  await registerHiveAdapters();

  // Create egg repository
  final eggRepository = await EggRepository.create();

  // Run the test
  final results = await eggRepository.testXpLimiting();

  // Print test results
  print('=== EGG XP LIMITING TEST ===');
  print('Case 1 (add within limit): ${results['case1']['success'] ? 'PASS' : 'FAIL'}');
  print('  Added: ${results['case1']['added']} XP');
  print('  Expected: ${results['case1']['expected']} XP');
  print('  Actual: ${results['case1']['actual']} XP');

  print('Case 2 (add more than needed): ${results['case2']['success'] ? 'PASS' : 'FAIL'}');
  print('  Added: ${results['case2']['added']} XP');
  print('  Expected: ${results['case2']['expected']} XP');
  print('  Actual: ${results['case2']['actual']} XP');

  print('Case 3 (add when already at max): ${results['case3']['success'] ? 'PASS' : 'FAIL'}');
  print('  Added: ${results['case3']['added']} XP');
  print('  Expected: ${results['case3']['expected']} XP');
  print('  Actual: ${results['case3']['actual']} XP');

  print('Overall result: ${results['overall'] ? 'PASS' : 'FAIL'}');

  // Exit
  SystemNavigator.pop();
}
