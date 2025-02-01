// here a class for each action
import 'package:clean_run/constants.dart';
//import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class CurrentPosition {
  final Position payload;
  CurrentPosition(this.payload);
}

class MapController {
  final MapboxMapController payload;
  MapController(this.payload);
}

class ChangeCameraPosition {
  final Position payload;
  ChangeCameraPosition(this.payload);
}

class StopWatch {
  final Stopwatch payload;
  StopWatch(this.payload);
}

class ChronoButtonLabel {
  final String payload;
  ChronoButtonLabel(this.payload);
}

class ActivityOn {
  final bool payload;
  ActivityOn(this.payload);
}

class CitiesAirQualityNames {
  final String payload;
  CitiesAirQualityNames(this.payload);
}

class CitiesAirQualityValues {
  final payload;
  CitiesAirQualityValues(this.payload);
}

class CitiesAirQualityColors {
  final airQualityColors payload;
  CitiesAirQualityColors(this.payload);
}

class CitiesAirQualityNamesDel {
  final String payload;
  CitiesAirQualityNamesDel(this.payload);
}

class CitiesAirQualityValuesDel {
  final payload;
  CitiesAirQualityValuesDel(this.payload);
}

class CitiesAirQualityColorsDel {
  final payload;
  CitiesAirQualityColorsDel(this.payload);
}

class Cities {
  final List<String> payload;
  Cities(this.payload);
}

class Initialize {
  final bool payload;
  Initialize(this.payload);
}

class StartRun {
  Map<String, dynamic> payload;
  StartRun(this.payload);
}

class EndRun {
  EndRun();
}

class RunsInitialize {
  final bool payload;
  RunsInitialize(this.payload);
}

class RunsAirQualityColors {
  final airQualityColors payload;
  RunsAirQualityColors(this.payload);
}

class InitializeCamera {
  final payload;
  InitializeCamera(this.payload);
}

class ResetLines {
  ResetLines();
}

class StoredRuns {
  List<Map> payload;
  StoredRuns(this.payload);
}

class RunDistance {
  final double payload;
  RunDistance(this.payload);
}

class DismissRun {
  int payload;
  DismissRun(this.payload);
}

class RestoreRun {
  RestoreRun();
}

class RestoreCity {
  RestoreCity();
}

//this might be useful?
class Refresh {
  Refresh();
}

class ConfirmRunDismiss extends Refresh {
  ConfirmRunDismiss();
}

class ChangeTheme extends Refresh {
  ChangeTheme();
}
