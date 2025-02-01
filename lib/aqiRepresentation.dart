import 'dart:math';

import 'constants.dart';

airQualityColors selectColor(aqi) {
  var col;
  try {
    if (aqi < 51) {
      col = airQualityColors.bestQuality;
    } else if (aqi < 100) {
      col = airQualityColors.goodQuality;
    } else if (aqi < 150) {
      col = airQualityColors.badQuality;
    } else {
      col = airQualityColors.worstQuality;
    }
  } catch (e) {
    col = airQualityColors.qualityNotAvailable;
  }
  return col;
}

double findAQI(Map run) {
  //print(run["aqis"]);
  double res = 0.0;
  double distanceSum = 0.0;
  for (int i = 0; i < run["aqis"].length; ++i) {
    distanceSum += run["measurementsDistances"][i];
    res += run["aqis"][i] * run["measurementsDistances"][i];
  }
  //print("res= $res");
  //print("res normalized= ${res / max(0.0000000001, distanceSum)}");
  return res / max(0.0000000001, distanceSum);
}
