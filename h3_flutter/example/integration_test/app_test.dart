import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:h3_flutter_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('test that app loads h3 lib correctly', () {
    testWidgets('verify that h3.degsToRads(180) returns correct result',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final degsToRadsText = tester
          .firstWidget(find.byKey(const ValueKey('degsToRadsText'))) as Text;

      expect(
        double.tryParse(degsToRadsText.data ?? '')?.toStringAsFixed(4),
        '3.1416',
      );
    });
  });
}
