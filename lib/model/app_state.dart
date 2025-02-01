import 'package:clean_run/aqiRepresentation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../clean_run_themes.dart';
import '../constants.dart';
import '../runs.dart';

class AppState {
  // a variable for each state we want to keep for the application
  Position currentPosition;
  MapboxMapController mapController;
  Stopwatch stopWatch;
  String chronoButtonLabel;
  bool activityOn;
  List citiesAirQualityNames;
  List citiesAirQualityValues;
  List citiesAirQualityColors;
  List<String> cities = [];
  bool initialize;
  Map<String, dynamic> run;
  List<Map<String, dynamic>> userRuns;
  bool initializeRuns;
  List<airQualityColors> runsAirQualityColors;
  List<LatLng> mapLines = [];
  double runDistance;
  Map temporaryDismissedRun;
  int dismissedRunIndex;
  RunPersistenceHandler runsStorageManager;
  Future<List<Map<String, dynamic>>> futureRuns;
  DateTime runStartTime;
  ThemeNotifier themeNotifier;
  Map<String, dynamic> dismissedCity;
  int dismissedCityIndex;

  AppState({
    @required this.currentPosition,
    this.mapController,
    this.stopWatch,
    this.chronoButtonLabel,
    this.activityOn,
    this.citiesAirQualityNames,
    this.citiesAirQualityValues,
    this.citiesAirQualityColors,
    this.cities,
    this.initialize,
    this.userRuns,
    this.initializeRuns,
    this.runsAirQualityColors,
    this.mapLines,
    this.runDistance,
    this.temporaryDismissedRun,
    this.dismissedRunIndex,
    this.runsStorageManager,
    this.futureRuns,
    this.run,
    this.themeNotifier,
  });

  AppState.fromAppState(AppState another) {
    //assign the various components
    currentPosition = another.currentPosition;
    mapController = another.mapController;
    stopWatch = another.stopWatch;
    chronoButtonLabel = another.chronoButtonLabel;
    activityOn = another.activityOn;
    citiesAirQualityNames = another.citiesAirQualityNames;
    citiesAirQualityValues = another.citiesAirQualityValues;
    citiesAirQualityColors = another.citiesAirQualityColors;
    cities = another.cities;
    initialize = another.initialize;
    userRuns = another.userRuns;
    initializeRuns = another.initializeRuns;
    runsAirQualityColors = another.runsAirQualityColors;
    mapLines = another.mapLines;
    runDistance = another.runDistance;
    temporaryDismissedRun = another.temporaryDismissedRun;
    dismissedRunIndex = another.dismissedRunIndex;
    runsStorageManager = another.runsStorageManager;
    futureRuns = another.futureRuns;
    run = another.run;
    runStartTime = another.runStartTime;
    themeNotifier = another.themeNotifier;
  }

  Position get currentUserPosition => currentPosition;
  MapboxMapController get currentMapController => mapController;
  Stopwatch get currentStopWatch => stopWatch;
  String get currentChronoButtonLabel => chronoButtonLabel;
  bool get currentActivityOn => activityOn;
  List get currentCitiesAirQualityNames => citiesAirQualityNames;
  List get currentCitiesAirQualityValues => citiesAirQualityValues;
  List get currentCitiesAirQualityColors => citiesAirQualityColors;
  List<String> get currentCities => cities;
  bool get currentInitialize => initialize;
  List<Map<String, dynamic>> get currentUserRuns => userRuns;
  bool get runsInitialize => initializeRuns;
  List<airQualityColors> get currentRunsAirQualityColors =>
      runsAirQualityColors;
  List<LatLng> get currentMapLines => mapLines;
  double get currentRunDistance => runDistance;
  Map get currentDismissedRun => temporaryDismissedRun;
  int get currentDismissedRunIndex => dismissedRunIndex;
  RunPersistenceHandler get currentRunsStorageManager => runsStorageManager;
  Future<List<Map<String, dynamic>>> get storedRuns => futureRuns;
  Map<String, dynamic> get currentRun => run;
  DateTime get currentStartTime => runStartTime;
  ThemeNotifier get currentThemeNotifier => themeNotifier;
  Map<String, dynamic> get currentDismissedCity => dismissedCity;
  int get currentDismissedCityIndex => dismissedCityIndex;

  set currentStartTime(value) {
    runStartTime = value;
  }

  void setMapController(MapboxMapController controller) {
    mapController = controller;
  }

  static AppState fromJson(dynamic jsonMap) {
    if (jsonMap == null) return null;
    var manager = RunPersistenceHandler();
    AppState loadedState = new AppState(
        currentPosition: Position(
            latitude: jsonMap["latitude"], longitude: jsonMap["longitude"]),
        stopWatch: new Stopwatch(),
        chronoButtonLabel: "Start",
        activityOn: false,
        citiesAirQualityNames:
            ((jsonMap["citiesAirQualityNames"] ?? []) as List)
                .cast<String>()
                .toList(),
        citiesAirQualityValues:
            ((jsonMap["citiesAirQualityValues"] ?? []) as List)
                .cast<double>()
                .toList(),
        citiesAirQualityColors: (var list) {
          List<airQualityColors> temp = [];
          if (list.length == 0) return temp;
          for (double i in list ?? []) {
            temp.add(selectColor(i));
          }
          return temp;
        }(((jsonMap["citiesAirQualityValues"] ?? []) as List)
            .cast<double>()
            .toList()),
        cities: ((jsonMap["cities"] ?? []) as List).cast<String>().toList(),
        initialize: true,
        userRuns: [],
        initializeRuns: true,
        runsAirQualityColors: [],
        mapLines: [],
        runDistance: 0.0,
        runsStorageManager: manager,
        futureRuns: manager.getStoredRuns(),
        themeNotifier: ThemeNotifier());
    if (jsonMap["darkMode"] as bool ?? false) {
      loadedState.themeNotifier.setDarkMode();
    }
    return loadedState;
  }

  dynamic toJson() {
    print("saving");
    return {
      "latitude": currentPosition.latitude,
      "longitude": currentPosition.longitude,
      "citiesAirQualityNames": citiesAirQualityNames,
      "citiesAirQualityValues": citiesAirQualityValues,
      "cities": cities,
      "darkMode": currentThemeNotifier.darkMode,
    };
  }
}
