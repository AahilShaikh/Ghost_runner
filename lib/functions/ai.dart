import 'package:latlong2/latlong.dart';

class BroThisReturnAClassUseAheadAndAreYouAhead {
  late double ahead;
  late bool areYouAhead;
}

class AIData {
  late double speed;
  late double distance;
  late double avgSpeed;
  late BroThisReturnAClassUseAheadAndAreYouAhead extraData;
}

class Ai {
  AIData main(List<double> logitude, List<double> Lantiide, List<double> Oldlogitude, List<double> OldLantiide, double time) {
    AIData returnData = AIData();

    returnData.distance = distance(logitude, Lantiide);

    returnData.avgSpeed = speed(returnData.distance, time);

    returnData.extraData = areYouAhead(returnData.distance, Oldlogitude, OldLantiide);

    returnData.speed = speed(
        const Distance()(LatLng(Lantiide[Lantiide.length - 2], logitude[logitude.length - 2]),
            LatLng(Lantiide[Lantiide.length - 1], logitude[logitude.length - 1])),
        time / Lantiide.length);

    return returnData;
  }

  double distance(List<double> logitude, List<double> Lantiide) {
    double totalDistance = 0;

    for (int where = 0; where < logitude.length; where++) {
      try {
        totalDistance = const Distance()(LatLng(Lantiide[where], logitude[where]), LatLng(Lantiide[where + 1], logitude[where + 1])) + totalDistance;
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

  BroThisReturnAClassUseAheadAndAreYouAhead areYouAhead(double newDistance, List<double> Oldlogitude, List<double> OldLantiide) {
    BroThisReturnAClassUseAheadAndAreYouAhead returnData = BroThisReturnAClassUseAheadAndAreYouAhead();

    double ghost = distance(OldLantiide, Oldlogitude);

    returnData.areYouAhead = newDistance > ghost;

    switch (returnData.areYouAhead) {
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

double calcDistanceAsFeet(LatLng a, LatLng b) {
  Distance distance = Distance();
  return distance.as(LengthUnit.Mile, a, b) * 5280;
}
