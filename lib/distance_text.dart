import 'dart:ui';
import 'package:clean_run/size_helpers.dart';
import 'package:flutter/material.dart';
//import 'constants.dart';

createAppbarDistanceText(state, context) {
  final TextStyle distanceTextStyle = TextStyle(
    fontSize: displayHeight(context) * 0.038,
    fontFamily: "Raleway",
    //color: Theme.of(context).colorScheme.aqiIconColor,
  );
  String formattedDistance =
      DistanceTextStateFormatter.format(state.currentRunDistance);
  return new Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FittedBox(
          child: Text(
            formattedDistance,
            style: distanceTextStyle,
          ),
          fit: BoxFit.fitWidth,
        ),
        FittedBox(
          child: Text(
            "Distance (km)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: displayHeight(context) * 0.018,
              fontFamily: "Raleway",
              //color: Theme.of(context).colorScheme.aqiIconColor,
            ),
            key: Key("distanceText"),
          ),
          fit: BoxFit.fitHeight,
        ),
      ]);
}

class DistanceTextStateFormatter {
  static String format(double distance) {
    int km = (distance).truncate();
    int m = ((distance - km) * 1000).truncate();

    String kmStr = km.toString().padLeft(2, '0');
    String mStr = m.toString().padLeft(3, '0');

    return "$kmStr.$mStr";
  }
}
