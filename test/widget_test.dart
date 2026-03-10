import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neram/app.dart';
import 'package:neram/data/services/timezone_service.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TimezoneService.initialize();
  });

  testWidgets('renders Neram home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NeramApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Neram'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}
