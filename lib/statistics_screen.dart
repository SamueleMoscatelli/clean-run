import 'dart:async';
import 'dart:convert';
import 'package:clean_run/aqiRepresentation.dart';
import 'package:clean_run/model/app_state.dart';
import 'package:clean_run/redux/actions.dart';
import 'package:clean_run/size_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:math';
import 'constants.dart';
import 'package:async/async.dart';

class Statistics extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  static bool canDelete = true;
  static final AsyncMemoizer _memoizer = AsyncMemoizer();
  Duration dismissCancellationDuration = new Duration(seconds: 2);
  Duration dismissCancellationDurationTimer = new Duration(milliseconds: 2050);
  TextStyle titleTextStyle =
      const TextStyle(fontSize: 30.0, fontFamily: "Raleway");

  bool updated = false;

  Widget titleContent = Text(
    "Statistics",
    style: TextStyle(fontSize: 30.0, fontFamily: "Raleway"),
    key: Key("Statistics"),
  );

  getData(state) async {
    await _memoizer.runOnce(() async {
      //use also here memoizer? or should direcly redo everytime since list may change after a new run?
      if (state.initializeRuns) {
        List<Map<String, dynamic>> runs = await state.storedRuns;
        StoreProvider.of<AppState>(context).dispatch(StoredRuns(runs ?? []));
        StoreProvider.of<AppState>(context).dispatch(RunsInitialize(false));
      }
    });
    titleContent =
        Text("Statistics", style: titleTextStyle, key: Key("Statistics"));
    for (var i = 0; i < state.currentUserRuns.length; ++i) {
      double aqi = findAQI(state.currentUserRuns[i]);
      state.currentRunsAirQualityColors.add(
          aqi != 0.0 ? selectColor(aqi) : airQualityColors.qualityNotAvailable);
    }
  }

  createCard(AppState state, int index) {
    /*if (index == 0) {
      return Text("");
    }*/

    return Card(
        margin: EdgeInsets.all(0),

        //elevation: 3.0,
        child: Container(
          padding: EdgeInsets.all(12),
          //height: displayHeight(context) * 0.5,
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: () {
                              BoxConstraints constraints = BoxConstraints(
                                minWidth: 0.15 * displayWidth(context),
                                maxWidth: 0.2 * displayWidth(context),
                                minHeight: 0.05 * displayHeight(context),
                                maxHeight: 0.07 * displayHeight(context),
                              );
                              List<Widget> res = [];
                              res.add(Container(
                                padding: const EdgeInsets.only(top: 10),
                                child: formatDate(
                                    state.currentUserRuns[index - 1]),
                              ));

                              LineSplitter ls = new LineSplitter();
                              List<String> lines = ls.convert(prepareContent(
                                  state.currentUserRuns[index - 1]));

                              res.add(Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Icon(
                                              Icons.directions_run_rounded),
                                        ),
                                        Text(" " + lines[1],
                                            style: TextStyle(
                                                fontFamily: "Raleway",
                                                fontSize:
                                                    displayHeight(context) *
                                                        0.02))
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          child:
                                              Icon(Icons.emoji_flags_rounded),
                                        ),
                                        Text(" " + lines[3],
                                            style: TextStyle(
                                                fontFamily: "Raleway",
                                                fontSize:
                                                    displayHeight(context) *
                                                        0.02))
                                      ],
                                    ),
                                    Divider(),
                                  ],
                                ),
                              ));

                              res.add(Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        lines[5],
                                        style: TextStyle(
                                          fontSize:
                                              displayHeight(context) * 0.030,
                                          fontFamily: "Raleway",
                                        ),
                                      ),
                                      Text(
                                        "Time (hh:mm:ss:ms)",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              displayHeight(context) * 0.015,
                                          fontFamily: "Raleway",
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: displayWidth(context) * 0.40,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                lines[7],
                                                style: TextStyle(
                                                  fontSize:
                                                      displayHeight(context) *
                                                          0.030,
                                                  fontFamily: "Raleway",
                                                ),
                                              ),
                                              Text(
                                                "Distance (km)",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      displayHeight(context) *
                                                          0.015,
                                                  fontFamily: "Raleway",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: displayWidth(context) * 0.40,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                lines[9],
                                                style: TextStyle(
                                                  fontSize:
                                                      displayHeight(context) *
                                                          0.030,
                                                  fontFamily: "Raleway",
                                                ),
                                              ),
                                              Text(
                                                "Average Speed (km/h)",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      displayHeight(context) *
                                                          0.015,
                                                  fontFamily: "Raleway",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        (aqi) {
                                          if (aqi == 0.0)
                                            return "-";
                                          else
                                            return aqi.toStringAsFixed(2);
                                        }(findAQI(
                                            state.currentUserRuns[index - 1])),
                                        style: TextStyle(
                                          fontSize:
                                              displayHeight(context) * 0.030,
                                          fontFamily: "Raleway",
                                        ),
                                      ),
                                      Text(
                                        "Mean AQI",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              displayHeight(context) * 0.015,
                                          fontFamily: "Raleway",
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ));

                              if (true
                                  //state.currentRunsAirQualityColors[index - 1] !=airQualityColors.qualityNotAvailable.value
                                  )
                                res.add(
                                  Container(
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ConstrainedBox(
                                              constraints: constraints,
                                              child: FittedBox(
                                                  child: Icon(
                                                      (airQualityColors value) {
                                                if (value ==
                                                    airQualityColors
                                                        .bestQuality)
                                                  return Icons
                                                      .sentiment_very_satisfied_outlined;
                                                if (value ==
                                                    airQualityColors
                                                        .goodQuality)
                                                  return Icons
                                                      .sentiment_satisfied_outlined;
                                                if (value ==
                                                    airQualityColors.badQuality)
                                                  return Icons
                                                      .sentiment_neutral_outlined;
                                                if (value ==
                                                    airQualityColors
                                                        .worstQuality)
                                                  return Icons
                                                      .sentiment_dissatisfied_outlined;
                                                return Icons
                                                    .sentiment_neutral_outlined;
                                              }(state.currentRunsAirQualityColors[
                                                          index - 1])))),
                                          ConstrainedBox(
                                            constraints: constraints,
                                            child: Card(
                                                //elevation: 3.0,
                                                color: getAqiColor(
                                                    Theme.of(context),
                                                    state.currentRunsAirQualityColors[
                                                        index - 1]),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          14.0),
                                                )),
                                          ),
                                          ConstrainedBox(
                                            constraints: constraints,
                                            child: Card(
                                                //elevation: 3.0,
                                                color: getAqiColor(
                                                  Theme.of(context),
                                                  (state.currentRunsAirQualityColors[
                                                              index - 1] !=
                                                          airQualityColors
                                                              .bestQuality)
                                                      ? state.currentRunsAirQualityColors[
                                                          index - 1]
                                                      : airQualityColors
                                                          .qualityNotAvailable,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          14.0),
                                                )),
                                          ),
                                          ConstrainedBox(
                                            constraints: constraints,
                                            child: Card(
                                              //elevation: 3.0,
                                              color: getAqiColor(
                                                  Theme.of(context),
                                                  (state.currentRunsAirQualityColors[
                                                                  index - 1] !=
                                                              airQualityColors
                                                                  .bestQuality &&
                                                          state.currentRunsAirQualityColors[
                                                                  index - 1] !=
                                                              airQualityColors
                                                                  .goodQuality)
                                                      ? state.currentRunsAirQualityColors[
                                                          index - 1]
                                                      : airQualityColors
                                                          .qualityNotAvailable),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14.0),
                                              ),
                                            ),
                                          ),
                                          ConstrainedBox(
                                            constraints: constraints,
                                            child: Card(
                                              //elevation: 3.0,
                                              color: getAqiColor(
                                                  Theme.of(context),
                                                  (state.currentRunsAirQualityColors[
                                                              index - 1] ==
                                                          airQualityColors
                                                              .worstQuality)
                                                      ? airQualityColors
                                                          .worstQuality
                                                      : airQualityColors
                                                          .qualityNotAvailable),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14.0),
                                              ),
                                            ),
                                          )
                                        ]),
                                  ),
                                );
                              return res;
                            }(),
                          ),
                        ),
                      ]),
                ),
              ]),
        ));
  }

  String prepareContent(Map run) {
    String temp = "";
    if ((run["startPosition"] ?? "") != "") {
      String startPos = run["startPosition"];
      String lastPos = (run["lastPosition"] ?? "");
      temp += "Started at : \n" + startPos;
      if (lastPos != "") {
        temp += "\nEnded at : \n" + lastPos;
      }
      temp += "\n";
    }
    temp += "Time: \n" +
        ((run["time"] != null)
            ? ((run["time"].inHours != 0)
                    ? (run["time"].inHours.toString().padLeft(2, "0") + ":")
                    : "00:") +
                (run["time"].inMinutes % 60).toString().padLeft(2, "0") +
                ":" +
                (run["time"].inSeconds % 60).toString().padLeft(2, "0") +
                ":" +
                ((run["time"].inMilliseconds % 1000)).toString().padLeft(3, "0")
            : "not Finished");
    temp += "\n";
    //print(run["distance"]);
    temp +=
        "Traveled Distance: \n" + run["distance"].toStringAsFixed(3) + " \n";

    var distanceKm = run["distance"];
    var timeMs = run["time"].inMilliseconds;
    var hourInMs = 1000 * 60 * 60;
    var speedKmPerH = (distanceKm / (timeMs / hourInMs));

    temp += "Average Speed: \n" + speedKmPerH.toStringAsFixed(3);
    if (run["aqis"].length > 1) {
      var best = run["aqis"].reduce((double current, double previous) {
        return max(current, previous);
      }).toStringAsFixed(2);
      var worst = run["aqis"].reduce((double current, double previous) {
        return min(current, previous);
      }).toStringAsFixed(2);

      if (best != worst) {
        temp += "\nworst Aqi:" +
            run["aqis"].reduce((double current, double previous) {
              return max(current, previous);
            }).toStringAsFixed(2) +
            "\n" +
            "best Aqi:" +
            run["aqis"].reduce((double current, double previous) {
              return min(current, previous);
            }).toStringAsFixed(2);
      }
    }
    return temp;
  }

  Widget formatDate(Map<String, dynamic> run) {
    var date = run["startTime"].split(" ");
    var hour = date[1].split(":");
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.date_range),
            Text(
              " " + date[0],
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Raleway",
                  fontSize: displayHeight(context) * 0.025),
            ),
          ],
        ),
        Text(
          hour[0] + ":" + hour[1],
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "Raleway",
              fontSize: displayHeight(context) * 0.021),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          /*var _icon = state.currentThemeNotifier.darkMode
              ? Icons.wb_sunny
              : Icons.brightness_2;*/
          return Scaffold(
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
                        centerTitle: false,
                        title: titleContent,
                      ),
                    ),
                  ];
                },
                body: FutureBuilder(
                  future: getData(state), // function where you call your api
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SpinKitThreeBounce(
                        color: Colors.grey,
                        size: 50.0,
                      );
                    } else {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        var timer;
                        var store = StoreProvider.of<AppState>(context);
                        if (state.currentUserRuns.length == 0) {
                          return Center(
                              child: Text(
                            "No activities to visualize",
                            style: TextStyle(
                                fontSize: displayHeight(context) * 0.02,
                                fontFamily: "Raleway",
                                color: Colors.grey[400]),
                          ));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: state.currentUserRuns.length,
                          itemBuilder: (BuildContext context, int index) {
                            /*if (index == 0) {
                              return createCard(state, index);
                            }*/
                            if (index > state.currentUserRuns.length) {
                              return Text("");
                            }
                            index += 1;
                            Map<String, dynamic> currentRun =
                                state.currentUserRuns[index - 1];
                            currentRun["index"] = index - 1;
                            return Card(
                              color: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Dismissible(
                                  movementDuration:
                                      new Duration(milliseconds: 150),
                                  resizeDuration:
                                      new Duration(milliseconds: 300),
                                  key: Key(index.toString()),
                                  confirmDismiss: (direction) =>
                                      Future.value(canDelete),
                                  onDismissed: (direction) {
                                    if (!canDelete) {
                                      return;
                                    }

                                    canDelete = false;
                                    var temp = currentRun;
                                    var idx = temp["index"];
                                    temp["color"] = store
                                        .state.currentRunsAirQualityColors[idx];

                                    store.state.temporaryDismissedRun = temp;
                                    store.state.dismissedRunIndex = idx;
                                    store.state.currentUserRuns.removeAt(idx);
                                    store.state.currentRunsAirQualityColors
                                        .removeAt(idx);
                                    /*for (int i = idx;
                                        i < store.state.currentUserRuns.length;
                                        ++i) {
                                      print("i:$i");
                                      print(store.state.currentUserRuns.length);
                                      store.state.currentUserRuns[i]["index"] -=
                                          1;
                                    }*/
                                    store.dispatch(Refresh());
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
                                              //store.dispatch(ConfirmRunDismiss());
                                              store.state
                                                  .currentRunsStorageManager
                                                  .storeRuns(store
                                                      .state.currentUserRuns);
                                              if (store.state.currentUserRuns
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
                                              store.dispatch(RestoreRun());
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
                                      child: createCard(state, index))),
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
