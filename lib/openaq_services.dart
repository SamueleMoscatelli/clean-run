import 'package:http/http.dart' as http;
import 'dart:convert';

getIndexesByCoordinates(double lat, double lon, int radius) async {
  final endpoint =
      'https://u50g7n0cbj.execute-api.us-east-1.amazonaws.com/v2/locations?limit=100&page=1&offset=0&sort=desc&order_by=lastUpdated&dumpRaw=false&';

  if (lat == null || lon == null) return [];

  String latlon = lat.toString() + "," + lon.toString();

  var response = await http.get(
      endpoint + "&coordinates=" + latlon + "&radius=" + radius.toString());

  var responseJson = json.decode(response.body);

  if (responseJson['results'] != null) {
    return responseJson;
  }
}

getIndexesByCity(String city, int radius) async {
  final endpoint =
      'https://docs.openaq.org/v2/locations?limit=100&page=1&offset=0&sort=desc&order_by=lastUpdated&dumpRaw=false&';

  if (city == null) return [];

  var response = await http
      .get(endpoint + "&city=" + city + "&radius=" + radius.toString());

  var responseJson = json.decode(response.body);

  if (responseJson['results'] != null) {
    return responseJson;
  }
}

getCities() async {
  final endpoint =
      'https://u50g7n0cbj.execute-api.us-east-1.amazonaws.com/v2/cities?limit=100000&page=1&offset=0&sort=asc&order_by=city';

  var response = await http.get(endpoint);

  var responseJson = json.decode(response.body);

  if (responseJson['results'] != null) {
    List<String> cities = [];
    for (var i = 0; i < responseJson['results'].length; i++) {
      if (!responseJson['results'][i]['city'].startsWith(RegExp(r'[0-9]')) &&
          !responseJson['results'][i]['city'].startsWith(RegExp(r'N/A'))) {
        cities.add(responseJson['results'][i]['city']);
      }
    }
    return cities;
  }
}
