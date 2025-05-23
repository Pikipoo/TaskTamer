import 'package:flutter_test/flutter_test.dart';

import 'blocs/task_bloc_test.dart' as task_bloc_test;
import 'blocs/creature_bloc_test.dart' as creature_bloc_test;
import 'models/task_test.dart' as task_model_test;
import 'models/creature_test.dart' as creature_model_test;
import 'widgets/task_list_item_test.dart' as task_list_item_test;

void main() {
  group('Running all unit tests', () {
    test('Model Tests', () {
      task_model_test.main();
      creature_model_test.main();
    });

    test('BLoC Tests', () {
      task_bloc_test.main();
      creature_bloc_test.main();
    });

    test('Widget Tests', () {
      task_list_item_test.main();
    });
  });
}
