import 'package:clean_run/redux/reducers.dart';
import 'package:test/test.dart';

void main() {
  test(
      'It should return 37.79256765770499, which is the distance between Milano and Como',
      () {
    expect(
        calculateDistance(45.8109, 9.0885, 45.4773, 9.1815), 37.79256765770499);
  });
}
