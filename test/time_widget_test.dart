import 'package:clean_run/model/app_state.dart';
import 'package:clean_run/redux/reducers.dart';
import 'package:flutter/material.dart';
import 'package:clean_run/timer_text.dart';
import 'package:clean_run/constants.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  // Define a test. The TestWidgets function also provides a WidgetTester
  // to work with. The WidgetTester allows you to build and interact
  // with widgets in the test environment.

  testWidgets('TimerText advances correctly', (WidgetTester tester) async {
    // Test code goes here.
    await binding.setSurfaceSize(Size(1024, 1024));
    AppState state = getTestAppstate();
    state.stopWatch.start();
    final Store<AppState> store = Store<AppState>(reducer, initialState: state);
    DateTime now = new DateTime.now();
    state.currentStartTime = now;
    await tester.pumpWidget(
        MediaQuery(
            data: MediaQueryData(size: Size(1024, 1024)),
            child: StoreProvider<AppState>(
                store: store,
                child: (Directionality(
                    textDirection: TextDirection.ltr,
                    child: TimerText(
                        stopwatch: state.stopWatch, appstate: state))))),
        Duration(milliseconds: 1200));
    Finder stopwatch = find.byKey(Key("timerText"));
    var seconds = int.parse(
        ((stopwatch.evaluate().first.widget as Text).data).split(":")[2]);
    print(seconds);
    expect(seconds > 0, true);
  });
  testWidgets('TimerText starts at 00:00:00', (WidgetTester tester) async {
    // Test code goes here.
    AppState state = getTestAppstate();
    await binding.setSurfaceSize(Size(1024, 1024));
    await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(size: Size(1024, 1024)),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: TimerText(stopwatch: state.stopWatch, appstate: state))));

    Finder stopwatch = find.text("00:00:00");

    expect(stopwatch.evaluate().length, 1);
  });
}
