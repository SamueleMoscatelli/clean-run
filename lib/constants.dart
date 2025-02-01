import 'package:clean_run/model/app_state.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'clean_run_themes.dart';
//import 'package:flutter_svg_provider/flutter_svg_provider.dart';

enum airQualityColors {
  worstQuality,
  badQuality,
  goodQuality,
  bestQuality,
  qualityNotAvailable,
}

extension CustomColorScheme on ColorScheme {
  get bestQuality => (brightness == Brightness.light)
      ? const Color(0xff88d08f)
      : const Color(0xff88d08f);
  get goodQuality => (brightness == Brightness.light)
      ? const Color(0xffFCD163)
      : const Color(0xffFCD163);
  get badQuality => (brightness == Brightness.light)
      ? const Color(0xffFFA26D)
      : const Color(0xffFFA26D);
  get worstQuality => (brightness == Brightness.light)
      ? const Color(0xfffd8181)
      : const Color(0xfffd8181);

  get unavailableQuality =>
      (brightness == Brightness.light) ? Colors.white : const Color(0xFFC0C0C0);

  get secondaryBestQuality => (brightness == Brightness.light)
      ? const Color(0xFF4DDF06)
      : const Color(0xFF20FF20);
  get secondaryGoodQuality => (brightness == Brightness.light)
      ? const Color(0xFFEEEE00)
      : const Color(0xFFF8F80A);
  get secondaryBadQuality => (brightness == Brightness.light)
      ? const Color(0xFFE77A00)
      : const Color(0xFFF48C14);
  get secondaryWorstQuality => (brightness == Brightness.light)
      ? const Color(0xFFFF4646)
      : const Color(0xFFFF1E1E);

  get secondaryUnavailableQuality =>
      (brightness == Brightness.light) ? Colors.white : const Color(0xFFA0A0A0);

  get aqiIconColor =>
      (brightness == Brightness.light) ? Colors.black : Colors.black;

  get aqiCardTextColor =>
      (brightness == Brightness.light) ? Colors.black : Colors.black;

  get aqiCardSecondaryTextColor =>
      (brightness == Brightness.light) ? Colors.grey[900] : Colors.grey[900];

  get bestQualityGradient => BoxDecoration(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(14.0),
        topLeft: Radius.circular(14.0),
      ),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[Color(0xffcbe7c3), Color(0xff88d08f)],
      ));

  get goodQualityGradient => BoxDecoration(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(14.0),
        topLeft: Radius.circular(14.0),
      ),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[Color(0xfffdedb6), Color(0xffFCD163)],
      ));

  get badQualityGradient => BoxDecoration(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(14.0),
        topLeft: Radius.circular(14.0),
      ),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[Color(0xffffdaae), Color(0xffFFA26D)],
      ));

  get worstQualityGradient => BoxDecoration(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(14.0),
        topLeft: Radius.circular(14.0),
      ),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[Color(0xfffab7bf), Color(0xfffd8181)],
      ));
}

dynamic getAqiColor(ThemeData theme, airQualityColors color) {
  switch (color) {
    case airQualityColors.worstQuality:
      return theme.colorScheme.worstQuality;
    case airQualityColors.badQuality:
      return theme.colorScheme.badQuality;
    case airQualityColors.goodQuality:
      return theme.colorScheme.goodQuality;
    case airQualityColors.bestQuality:
      return theme.colorScheme.bestQuality;
    default:
      return theme.colorScheme.unavailableQuality;
  }
}

dynamic getAqiColorSecondary(ThemeData theme, airQualityColors color) {
  switch (color) {
    case airQualityColors.worstQuality:
      return theme.colorScheme.secondaryWorstQuality;
    case airQualityColors.badQuality:
      return theme.colorScheme.secondaryBadQuality;
    case airQualityColors.goodQuality:
      return theme.colorScheme.secondaryGoodQuality;
    case airQualityColors.bestQuality:
      return theme.colorScheme.secondaryBestQuality;
    default:
      return theme.colorScheme.secondaryUnavailableQuality;
  }
}

dynamic getAqiGradientBoxDecoration(ThemeData theme, airQualityColors color) {
  switch (color) {
    case airQualityColors.worstQuality:
      return theme.colorScheme.worstQualityGradient;
    case airQualityColors.badQuality:
      return theme.colorScheme.badQualityGradient;
    case airQualityColors.goodQuality:
      return theme.colorScheme.goodQualityGradient;
    case airQualityColors.bestQuality:
      return theme.colorScheme.bestQualityGradient;
    default:
      return theme.colorScheme.bestQualityGradient;
  }
}

dynamic getAqiImageContainer(airQualityColors color) {
  //Svg svg;
  dynamic svg;
  switch (color) {
    case airQualityColors.worstQuality:
      //svg = Svg('assets/images/red.svg');
      svg = AssetImage('assets/images/red.png');
      break;
    case airQualityColors.badQuality:
      //svg = Svg('assets/images/orange.svg');
      svg = AssetImage('assets/images/orange.png');
      break;
    case airQualityColors.goodQuality:
      //svg = Svg('assets/images/yellow.svg');
      svg = AssetImage('assets/images/yellow.png');
      break;
    case airQualityColors.bestQuality:
      //svg = Svg('assets/images/green.svg');
      svg = AssetImage('assets/images/green.png');
      break;
    default:
      svg = AssetImage('assets/images/green.png');
      break;
  }
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(image: svg, fit: BoxFit.fill),
    ),
  );
}

AppState getDefaultState(manager) {
  return AppState(
      currentPosition: new Position(latitude: 45.4773, longitude: 9.1815),
      stopWatch: new Stopwatch(),
      chronoButtonLabel: "Start",
      activityOn: false,
      citiesAirQualityNames: ["Milano"],
      citiesAirQualityValues: [0.0],
      citiesAirQualityColors: [airQualityColors.qualityNotAvailable],
      cities: [],
      initialize: true,
      userRuns: [],
      initializeRuns: true,
      runsAirQualityColors: [],
      mapLines: [],
      runDistance: 0.0,
      runsStorageManager: manager,
      futureRuns: manager.getStoredRuns(),
      themeNotifier: ThemeNotifier());
}

AppState getTestAppstate() {
  return AppState(
      currentPosition: new Position(latitude: 45.4773, longitude: 9.1815),
      stopWatch: new Stopwatch(),
      chronoButtonLabel: "Start",
      activityOn: false,
      citiesAirQualityNames: ["Milano"],
      citiesAirQualityValues: [0.0],
      citiesAirQualityColors: [airQualityColors.qualityNotAvailable],
      cities: [],
      initialize: true,
      userRuns: [],
      initializeRuns: true,
      runsAirQualityColors: [],
      mapLines: [],
      runDistance: 0.0);
}

AppState getTestAppstateWithTheme() {
  return AppState(
      currentPosition: new Position(latitude: 45.4773, longitude: 9.1815),
      stopWatch: new Stopwatch(),
      chronoButtonLabel: "Start",
      activityOn: false,
      citiesAirQualityNames: ["Milano"],
      citiesAirQualityValues: [0.0],
      citiesAirQualityColors: [airQualityColors.qualityNotAvailable],
      cities: [],
      initialize: true,
      userRuns: [],
      initializeRuns: true,
      runsAirQualityColors: [],
      mapLines: [],
      runDistance: 0.0,
      themeNotifier: ThemeNotifier());
}
