import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:unit_converter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home screen renders on Android without layout overflow', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('All-in-One Unit Converter'), findsOneWidget);
    expect(find.text('Quick presets'), findsOneWidget);
    expect(find.text('Converters'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}