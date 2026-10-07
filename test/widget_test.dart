import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bill_tracker_app/main.dart';
import 'package:bill_tracker_app/state/app_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Bill Tracker App smoke test', (WidgetTester tester) async {
    // Set a large screen size to view all 5 cards in list
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = AppState();
    await appState.init();

    await tester.pumpWidget(BillTrackerApp(appState: appState));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify app title exists
    expect(find.text('Bill Trap'), findsOneWidget);

    // Verify all 5 cards are rendered
    expect(find.text('Axis Flipkart Card'), findsOneWidget);
    expect(find.text('ICICI Amazon Card'), findsOneWidget);
    expect(find.text('IDFC Power Card'), findsOneWidget);
    expect(find.text('ICICI Coral Card'), findsOneWidget);
    expect(find.text('Slice Card'), findsOneWidget);

    // Verify HDFC Millennia is not rendered
    expect(find.text('HDFC Millennia Card'), findsNothing);

    // Verify summary banner exists
    expect(find.text('TOTAL DUE THIS MONTH'), findsOneWidget);
  });
}
