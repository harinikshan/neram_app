import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neram/data/models/clock_model.dart';
import 'package:neram/data/services/timezone_service.dart';
import 'package:neram/features/clock/providers/time_tick_provider.dart';
import 'package:neram/features/clock/widgets/master_clock_display.dart';
import 'package:neram/features/clock/widgets/mechanical_master_clock.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TimezoneService.initialize();
  });

  testWidgets('mechanical master clock renders on compact width', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: MechanicalMasterClock(
                hourTens: '0',
                hourOnes: '5',
                minuteTens: '4',
                minuteOnes: '9',
                secondTens: '2',
                secondOnes: '6',
                amPm: 'PM',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(MechanicalMasterClock), findsOneWidget);
  });

  testWidgets('mechanical master clock renders on wide width', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 920,
              child: MechanicalMasterClock(
                hourTens: '1',
                hourOnes: '2',
                minuteTens: '3',
                minuteOnes: '4',
                secondTens: '5',
                secondOnes: '6',
                amPm: 'AM',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(MechanicalMasterClock), findsOneWidget);
  });

  testWidgets('master clock display does not throw on narrow screen', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final clock = ClockModel.fromTimezoneId(
      'Asia/Kolkata',
      isMaster: true,
      orderIndex: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timeTickProvider.overrideWith(
            (ref) => Stream<DateTime>.value(DateTime(2026, 3, 8, 17, 5, 10)),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 340,
                child: MasterClockDisplay(clock: clock),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.byType(MasterClockDisplay), findsOneWidget);
  });
}
