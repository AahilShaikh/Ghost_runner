import 'package:latlong2/latlong.dart';

// void main() {
//   List<double> logitude = [23, 24, 24];
//   List<double> Lantiide = [40, 41, 41.5];
//   List<double> Oldlogitude = [23, 24, 26];
//   List<double> OldLantiide = [40, 41, 42];
//   const double time_passed = 8000000;
//   ai_data cool =
//   Ai().main(logitude, Lantiide, Oldlogitude, OldLantiide, time_passed);
//   print(cool.AvgSpeed);
//   print(cool.speed);
//   print(cool.distance);
//   print(cool.extra_data.ahead);
//   print(cool.extra_data.are_you_ahead);
//   //196.52626620000004
//   // 167.69480355000002
//   // 195228.0
//   // 145015.0
//   // false
// }

class bro_this_return_a_class_use_ahead_and_are_you_ahead {
  late double ahead;
  late bool are_you_ahead;
}

class ai_data {
  late double speed;
  late double distance;
  late double AvgSpeed;
  late bro_this_return_a_class_use_ahead_and_are_you_ahead extra_data;
}

class Ai {
  ai_data main(List<double> logitude, List<double> Lantiide,
      List<double> Oldlogitude, List<double> OldLantiide, double time) {
    ai_data returnData = ai_data();

    returnData.distance = distance(logitude, Lantiide);

    returnData.AvgSpeed = speed(returnData.distance, time);

    returnData.extra_data =
        areYouAhead(returnData.distance, Oldlogitude, OldLantiide);

    returnData.speed = speed(
        const Distance()(
            LatLng(
                Lantiide[Lantiide.length - 2], logitude[logitude.length - 2]),
            LatLng(
                Lantiide[Lantiide.length - 1], logitude[logitude.length - 1])),
        time / Lantiide.length);

    return returnData;
  }

  double distance(List<double> logitude, List<double> Lantiide) {
    double totalDistance = 0;

    for (int where = 0; where < logitude.length; where++) {
      try {
        totalDistance = const Distance()(LatLng(Lantiide[where], logitude[where]),
            LatLng(Lantiide[where + 1], logitude[where + 1])) +
            totalDistance;
      } catch (_) {
        return totalDistance;
      }
    }
    return totalDistance;
  }

  double speed(double distance, double time) {
    double first = distance / time;

    return first * 2.237 * 3600;
  }

  bro_this_return_a_class_use_ahead_and_are_you_ahead areYouAhead(
      double newDistance, List<double> Oldlogitude, List<double> OldLantiide) {
    bro_this_return_a_class_use_ahead_and_are_you_ahead returnData =
    bro_this_return_a_class_use_ahead_and_are_you_ahead();

    double ghost = distance(OldLantiide, Oldlogitude);

    returnData.are_you_ahead = newDistance > ghost;

    switch (returnData.are_you_ahead) {
      case true:
        {
          returnData.ahead = newDistance - ghost;
        }
        break;
      default:
        {
          returnData.ahead = ghost - newDistance;
        }
        break;
    }
    return returnData;
  }
}