import 'package:clean_run/model/app_state.dart';
import 'package:flutter/material.dart';
import 'package:clean_run/distance_text.dart';
import 'package:clean_run/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  // Define a test. The TestWidgets function also provides a WidgetTester
  // to work with. The WidgetTester allows you to build and interact
  // with widgets in the test environment.
  testWidgets('DistanceText should start from 00.000',
      (WidgetTester tester) async {
    // Test code goes here.
    AppState state = getTestAppstate();
    await binding.setSurfaceSize(Size(1024, 1024));
    await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(size: Size(1024, 1024)),
        child: Builder(
          builder: (BuildContext context) {
            return Directionality(
                textDirection: TextDirection.ltr,
                child: createAppbarDistanceText(state, context));
          },
        )));
    Finder stopwatch = find.text("00.000");

    expect(stopwatch.evaluate().length, 1);
  });

  testWidgets('DistanceText displays the state correctly',
      (WidgetTester tester) async {
    // Test code goes here.
    await binding.setSurfaceSize(Size(1024, 1024));
    AppState state = getTestAppstate();
    state.runDistance = 0.01;

    DateTime now = new DateTime.now();
    state.currentStartTime = now;
    await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(size: Size(1024, 1024)),
        child: Builder(
          builder: (BuildContext context) {
            return Directionality(
                textDirection: TextDirection.ltr,
                child: createAppbarDistanceText(state, context));
          },
        )));
    Finder stopwatch = find.text("00.010");

    expect(stopwatch.evaluate().length, 1);
  });

  testWidgets('DistanceText displays distances longer than the padded sequence',
      (WidgetTester tester) async {
    // Test code goes here.
    await binding.setSurfaceSize(Size(1024, 1024));
    AppState state = getTestAppstate();
    state.runDistance = 100000.0;

    DateTime now = new DateTime.now();
    state.currentStartTime = now;
    await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(size: Size(1024, 1024)),
        child: Builder(
          builder: (BuildContext context) {
            return Directionality(
                textDirection: TextDirection.ltr,
                child: createAppbarDistanceText(state, context));
          },
        )));
    Finder stopwatch = find.text("100000.000");

    expect(stopwatch.evaluate().length, 1);
  });
}
