import 'package:clean_run/air_quality_index.dart';
import 'package:clean_run/model/app_state.dart';
import 'package:clean_run/openaq_services.dart';
import 'package:clean_run/redux/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:clean_run/timer_text.dart';
import 'package:clean_run/size_helpers.dart';
import 'dart:math' show cos, sqrt, asin;
import 'NotificationPlugin.dart';
import 'constants.dart';
import 'location.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String selectedStyle =
      'mapbox://styles/samuelemoscatelli/ckhvu6z990qiq19pa94e5u65h';
  Location loc;
  String message;
  var currentUserRun;
  MapboxMap mapbox;
  airQualityColors appBarColor;
  ThemeData currentTheme;
  Text appBarText = Text(
    "AQI calculation..",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 30.0,
      fontFamily: "Raleway",
      //color: Colors.black
    ),
  );
  Text aqiText = Text(
    "-",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 25.0,
      fontFamily: "Raleway",
      //color: Colors.black
    ),
  );
  double mapInitialZoom = 14;
  /*@override
  void initState() {
    super.initState();
    loc = new Location();
    loc.onLocationChanged.listen((LocationData cLoc) {
      StoreProvider.of<AppState>(context).dispatch(CurrentPosition(
          Position(latitude: cLoc.latitude, longitude: cLoc.longitude)));
    });
  }*/

  @override
  void initState() {
    super.initState();
    notificationPlugin
        .setListenerForLowerVersions(onNotificationInLowerVersions);
    notificationPlugin.setOnNotificationClick(onNotificationClick);
  }

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {
    print('Notification Received ${receivedNotification.id}');
  }

  onNotificationClick(String payload) {
    print('Payload $payload');
  }

  setMarkers(controller, state) async {
    controller.getVisibleRegion().then((visibleRegion) {
      //var ne = visibleRegion.northeast;
      //var sw = visibleRegion.southwest;
      //var n = ne.latitude;
      //var e = ne.longitude;
      //var w = sw.longitude;
      //var s = sw.latitude;
      //var center = LatLng((n + s) / 2, (e + w) / 2);
      var center = state.currentUserPosition;
      var radius;

      if (controller.cameraPosition.zoom >= 14) {
        radius = 1000;
      } else if (controller.cameraPosition.zoom >= 10) {
        radius = 10000;
      } else {
        radius = 100000;
      }
      getIndexesByCoordinates(num.parse(center.latitude.toStringAsFixed(8)),
              num.parse(center.longitude.toStringAsFixed(8)), radius)
          .then((airData) {
        bool red = false;
        bool orange = false;
        bool yellow = false;
        double totAqi = 0;

        var resultList = [];
        if (airData != null) {
          resultList = airData['results'];
        }

        for (var res in resultList) {
          var lat = res['coordinates']['latitude'];
          var lon = res['coordinates']['longitude'];
          var aqi = computeAirQualityIndex([res]);
          var aqiColor = selectColor(aqi);
          var distance = calculateDistance(state.currentUserPosition.latitude,
              state.currentUserPosition.longitude, lat, lon);

          totAqi += aqi;

          if (aqiColor == "squat-marker-red" && distance < 1) {
            red = true;
          } else if (aqiColor == "squat-marker-orange" && distance < 1) {
            orange = true;
          } else if (aqiColor == "squat-marker-yellow" && distance < 1) {
            yellow = true;
          }
          /*controller.addCircle(CircleOptions(
              geometry: LatLng(lat, lon),
              circleRadius: 10,
              circleColor: selectColor(aqi)));*/

          controller.addSymbol(SymbolOptions(
            geometry: LatLng(lat, lon),
            iconImage: aqiColor,
          ));

          if (state.currentStopWatch.isRunning) {
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
        int totRes = 1;
        if (resultList.length != 0) {
          totRes = airData['results'].length;
        }
        int meanAqi = (totAqi / totRes).truncate();
        bool toBeUpdated = false;

        if (!mounted) {
          //do nothing
        } else if (red && appBarColor != airQualityColors.worstQuality) {
          message = "Warning, unhealty air!";
          toBeUpdated = true;
          appBarColor = airQualityColors.worstQuality;
        } else if (orange &&
            appBarColor != airQualityColors.worstQuality &&
            appBarColor != airQualityColors.badQuality) {
          appBarColor = airQualityColors.badQuality;
          message = "Warning, risky air!";
          toBeUpdated = true;
        } else if (yellow &&
            appBarColor != airQualityColors.worstQuality &&
            appBarColor != airQualityColors.badQuality &&
            appBarColor != airQualityColors.goodQuality) {
          appBarColor = airQualityColors.goodQuality;
          message = "Moderate good air";
          toBeUpdated = true;
        } else if (!yellow &&
            !orange &&
            !red &&
            appBarColor != airQualityColors.bestQuality) {
          appBarColor = airQualityColors.bestQuality;
          message = "Good air";
          toBeUpdated = true;
        }
        if (mounted && toBeUpdated) {
          setState(() {
            appBarText = Text(
              message,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
                fontFamily: "Raleway",
                //color: Theme.of(context).colorScheme.aqiIconColor,
              ),
            );
            aqiText = Text(
              "AQI: " + meanAqi.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
                fontFamily: "Raleway",
                //color: Theme.of(context).colorScheme.aqiIconColor,
              ),
            );
          });
        }
      });
    });
    //var center = LatLng(visibleRegionBounds[0], longitude)
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  selectColor(aqi) {
    var col;
    var red = "squat-marker-red";
    var orange = "squat-marker-orange";
    var yellow = "squat-marker-yellow";
    var green = "squat-marker-green";
    if (aqi < 51) {
      col = green;
    } else if (aqi < 100) {
      col = yellow;
    } else if (aqi < 150) {
      col = orange;
    } else {
      col = red;
    }
    return col;
  }

  setCamera(controller) {
    getCurrentLocation().then((currentPosition) {
      if (mounted)
        controller.moveCamera(CameraUpdate.newLatLngZoom(
            LatLng(currentPosition.latitude, currentPosition.longitude),
            mapInitialZoom));
    });
  }

  String computeStringFromAddress(List<Address> value) {
    //print(value?.first?.toMap());
    //return value?.first?.addressLine ?? "not Available"
    String firstPart = (value?.first?.thoroughfare ?? "");

    String secondPart =
        (value?.first?.locality ?? value?.first?.subAdminArea) ??
            value?.first?.postalCode ??
            "";
    if (firstPart != "" && secondPart != "") {
      return firstPart + " , " + secondPart;
    }
    if (firstPart != "") {
      return firstPart;
    }
    return secondPart;
  }

  MapboxMap createMap(AppState state) {
    mapbox = MapboxMap(
      trackCameraPosition: true,
      onCameraTrackingChanged: (location) {},
      onCameraIdle: () {
        if (state.currentMapController != null) {
          setMarkers(state.currentMapController, state);
        }
      },
      styleString: selectedStyle,
      onMapCreated: (controller) {
        setCamera(controller);
        state.setMapController(controller);
        for (var circle in state.currentMapLines) {
          Future.delayed(Duration(milliseconds: 200), () {
            controller.addCircle(CircleOptions(
                geometry: circle, circleRadius: 6, circleColor: "#0046FF"));
          });
        }
      },
      initialCameraPosition: CameraPosition(
          target: LatLng(state.currentUserPosition.latitude,
              state.currentUserPosition.longitude),
          zoom: mapInitialZoom),
      myLocationEnabled: true,
      onUserLocationUpdated: (location) {
        if (state.currentMapController != null && mounted) {
          setMarkers(state.currentMapController, state);
        }
        /*
        Position userPosition = Position(
            latitude: location.position.latitude,
            longitude: location.position.longitude);

        if (state.stopWatch.isRunning) {
          LatLng lineStart = LatLng(
              state.currentPosition.latitude, state.currentPosition.longitude);

          LatLng lineEnd =
              LatLng(userPosition.latitude, userPosition.longitude);
          List<LatLng> line = [lineStart, lineEnd];
          LineOptions lineOptions = LineOptions(
              geometry: line, lineWidth: 12, lineColor: "#0046FF", lineBlur: 4);
          state.mapController.addLine(lineOptions);
          state.mapLines.add(lineOptions);

          /*   newState.mapController.moveCamera(
        CameraUpdate.newLatLng(
          LatLng(action.payload.latitude, action.payload.longitude),
        ),
      );*/

          double distance = calculateDistance(lineStart.latitude,
              lineStart.longitude, lineEnd.latitude, lineEnd.longitude);

          state.runDistance += distance;
        }

        state.currentPosition = userPosition;*/
      },
    );
    return mapbox;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        if (state.currentStopWatch.isRunning) {
          mapInitialZoom = 16;
        }
        if (currentTheme == null) {
          currentTheme = Theme.of(context);
        }
        /*var _icon = state.currentThemeNotifier.darkMode
            ? Icons.wb_sunny
            : Icons.brightness_2;*/
        return Scaffold(
          appBar: AppBar(
            title: Container(
              height: displayHeight(context) * 0.20,
              child: FittedBox(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      appBarText,
                      aqiText,
                      Divider(
                        color: Theme.of(context).colorScheme.aqiCardTextColor,
                      ),
                      IntrinsicHeight(
                        child: TimerText(
                          stopwatch: state.currentStopWatch,
                          appstate: state,
                        ), /*Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: displayWidth(context) * 0.50,
                                child: createAppbarDistanceText(state),
                              ),
                              VerticalDivider(
                                color: Colors.black87,
                              ),
                              Container(
                                width: displayWidth(context) * 0.50,
                                child: TimerText(
                                  stopwatch: state.currentStopWatch,
                                  appstate: state,
                                ),
                              ),
                            ]),*/
                      ),
                    ]),
                fit: BoxFit.scaleDown,
              ),
            ),
            backgroundColor: (appBarColor != null)
                ? getAqiColor(Theme.of(context), appBarColor)
                : Theme.of(context).appBarTheme.color,
            centerTitle: true,
            toolbarHeight: displayHeight(context) * 0.25,
            /*actions: <Widget>[
              IconButton(
                icon: Icon(
                  _icon,
                  //color: Theme.of(context).colorScheme.secondary,
                  color: Theme.of(context).textTheme.bodyText1.color,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    if (_icon == Icons.brightness_2) {
                      _icon = Icons.wb_sunny;
                    } else {
                      _icon = Icons.brightness_2;
                    }
                    StoreProvider.of<AppState>(context).dispatch(ChangeTheme());
                  });
                },
              ),
            ],*/
          ),
          body: createMap(state),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                child: Icon(Icons.place),
                onPressed: () {
                  state.currentMapController.moveCamera(
                    CameraUpdate.newLatLng(
                      LatLng(state.currentUserPosition.latitude,
                          state.currentUserPosition.longitude),
                    ),
                  );
                },
              ),
              SizedBox(height: 15),
              FloatingActionButton(
                key: Key("Start"),
                child: Text(state.currentChronoButtonLabel),
                onPressed: () {
                  if (state.currentStopWatch.isRunning) {
                    state.currentStopWatch.stop();
                    setState(() {
                      StoreProvider.of<AppState>(context)
                          .dispatch(ChronoButtonLabel("Start"));

                      StoreProvider.of<AppState>(context)
                          .dispatch(ActivityOn(false));
                    });
                  } else {
                    // create user run data
                    if (state.currentStopWatch.elapsed.inMicroseconds == 0.0) {
                      DateTime now = new DateTime.now();
                      StoreProvider.of<AppState>(context)
                          .state
                          .currentStartTime = now;

                      String temp = now.toString();

                      currentUserRun = {
                        "aqis": [],
                        "distance": 0.0,
                        //"lastPosition": Position(latitude: 0, longitude: 0),
                        "measurementsDistances": [],
                        "startTime": temp,
                      };
                      currentUserRun["lastPosition"] = "";
                      var run = currentUserRun;
                      currentUserRun["waitingStartPosition"] = Geocoder.local
                          .findAddressesFromCoordinates(Coordinates(
                              state.currentUserPosition.latitude,
                              state.currentUserPosition.longitude))
                          .then((List<Address> value) {
                        //print(value.first.toMap());
                        String res = computeStringFromAddress(value);
                        run["startPosition"] = res;
                        //print(res);
                      }).catchError((e) {
                        run["startPosition"] = "Not Available";
                      });
                      StoreProvider.of<AppState>(context)
                          .dispatch(StartRun(currentUserRun));
                    }
                    state.currentStopWatch.start();
                    setState(() {
                      StoreProvider.of<AppState>(context)
                          .dispatch(ChronoButtonLabel("Pause"));

                      state.currentMapController.moveCamera(
                          CameraUpdate.newLatLngZoom(
                              LatLng(state.currentPosition.latitude,
                                  state.currentPosition.longitude),
                              16));

                      StoreProvider.of<AppState>(context)
                          .dispatch(ActivityOn(true));
                    });
                  }
                },
              ),
              SizedBox(height: 15),
              FloatingActionButton(
                key: Key("Stop"),
                child: Text("Stop"),
                onPressed: () {
                  if (state.currentStopWatch.elapsed.inMicroseconds > 0.0) {
                    setState(() {
                      state.currentStopWatch.stop();
                      StoreProvider.of<AppState>(context)
                          .dispatch(ChronoButtonLabel("Start"));
                      // save run time and then reset
                      state.currentRun["time"] = state.currentStopWatch.elapsed;
                      state.currentStopWatch.reset();

                      StoreProvider.of<AppState>(context)
                          .dispatch(ActivityOn(false));

                      state.currentRun["distance"] = state.currentRunDistance;
                      state.currentMapController.moveCamera(
                          CameraUpdate.newLatLng(LatLng(
                              state.currentPosition.latitude,
                              state.currentPosition.longitude)));
                      var run = state.currentRun;
                      state.currentRun["waitingLastPosition"] = Geocoder.local
                          .findAddressesFromCoordinates(Coordinates(
                              state.currentUserPosition.latitude,
                              state.currentUserPosition.longitude))
                          .then((List<Address> value) {
                        String res = computeStringFromAddress(value);
                        run["lastPosition"] = res;
                        //print(res);
                      }).catchError((e) {
                        run["lastPosition"] = "Not Available";
                      });
                      state.runDistance = 0.0;
                      StoreProvider.of<AppState>(context)
                          .dispatch(ResetLines());
                      Future.delayed(Duration(seconds: 0), () {
                        state.currentMapController.clearCircles();
                      });

                      // zeros the distance
                      StoreProvider.of<AppState>(context)
                          .dispatch(RunDistance(0.0));
                      StoreProvider.of<AppState>(context).dispatch(EndRun());
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
