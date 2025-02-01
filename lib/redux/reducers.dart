import 'package:clean_run/aqiRepresentation.dart';
import 'package:clean_run/model/app_state.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'actions.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:clean_run/constants.dart';

AppState reducer(AppState prevState, dynamic action) {
  AppState newState = AppState.fromAppState(prevState);
  if (action is CurrentPosition) {
    newState.currentPosition = action.payload;
  } else if (action is MapController) {
    newState.mapController = action.payload;
  } else if (action is StopWatch) {
    newState.stopWatch = action.payload;
  } else if (action is ChronoButtonLabel) {
    newState.chronoButtonLabel = action.payload;
  } else if (action is ChangeCameraPosition && newState.mapController != null) {
    if (newState.stopWatch.isRunning) {
      /*LatLng lineStart = LatLng(newState.currentPosition.latitude,
          newState.currentPosition.longitude);
      LatLng lineEnd =
          LatLng(action.payload.latitude, action.payload.longitude);
      List<LatLng> line = [lineStart, lineEnd];
      LineOptions lineOptions = LineOptions(
          geometry: line, lineWidth: 12, lineColor: "#0046FF", lineBlur: 4);
      newState.mapController.addLine(lineOptions);
      newState.mapLines.add(line);

      /*   newState.mapController.moveCamera(
        CameraUpdate.newLatLng(
          LatLng(action.payload.latitude, action.payload.longitude),
        ),
      );*/

      double distance = calculateDistance(lineStart.latitude,
          lineStart.longitude, lineEnd.latitude, lineEnd.longitude);

      newState.runDistance += distance;*/
    }
    newState.currentPosition = action.payload;
  } else if (action is ActivityOn) {
    newState.activityOn = action.payload;
  } else if (action is CitiesAirQualityNames) {
    newState.citiesAirQualityNames.add(action.payload);
  } else if (action is CitiesAirQualityValues) {
    newState.citiesAirQualityValues.add(action.payload);
  } else if (action is CitiesAirQualityColors) {
    newState.citiesAirQualityColors.add(action.payload);
  } else if (action is Cities) {
    newState.cities = action.payload;
  } else if (action is Initialize) {
    newState.initialize = action.payload;
  } else if (action is CitiesAirQualityColorsDel) {
    newState.citiesAirQualityColors.removeAt(action.payload);
  } else if (action is CitiesAirQualityValuesDel) {
    newState.citiesAirQualityValues.removeAt(action.payload);
  } else if (action is CitiesAirQualityNamesDel) {
    newState.citiesAirQualityNames.remove(action.payload);
  } else if (action is StartRun) {
    newState.run = action.payload;
    //newState.currentRunsStorageManager.storeRuns(newState.currentUserRuns);
  } else if (action is EndRun) {
    newState.run = null;
    prevState.run["time"] = DateTime.now().difference(prevState.runStartTime);
    prevState.run["aqis"] =
        (prevState.run["aqis"] as List).cast<double>().toList();
    prevState.run["measurementsDistances"] =
        (prevState.run["measurementsDistances"] as List)
            .cast<double>()
            .toList();
    newState.currentUserRuns.insert(0, prevState.run);
    newState.currentRunsAirQualityColors.insert(
        0,
        (value) {
          if (value == 0.0) return airQualityColors.qualityNotAvailable;
          return selectColor(value);
        }(findAQI(prevState.run)));
    newState.currentRunsStorageManager.storeRuns(newState.currentUserRuns);
  } else if (action is StoredRuns) {
    newState.userRuns += action.payload;
  } else if (action is RunsInitialize) {
    newState.initializeRuns = action.payload;
  } else if (action is RunsAirQualityColors) {
    newState.runsAirQualityColors.add(action.payload);
  } else if (action is InitializeCamera) {
    newState.currentPosition = action.payload;

    newState.mapController.moveCamera(
      CameraUpdate.newLatLng(
        LatLng(action.payload.latitude, action.payload.longitude),
      ),
    );
    //print(newState.mapController.cameraPosition);
  } else if (action is ResetLines) {
    newState.mapLines = [];
  } else if (action is RunDistance) {
    newState.runDistance = action.payload;
  } else if (action is DismissRun) {
    //print(prevState.currentUserRuns[action.payload]);
    var temp = prevState.currentUserRuns[action.payload];
    temp["color"] = prevState.currentRunsAirQualityColors[action.payload];
    newState.temporaryDismissedRun = temp;
    newState.dismissedRunIndex = action.payload;
    newState.currentUserRuns.removeAt(action.payload);
    newState.currentRunsAirQualityColors.removeAt(action.payload);
  } else if (action is RestoreRun) {
    newState.currentUserRuns.insert(
        prevState.currentDismissedRunIndex, prevState.currentDismissedRun);
    newState.currentRunsAirQualityColors.insert(
        prevState.currentDismissedRunIndex,
        prevState.currentDismissedRun["color"]);
    newState.currentUserRuns[prevState.currentDismissedRunIndex]
        .removeWhere((key, value) => key == "color");
  } else if (action is RestoreCity) {
    newState.currentCitiesAirQualityNames.insert(
        prevState.currentDismissedCityIndex,
        prevState.currentDismissedCity["name"]);
    newState.currentCitiesAirQualityColors.insert(
        prevState.currentDismissedCityIndex,
        prevState.currentDismissedCity["color"]);
    newState.currentCitiesAirQualityValues.insert(
        prevState.currentDismissedCityIndex,
        prevState.currentDismissedCity["value"]);
  } else if (action is ConfirmRunDismiss) {
    newState.currentRunsStorageManager.storeRuns(newState.currentUserRuns);
  } else if (action is ChangeTheme) {
    newState.currentThemeNotifier.switchMode();
  } else if (action is Refresh) {
    //throw ("here");
  }
  print(action.runtimeType);
  return newState;
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295; // pi/180 approximation
  var r = 6371; //earth radius in KM
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 2 * r * asin(sqrt(a));
}
