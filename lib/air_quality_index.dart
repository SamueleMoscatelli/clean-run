final breakpointsW = [
  [0, 50],
  [51, 100],
  [101, 150],
  [151, 200],
  [201, 300],
  [301, 400],
  [401, 500]
];
final breakpoints = [
  {
    "name": "o3",
    "concentrations": [
      [0, 55],
      [55, 71],
      [71, 86],
      [86, 106],
      [106, 200],
      [106, 200],
      [106, 2000]
    ],
  },
  {
    "name": "pm25",
    "concentrations": [
      [0, 12.1],
      [12.1, 35.5],
      [35.5, 55.5],
      [55.5, 150.5],
      [150.5, 250.5],
      [250.5, 350.5],
      [350.5, 500.5]
    ],
  },
  {
    "name": "pm10",
    "concentrations": [
      [0, 55],
      [55, 155],
      [155, 255],
      [255, 355],
      [355, 425],
      [425, 505],
      [505, 605]
    ],
  },
  {
    "name": "co",
    "concentrations": [
      [0, 4.5],
      [4.5, 9.5],
      [9.5, 12.5],
      [12.5, 15.5],
      [15.5, 30.5],
      [30.5, 40.5],
      [40.5, 50.5]
    ],
  },
  {
    "name": "so2",
    "concentrations": [
      [0, 36],
      [36, 76],
      [76, 186],
      [186, 306],
      [305, 606],
      [605, 806],
      [805, 1006]
    ],
  },
  {
    "name": "no2",
    "concentrations": [
      [0, 54],
      [54, 101],
      [101, 361],
      [361, 650],
      [650, 1250],
      [1250, 1650],
      [1650, 2050]
    ],
  }
];

convertCityResult(jsonData) {
  var names = ['o3', 'pm25', 'pm10', 'co', 'so2', 'no2'];
  var parss = {
    'o3': {'value': 0.0, 'count': 0},
    'pm25': {'value': 0.0, 'count': 0},
    'pm10': {'value': 0.0, 'count': 0},
    'co': {'value': 0.0, 'count': 0},
    'so2': {'value': 0.0, 'count': 0},
    'no2': {'value': 0.0, 'count': 0}
  };

  for (var i = 0; i < jsonData.length; i++) {
    for (var j = 0; j < jsonData[i]['parameters'].length; j++) {
      if ('o3' == jsonData[i]['parameters'][j]['parameter'] ||
          'pm25' == jsonData[i]['parameters'][j]['parameter'] ||
          'pm10' == jsonData[i]['parameters'][j]['parameter'] ||
          'co' == jsonData[i]['parameters'][j]['parameter'] ||
          'so2' == jsonData[i]['parameters'][j]['parameter'] ||
          'no2' == jsonData[i]['parameters'][j]['parameter']) {
        parss[jsonData[i]['parameters'][j]['parameter']]['count']++;
        parss[jsonData[i]['parameters'][j]['parameter']]['value'] +=
            jsonData[i]['parameters'][j]['average'];
      }
    }
  }

  for (var ind in names) {
    if (parss[ind]['count'] != 0) {
      parss[ind]['value'] = parss[ind]['value'] / parss[ind]['count'];
    }
    if (ind == "co") {
      parss[ind]['value'] = (parss[ind]['value'] / 1000) * 24.45 / 28.02;
    } else if (ind == "so2") {
      parss[ind]['value'] = parss[ind]['value'] * 2.62;
    } else if (ind == "no2") {
      parss[ind]['value'] = parss[ind]['value'] * 1.88;
    }
  }

  return parss;
}

computeAirQualityIndex(airDataJson) {
  double aqisMax = 0;

  var parss = convertCityResult(airDataJson);

  for (var i = 0; i < breakpoints.length; i++) {
    var currentAqi =
        computeAQI(breakpoints[i], parss[breakpoints[i]['name']]['value']);

    if (aqisMax < currentAqi) {
      aqisMax = currentAqi;
    }
  }

  return aqisMax;
}

checkParameterPresence(par, params) {
  for (var i = 0; i < params.length; i++) {
    if (params[i] == par) {
      return i;
    }
  }
  return -1;
}

computeAQI(breakpoint, value) {
  var high, low, bhigh, blow;
  var index = breakpoint['concentrations'].length - 1;

  if (value < 0) {
    value = value * (-1);
  }
  for (var i = 0; i < breakpoint['concentrations'].length; i++) {
    if (value >= breakpoint['concentrations'][i][0] &&
        value < breakpoint['concentrations'][i][1]) {
      bhigh = breakpoint['concentrations'][i][1];
      blow = breakpoint['concentrations'][i][0];
      index = i;
      break;
    }
  }

  if (bhigh == null) {
    bhigh = 1;
    blow = 0;
  }

  high = breakpointsW[index][1];
  low = breakpointsW[index][0];

  var aqi = ((high - low) / (bhigh - blow)) * (value - blow) + low;

  return aqi;
}
