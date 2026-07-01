import 'package:flutter_test/flutter_test.dart';
import 'package:univercel_remote/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MyApp(),
      ),
    );
  });
}
