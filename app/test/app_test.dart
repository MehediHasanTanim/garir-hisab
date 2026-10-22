import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/app.dart';
import 'package:vehicle_khata/app/flavor.dart';

void main() {
  testWidgets('app shell renders flavor name', (tester) async {
    await tester.pumpWidget(
      const KhataApp(config: AppConfig(flavor: Flavor.dev)),
    );
    expect(find.text('Flavor: dev'), findsOneWidget);
  });
}
