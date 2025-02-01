import 'package:test/test.dart';
import 'package:clean_run/openaq_services.dart';

void main() {
  group("API testing", () {
    test('It should return a data about Como given its coordinates', () async {
      var indexesByCoordinates =
          await getIndexesByCoordinates(45.8109, 9.0885, 1000);
      expect(indexesByCoordinates["results"][0]["city"], "Como");
    });

    test('It should return data about Como given its name', () async {
      var indexesByCity = await getIndexesByCity("Como", 1000);
      expect(indexesByCity["results"][0]["city"], "Como");
    });

    test('It should return the list of all the available cities (2876)',
        () async {
      var cities = await getCities();
      expect(cities.length, 2876);
    });
  });
}
