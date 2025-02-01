import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'package:clean_run/constants.dart';
import 'package:clean_run/location.dart';
import 'package:clean_run/redux/actions.dart';
import 'package:clean_run/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:clean_run/home_screen.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:redux/redux.dart';
import 'NotificationPlugin.dart';
import 'air_quality_index.dart';
import 'aqiRepresentation.dart';
import 'model/app_state.dart';
import 'myair_screen.dart';
import 'package:background_location/background_location.dart';
import 'package:location_permissions/location_permissions.dart';

import 'openaq_services.dart';

class Nav extends StatefulWidget {
  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> with WidgetsBindingObserver {
  LatLng lastForMyAir;
  int _selectedIndex = 0;
  StreamSubscription<Position> positionStream;
  Position position;
  airQualityColors positionColor = airQualityColors.bestQuality;
  bool justInBackground = true;
  List<Widget> _widgetOption = <Widget>[
    MyAir(),
    Home(),
    Statistics(),
  ];
  static AppLifecycleState lastState = AppLifecycleState.resumed;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.detached) {
      justInBackground = true;
      BackgroundLocation.stopLocationService();
    } else if ((state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused) &&
        StoreProvider.of<AppState>(context).state.stopWatch.isRunning) {
      if (lastState == AppLifecycleState.resumed) {
        BackgroundLocation.startLocationService(distanceFilter: 0.1);
        BackgroundLocation.getLocationUpdates((Location location) {
          var center =
              StoreProvider.of<AppState>(context).state.currentPosition;

          getIndexesByCoordinates(num.parse(center.latitude.toStringAsFixed(8)),
                  num.parse(center.longitude.toStringAsFixed(8)), 1000)
              .then((airData) {
            bool red = false;
            bool orange = false;
            bool yellow = false;

            var resultList = [];
            if (airData != null) {
              resultList = airData['results'];
            }

            for (var res in resultList) {
              var lat = res['coordinates']['latitude'];
              var lon = res['coordinates']['longitude'];
              var aqi = computeAirQualityIndex([res]);
              var aqiColor = selectColor(aqi);
              var distance = calculateDistance(
                  center.latitude, center.longitude, lat, lon);

              if (aqiColor == airQualityColors.worstQuality && distance < 1) {
                red = true;
              } else if (aqiColor == airQualityColors.badQuality &&
                  distance < 1) {
                orange = true;
              } else if (aqiColor == airQualityColors.goodQuality &&
                  distance < 1) {
                yellow = true;
              }
              /*controller.addCircle(CircleOptions(
              geometry: LatLng(lat, lon),
              circleRadius: 10,
              circleColor: selectColor(aqi)));*/

              if (StoreProvider.of<AppState>(context)
                  .state
                  .currentStopWatch
                  .isRunning) {
                if (distance < 1) {
                  //print(StoreProvider.of<AppState>(context).state.currentRun);
                  StoreProvider.of<AppState>(context)
                      .state
                      .currentRun["aqis"]
                      .add(aqi);
                  StoreProvider.of<AppState>(context)
                      .state
                      .currentRun["measurementsDistances"]
                      .add(distance);
                }
              }
            }

            if (red &&
                positionColor != airQualityColors.worstQuality &&
                !justInBackground) {
              positionColor = airQualityColors.worstQuality;
              notificationPlugin.showNotification("Unhealthy air!",
                  "Warning! You are entering in a zone where the air quality is unhealthy.");
            } else if (orange &&
                positionColor != airQualityColors.badQuality &&
                !justInBackground) {
              positionColor = airQualityColors.badQuality;
              notificationPlugin.showNotification("Risky air!",
                  "Warning! You are entering in a zone where the air quality is risky.");
            } else if (yellow &&
                positionColor != airQualityColors.goodQuality &&
                !justInBackground) {
              positionColor = airQualityColors.goodQuality;
              notificationPlugin.showNotification("Moderate good air!",
                  "You are entering in a zone where the air quality is moderate good.");
            } else if (!yellow &&
                !orange &&
                !red &&
                positionColor != airQualityColors.bestQuality &&
                !justInBackground) {
              positionColor = airQualityColors.bestQuality;
              notificationPlugin.showNotification("Good air!",
                  "You are entering in a zone where the air quality is good.");
            }
            if (justInBackground) {
              justInBackground = false;
            }
          });

          //print("updated: ${location.toMap()}");
          return null;
        });
      }
    }
    lastState = state;
  }

  @override
  void initState() {
    super.initState();
    LocationPermissions().requestPermissions().then((permission) {
      WidgetsBinding.instance.addObserver(this);
      getCurrentLocation().then((currentPosition) {
        StoreProvider.of<AppState>(context)
            .dispatch(CurrentPosition(currentPosition));
      });
    });
    /*LocationOptions locationOptions =
        LocationOptions(accuracy: LocationAccuracy.medium);
    positionStream = Geolocator()
        .getPositionStream(locationOptions)
        .listen((Position position) {
      StoreProvider.of<AppState>(context)
          .dispatch(ChangeCameraPosition(position));
      //StoreProvider.of<AppState>(context).dispatch(CurrentPosition(position));
    });*/
  }

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  String computeStringFromAddress(List<Address> value) {
    return (value?.first?.locality ?? value?.first?.subAdminArea) ??
        value?.first?.postalCode ??
        "";
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          Store<AppState> store = StoreProvider.of<AppState>(context);
          LocationPermissions().checkPermissionStatus().then((permission) {
            if (permission == PermissionStatus.granted) {
              LocationOptions locationOptions =
                  LocationOptions(accuracy: LocationAccuracy.medium);
              positionStream = Geolocator()
                  .getPositionStream(locationOptions)
                  .listen((Position position) {
                if (state.stopWatch.isRunning) {
                  LatLng pos = LatLng(state.currentPosition.latitude,
                      state.currentPosition.longitude);
                  CircleOptions circle = CircleOptions(
                      geometry: pos, circleRadius: 6, circleColor: "#0046FF");

                  if (state.mapLines.isNotEmpty) {
                    double distanceWithLast = calculateDistance(
                        pos.latitude,
                        pos.longitude,
                        state.mapLines.last.latitude,
                        state.mapLines.last.longitude);
                    if (distanceWithLast >= 0.010) {
                      if (state.mapController != null)
                        state.mapController.addCircle(circle);
                      state.mapLines.add(pos);
                    }
                  } else {
                    if (state.mapController != null)
                      state.mapController.addCircle(circle);
                    state.mapLines.add(pos);
                  }

                  LatLng lineStart = LatLng(state.currentPosition.latitude,
                      state.currentPosition.longitude);

                  LatLng lineEnd =
                      LatLng(position.latitude, position.longitude);
                  /*List<LatLng> line = [lineStart, lineEnd];
              LineOptions lineOptions = LineOptions(
                geometry: line,
                lineWidth: 12,
                lineColor: "#0046FF",
                //lineBlur: 4
              );
              state.mapController?.addLine(lineOptions);
              state.mapLines.add(line);*/

                  /*   newState.mapController.moveCamera(
        CameraUpdate.newLatLng(
          LatLng(action.payload.latitude, action.payload.longitude),
        ),
      );*/

                  double distance = calculateDistance(lineStart.latitude,
                      lineStart.longitude, lineEnd.latitude, lineEnd.longitude);

                  state.runDistance += distance;
                }

                LatLng pos = LatLng(position.latitude, position.longitude);

                state.currentPosition = position;
                lastForMyAir = lastForMyAir ?? pos;
                double distanceForMyAir = calculateDistance(
                    lastForMyAir.latitude,
                    lastForMyAir.longitude,
                    pos.latitude,
                    pos.longitude);

                if (distanceForMyAir >= 1.00) {
                  lastForMyAir = pos;
                  Future.delayed(Duration(seconds: 0), () async {
                    var currentPositionData = await getIndexesByCoordinates(
                        state.currentUserPosition.latitude,
                        state.currentUserPosition.longitude,
                        1000);
                    if (currentPositionData != null &&
                        currentPositionData['results'] != []) {
                      var currentPositionAQI = computeAirQualityIndex(
                          currentPositionData['results']);

                      await Geocoder.local
                          .findAddressesFromCoordinates(Coordinates(
                              state.currentUserPosition.latitude,
                              state.currentUserPosition.longitude))
                          .then((List<Address> value) {
                        String res = computeStringFromAddress(value);
                        state.currentCitiesAirQualityNames[0] = res;
                        //print(res);
                      }).catchError((e) {
                        print("exception:$e");
                        //print("periodic error");
                        return null;
                      });

                      state.currentCitiesAirQualityValues[0] =
                          currentPositionAQI;
                      state.currentCitiesAirQualityColors[0] =
                          selectColor(state.currentCitiesAirQualityValues[0]);
                      store.dispatch(Refresh());
                    }
                  });
                }
              });
            }
          });
          return Scaffold(
            /*appBar: AppBar(
        title: Text("Bottom nav bar"),
      ),*/
            body: Center(
              child: _widgetOption.elementAt(_selectedIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              key: Key("NavBar"),
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.ac_unit),
                  label: "MyAir",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.public),
                  label: "Map",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.show_chart),
                  label: "Statistics",
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTap,
            ),
          );
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BackgroundLocation.stopLocationService();
    positionStream.cancel();
    super.dispose();
  }
}
