import 'dart:async';
import 'dart:ui';

import 'package:clean_run/data_search.dart';
import 'package:clean_run/redux/actions.dart';
import 'package:clean_run/size_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:redux/redux.dart';
import 'air_quality_index.dart';
import 'model/app_state.dart';
import 'openaq_services.dart';
import 'package:async/async.dart';
import 'constants.dart';
import 'package:clean_run/aqiRepresentation.dart';

class MyAir extends StatefulWidget {
  @override
  _MyAirState createState() => _MyAirState();
}

class _MyAirState extends State<MyAir> {
  static final AsyncMemoizer _memoizer = AsyncMemoizer();
  Duration dismissCancellationDuration = new Duration(seconds: 2);
  Duration dismissCancellationDurationTimer = new Duration(milliseconds: 2050);
  static bool firstConnectionSuccessful = false;
  var searchPressed;
  bool canDelete = true;
  TextStyle titleTextStyle =
      const TextStyle(fontSize: 30.0, fontFamily: "Raleway");
  bool updated = false;
  Widget titleContent = Text(
    "MyAir",
    style: TextStyle(
      fontSize: 30.0,
      fontFamily: "Raleway",
    ),
    key: Key("MyAir"),
  );
  Widget closeSearch = Container();
  List<DropdownMenuItem<String>> citiesConverted = <DropdownMenuItem<String>>[
    DropdownMenuItem<String>(
      value: "",
      child: Text(""),
    )
  ];

  String computeStringFromAddress(List<Address> value) {
    return (value?.first?.locality ?? value?.first?.subAdminArea) ??
        value?.first?.postalCode ??
        "";
  }

  Future<Null> getFutureData(Store<AppState> store) async {
    var state = store.state;
    if (state.currentInitialize) {
      List<String> cities = await getCities();

      store.dispatch(Cities(cities));
      store.dispatch(Initialize(false));

      titleContent = Text(
        "MyAir",
        style: titleTextStyle,
        key: Key("MyAir"),
      );
      var currentPositionData = await getIndexesByCoordinates(
          state.currentUserPosition.latitude,
          state.currentUserPosition.longitude,
          1000);
      if (currentPositionData != null && currentPositionData['results'] != []) {
        var currentPositionAQI =
            computeAirQualityIndex(currentPositionData['results']);
        //state.currentCitiesAirQualityNames[0] = "Current location";
        Geocoder.local
            .findAddressesFromCoordinates(Coordinates(
                state.currentUserPosition.latitude,
                state.currentUserPosition.longitude))
            .then((List<Address> value) {
          String res = computeStringFromAddress(value);
          state.currentCitiesAirQualityNames[0] = res;
          //print(res);
          if (mounted) store.dispatch(Refresh());
        });

        state.currentCitiesAirQualityValues[0] = currentPositionAQI;
        state.currentCitiesAirQualityColors[0] =
            selectColor(state.currentCitiesAirQualityValues[0]);
      } else {
        state.currentCitiesAirQualityNames[0] = "Milano";
        var airData =
            await getIndexesByCity(state.currentCitiesAirQualityNames[0], 1000);

        if (airData['results'] != []) {
          state.currentCitiesAirQualityValues[0] =
              computeAirQualityIndex(airData['results']);

          state.currentCitiesAirQualityColors[0] =
              selectColor(state.currentCitiesAirQualityValues[0]);
        }
      }
    }
    for (var i = 1; i < state.currentCitiesAirQualityNames.length; i++) {
      state.currentCitiesAirQualityColors
          .add(airQualityColors.qualityNotAvailable);
      var airData =
          await getIndexesByCity(state.currentCitiesAirQualityNames[i], 1000);
      if (airData['results'] != []) {
        state.currentCitiesAirQualityValues[i] =
            computeAirQualityIndex(airData['results']);

        state.currentCitiesAirQualityColors[i] =
            selectColor(state.currentCitiesAirQualityValues[i]);
      }
      updated = true;
    }
    firstConnectionSuccessful = true;
    return null;
  }

  getData(Store<AppState> store) {
    Future<dynamic> result = _memoizer.runOnce(() async {
      try {
        await getFutureData(store);
        print("successfully loaded data");
      } catch (e) {
        print("stackTrace:$e");
        Timer.periodic(Duration(seconds: 10), (Timer timer) {
          getFutureData(store).then((value) {
            timer.cancel();
            if (mounted) {
              setState(() {});
            }
            print("successfully loaded data");
            return;
          }).catchError((e) {
            //print("exception:$e");
            print("periodic error");
            return null;
          });
        });
      }
    });

    return result;
  }

  createCard(AppState state, int index) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(14.0),
        child: Card(
            margin: EdgeInsets.all(0),
            //elevation: 3.0,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(14.0),
                child: Container(
                  height: displayHeight(context) * 0.16,
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: getAqiGradientBoxDecoration(
                                Theme.of(context),
                                state.currentCitiesAirQualityColors[index]),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    flex: 8,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            padding: EdgeInsets.only(
                                                top: index == 0 ? 2.0 : 8.0,
                                                bottom: 0,
                                                left: 14),
                                            child: () {
                                              if (index != 0)
                                                return Text(
                                                  state.currentCitiesAirQualityNames[
                                                      index],
                                                  textAlign: TextAlign.left,
                                                  overflow: TextOverflow.clip,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .aqiCardTextColor,
                                                      fontFamily: "Raleway",
                                                      fontSize: displayHeight(
                                                              context) *
                                                          0.028,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                );
                                              else
                                                return Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      state.currentCitiesAirQualityNames[
                                                          index],
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .aqiCardTextColor,
                                                          fontFamily: "Raleway",
                                                          fontSize:
                                                              displayHeight(
                                                                      context) *
                                                                  0.028,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .person_pin_circle_outlined,
                                                      color: Colors
                                                          .blueAccent[700],
                                                    ),
                                                  ],
                                                );
                                            }()),
                                        Container(
                                            padding: EdgeInsets.only(
                                                top: index == 0 ? 6 : 8,
                                                bottom: 8,
                                                left: 14),
                                            child: Text(
                                              (airQualityColors aqi) {
                                                switch (aqi) {
                                                  case airQualityColors
                                                      .worstQuality:
                                                    return "Unhealty";
                                                  case airQualityColors
                                                      .badQuality:
                                                    return "Risky";
                                                  case airQualityColors
                                                      .goodQuality:
                                                    return "Moderate";
                                                  case airQualityColors
                                                      .bestQuality:
                                                    return "Good";
                                                  default:
                                                    return "Not Available";
                                                }
                                              }(state.currentCitiesAirQualityColors[
                                                  index]),
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .aqiCardTextColor,
                                                  fontFamily: "Raleway",
                                                  fontSize:
                                                      displayHeight(context) *
                                                          0.022,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 8, left: 14),
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .aqiCardSecondaryTextColor,
                                                fontFamily: "Raleway",
                                                fontSize:
                                                    displayHeight(context) *
                                                        0.02,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: state
                                                      .currentCitiesAirQualityValues[
                                                          index]
                                                      .toStringAsFixed(0),
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .aqiCardTextColor,
                                                      fontFamily: "Raleway",
                                                      fontSize: displayHeight(
                                                              context) *
                                                          0.022,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                    text:
                                                        ' Air Quality Index'), //(AQI)'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                        Expanded(flex: 1, child: createColumn(state, index)),
                      ]),
                ))));
  }

  createColumn(state, index) {
    return getAqiImageContainer(state.currentCitiesAirQualityColors[index]);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, AppState state) {
          var _icon = state.currentThemeNotifier.darkMode
              ? Icons.wb_sunny
              : Icons.brightness_2;
          return Scaffold(
            drawer: Drawer(
              child: SafeArea(
                minimum: EdgeInsets.only(top: displayHeight(context) * 0.15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Dark mode",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Raleway",
                            )),
                        Switch(
                          activeColor: Colors.white,
                          activeTrackColor: Colors.greenAccent[700],
                          value: state.currentThemeNotifier.darkMode,
                          onChanged: (value) {
                            setState(() {
                              if (_icon == Icons.brightness_2) {
                                _icon = Icons.wb_sunny;
                              } else {
                                _icon = Icons.brightness_2;
                              }
                              StoreProvider.of<AppState>(context)
                                  .dispatch(ChangeTheme());
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      centerTitle: true,
                      expandedHeight: displayHeight(context) * 0.15,
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        titlePadding: EdgeInsetsDirectional.only(
                          start: 72,
                          bottom: 16,
                          top: 16,
                        ),
                        centerTitle: false,
                        title: titleContent,
                      ),
                      /*actions: [
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: searchPressed,
                        )
                      ],*/
                    ),
                  ];
                },
                body: FutureBuilder(
                  future: getData(StoreProvider.of<AppState>(
                      context)), // function where you call your api
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    searchPressed = () {
                      showSearch(
                              context: context,
                              delegate: DataSearch(state.currentCities))
                          .then((value) async {
                        if (value != null) {
                          bool present = false;
                          for (var i = 0;
                              i < state.currentCitiesAirQualityNames.length;
                              i++) {
                            if (state.currentCitiesAirQualityNames[i] ==
                                value) {
                              present = true;
                            }
                          }
                          updated = false;
                          /* if (!present) {
                            var airData = await getIndexesByCity(value, 1000);
                            setState(() {
                              var res =
                                  computeAirQualityIndex(airData['results']);
                              StoreProvider.of<AppState>(context)
                                  .dispatch(CitiesAirQualityNames(value));
                              StoreProvider.of<AppState>(context)
                                  .dispatch(CitiesAirQualityValues(res));
                              StoreProvider.of<AppState>(context).dispatch(
                                  CitiesAirQualityColors(selectColor(res)));
                            });
                          }*/
                          if (!present) {
                            StoreProvider.of<AppState>(context)
                                .dispatch(CitiesAirQualityNames(value));
                            StoreProvider.of<AppState>(context)
                                .dispatch(CitiesAirQualityValues(0.0));
                            StoreProvider.of<AppState>(context).dispatch(
                                CitiesAirQualityColors(
                                    airQualityColors.qualityNotAvailable));

                            var ind = state.currentCitiesAirQualityNames
                                .indexOf(value);

                            var airData = await getIndexesByCity(value, 1000);
                            setState(() {
                              state.currentCitiesAirQualityValues[ind] =
                                  computeAirQualityIndex(airData['results']);

                              state.currentCitiesAirQualityColors[ind] =
                                  selectColor(
                                      state.currentCitiesAirQualityValues[ind]);
                            });
                          }
                        } else
                          updated = true;
                      });
                    };
                    // AsyncSnapshot<Your object type>
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SpinKitThreeBounce(
                        color: Colors.grey,
                        size: 50.0,
                      );
                    } else {
                      if (snapshot.hasError || !firstConnectionSuccessful) {
                        print('Error: ${snapshot.error}');
                        return Center(child: Text('No internet connection'));
                      } else {
                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: (state.citiesAirQualityNames.length == 1)
                              ? state.citiesAirQualityNames.length + 2
                              : state.citiesAirQualityNames.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: Card(
                                      margin: EdgeInsets.all(0),
                                      color: Theme.of(context).cardTheme.color,
                                      child: createCard(state, index)));
                            }
                            if (index == 1) {
                              return Row(
                                children: [
                                  Expanded(
                                      flex: 9,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Saved Locations",
                                            style: TextStyle(
                                              fontSize:
                                                  displayHeight(context) * 0.03,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      )),
                                  Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: IconButton(
                                          key: Key("add"),
                                          iconSize: 28,
                                          icon: Icon(
                                              Icons.add_circle_outline_rounded),
                                          onPressed: () {
                                            return !canDelete
                                                ? null
                                                : searchPressed();
                                          },
                                        ),
                                      ))
                                ],
                              );
                            }
                            if ((state.citiesAirQualityNames.length == 1)) {
                              //index==2
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "No Saved Locations",
                                  style: TextStyle(
                                    fontSize: displayHeight(context) * 0.022,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }

                            dynamic store = StoreProvider.of<AppState>(context);
                            String name =
                                state.citiesAirQualityNames[index - 1];
                            dynamic currentCity = {
                              "name": name,
                              "index": index - 1
                            };
                            var timer;
                            return Card(
                              color: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Dismissible(
                                  key: UniqueKey(),
                                  //key: Key(index.toString()),
                                  movementDuration:
                                      new Duration(milliseconds: 150),
                                  resizeDuration:
                                      new Duration(milliseconds: 300),
                                  //key: Key(index.toString()),
                                  confirmDismiss: (direction) =>
                                      Future.value(canDelete),
                                  onDismissed: (direction) {
                                    if (!canDelete) {
                                      return;
                                    }
                                    Future.delayed(Duration(milliseconds: 0),
                                        () {
                                      setState(() {});
                                    });
                                    canDelete = false;
                                    var temp = currentCity;
                                    var idx = temp["index"];
                                    temp["color"] =
                                        store.state.citiesAirQualityColors[idx];
                                    temp["value"] =
                                        store.state.citiesAirQualityValues[idx];
                                    store.state.dismissedCity = temp;
                                    store.state.dismissedCityIndex = idx;
                                    store.state.citiesAirQualityNames
                                        .removeAt(idx);
                                    store.state.citiesAirQualityColors
                                        .removeAt(idx);
                                    store.state.citiesAirQualityValues
                                        .removeAt(idx);
                                    /*for (int i = idx;
                                        i <
                                            store.state.citiesAirQualityNames
                                                .length;
                                        ++i) {
                                      print("i:$i");
                                      print(store
                                          .state.citiesAirQualityNames.length);
                                      store.state.citiesAirQualityNames[i]
                                          ["index"] -= 1;
                                    }*/
                                    // Then show a snackbar.
                                    ScaffoldState scaffold =
                                        Scaffold.of(context);
                                    scaffold.showSnackBar(() {
                                      SnackBar snackbar;
                                      snackbar = SnackBar(
                                          content: Text("Deleted Run data"),
                                          duration: dismissCancellationDuration,
                                          onVisible: () {
                                            timer = Timer(
                                                dismissCancellationDurationTimer,
                                                () {
                                              //store.dispatch(Refresh());

                                              if (store
                                                      .state
                                                      .citiesAirQualityNames
                                                      .length ==
                                                  0) {
                                                if (mounted)
                                                  store.dispatch(Refresh());
                                              }
                                              canDelete = true;
                                            });
                                          },
                                          action: SnackBarAction(
                                            label: 'Undo',
                                            onPressed: () {
                                              store.dispatch(RestoreCity());
                                              timer.cancel();
                                              canDelete = true;
                                              scaffold.removeCurrentSnackBar();
                                            },
                                          ));
                                      return snackbar;
                                    }());
                                  },
                                  // Show a red background as the item is swiped away.
                                  background: ClipRRect(
                                    borderRadius: BorderRadius.circular(14.0),
                                    child: Container(
                                      color: Colors.red,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.delete,
                                                color: Colors.white),
                                            Text('Remove',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  secondaryBackground: ClipRRect(
                                    borderRadius: BorderRadius.circular(14.0),
                                    child: Container(
                                      color: Colors.red,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('Remove',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            Icon(Icons.delete,
                                                color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: Card(
                                      margin: EdgeInsets.all(0),
                                      color: Theme.of(context).cardTheme.color,
                                      child: createCard(state, index - 1))),
                            );
                          },
                        );
                      }
                    }
                  },
                )),
          );
        });
  }
}
