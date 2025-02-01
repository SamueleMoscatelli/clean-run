import 'dart:async';

import 'package:clean_run/size_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'distance_text.dart';
import 'model/app_state.dart';
//import 'constants.dart';

class TimerText extends StatefulWidget {
  TimerText({this.stopwatch, this.appstate});
  final Stopwatch stopwatch;
  final AppState appstate;

  TimerTextState createState() =>
      new TimerTextState(stopwatch: stopwatch, appState: appstate);
}

class TimerTextState extends State<TimerText> {
  Timer timer;
  final Stopwatch stopwatch;
  final AppState appState;
  Duration duration;
  BuildContext ctx;

  TimerTextState({this.stopwatch, this.appState}) {
    duration = Duration();

    timer = new Timer.periodic(new Duration(milliseconds: 30), callback);
  }

  void callback(Timer timer) {
    if (stopwatch.isRunning && mounted) {
      duration = DateTime.now()
          .difference(StoreProvider.of<AppState>(ctx).state.currentStartTime);
      setState(() {});
    }
    if (stopwatch.elapsedMicroseconds == 0) {
      if (duration.inMilliseconds != 0 && mounted) {
        appState.runDistance = 0.0;
        duration = new Duration();
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    if (stopwatch.elapsedMicroseconds != 0) {
      duration = DateTime.now().difference(
          StoreProvider.of<AppState>(context).state.currentStartTime);
    }
    final TextStyle timerTextStyle = TextStyle(
      fontSize: displayHeight(context) * 0.038,
      fontFamily: "Raleway",
      //color: Theme.of(context).colorScheme.aqiIconColor,
    );
    String formattedTime = TimerTextFormatter.format(duration.inMilliseconds);
    return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: displayWidth(context) * 0.49,
            child: createAppbarDistanceText(appState, context),
          ),
          VerticalDivider(
              //color: Theme.of(context).colorScheme.aqiCardTextColor
              ),
          Container(
              width: displayWidth(context) * 0.49,
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Text(
                        formattedTime,
                        style: timerTextStyle,
                        key: Key("timerText"),
                      ),
                      fit: BoxFit.fitWidth,
                    ),
                    FittedBox(
                      child: Text(
                        "Time",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: displayHeight(context) * 0.018,
                          fontFamily: "Raleway",
                          //color: Theme.of(context).colorScheme.aqiIconColor,
                        ),
                      ),
                      fit: BoxFit.fitHeight,
                    ),
                  ])),
        ]);
  }
}

class TimerTextFormatter {
  static String format(int milliseconds) {
    //print(milliseconds);
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr =
        (hours != 0) ? hours.toString().padLeft(2, '0') + ":" : "";
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');

    return "$hoursStr$minutesStr:$secondsStr:$hundredsStr";
  }
}
