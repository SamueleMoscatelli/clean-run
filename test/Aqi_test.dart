import 'package:test/test.dart';
import 'package:clean_run/constants.dart';
import 'package:clean_run/aqiRepresentation.dart';

void main() {
  group("Aqi test", () {
    test('Worst', () async {
      var aqi;
      for (aqi = 150; aqi < 200; ++aqi) {
        expect(selectColor(aqi), airQualityColors.worstQuality);
      }
    });
    test('Bad', () async {
      var aqi;
      for (aqi = 100; aqi < 150; ++aqi) {
        expect(selectColor(aqi), airQualityColors.badQuality);
      }
    });
    test('Good', () async {
      var aqi;
      for (aqi = 51; aqi < 100; ++aqi) {
        expect(selectColor(aqi), airQualityColors.goodQuality);
      }
    });
    test('best', () async {
      var aqi;
      for (aqi = 0; aqi < 51; ++aqi) {
        expect(selectColor(aqi), airQualityColors.bestQuality);
      }
    });
    test('undefined', () async {
      var aqi;
      expect(selectColor(aqi), airQualityColors.qualityNotAvailable);
    });
  });
}
