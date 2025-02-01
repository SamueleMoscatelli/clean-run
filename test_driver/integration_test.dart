// Imports the Flutter Driver API.
import 'package:flutter/material.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('CleanRun app', () {
    // First, define the Finders and use them to locate widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.
    final addLocality = find.byValueKey('add');
    final myAirTitle = find.byValueKey('MyAir');
    final navigation = find.byValueKey("NavBar");
    final statisticsTitle = find.byValueKey('Statistics');
    final map = find.text("Map");
    final mapScreenFinder = find.byType("Home");
    final myAir = find.text("MyAir");
    final statistics = find.text("Statistics");
    final dismissibleFinder = find.byType("Dismissible");
    final start = find.byValueKey("Start");
    final stop = find.byValueKey("Stop");
    final firstCity = find.byValueKey("0");
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      await driver.setSemantics(true);
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('MyAir screen title is MyAir', () async {
      await driver.runUnsynchronized(() async {
        expect(await driver.getText(myAirTitle), "MyAir");
      });
    });

    test('search a new locality', () async {
      await driver.waitFor(addLocality);
      await Future.delayed(Duration(seconds: 2));
      await driver.tap(addLocality);
      await driver.tap(firstCity);
      expect(await driver.getText(myAirTitle), "MyAir");
    });

    test('there is a new locality', () async {
      await driver.waitFor(dismissibleFinder);
    });

    test('navigate between tabs', () async {
      await driver.tap(map);
      await driver.waitFor(mapScreenFinder);
      await driver.tap(statistics);
      expect(await driver.getText(statisticsTitle), "Statistics");
      await driver.tap(myAir);
      expect(await driver.getText(myAirTitle), "MyAir");
    });

    test('starts and stops activity tracking', () async {
      await driver.tap(map);
      await driver.waitFor(mapScreenFinder);
      await driver.tap(start);
      try {
        await driver.waitFor(find.text("Start"), timeout: Duration(seconds: 1));
        expect(true, false);
      } catch (e) {
        //ok expected not finding text Start
      }
      try {
        await driver.waitFor(find.text("00:00:00"),
            timeout: Duration(seconds: 1));
        expect(true, false);
      } catch (e) {
        //ok expected not finding text Start
      }
      await driver.waitFor(find.text("Pause"));
      await driver.tap(stop);
      try {
        await driver.waitFor(find.text("Pause"), timeout: Duration(seconds: 1));
        expect(true, false);
      } catch (e) {
        //ok expected not finding text Start
      }
      await driver.waitFor(find.text("00:00:00"));
      await driver.waitFor(find.text("00.000"));
      await driver.waitFor(find.text("Start"));
      await Future.delayed(Duration(seconds: 2));
    });

    test('there is a new statistic', () async {
      await driver.tap(statistics);
      expect(await driver.getText(statisticsTitle), "Statistics");
      await driver.waitFor(dismissibleFinder);
    });
  });
}
