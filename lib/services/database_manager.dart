import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';

import '../functions/ai.dart';

class DatabaseManager {
  static String nullDbError = "Please Sign in and out, there was a User error!";

  static void addNewRunLocation(String locationName, Map<String, dynamic> data, double speed, double distanceTraveled) {
    String userEmail = nullCheckEmail();

    SetOptions options = SetOptions(merge: true);
    FirebaseFirestore.instance.collection("Users").doc(userEmail).collection("RunLocations").doc(locationName).set(data, options);
    updateSpeed(speed);
    addHistoryData({
      "location": locationName,
      "speed": speed,
      "distanceTraveled": distanceTraveled,
    });
  }

  static List<String> getRunningLocations() {
    List<String> locations = [];
    String userEmail = nullCheckEmail();
    FirebaseFirestore.instance.collection("Users").doc(userEmail).collection("RunLocations").get().then((value) => {
          // TODO change this for each is slow!!!!!!
          value.docs.forEach((element) {
            locations.add(element.id);
          })
        });
    return locations;
  }

  static Future<LinkedHashMap<LatLng, int>> getLocationData(String runName) async {
    LinkedHashMap<LatLng, int> result = LinkedHashMap();
    String userEmail = nullCheckEmail();
    await FirebaseFirestore.instance.collection("Users").doc(userEmail).collection("RunLocations").doc(runName).get().then((value) {
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      List<dynamic> location = data['Location Data'];
      List<dynamic> time = data['elapsed_time_intervals'];
      for (int i = 0; i < time.length; i++) {
        GeoPoint point = location[i];
        result[LatLng(point.latitude, point.longitude)] = time[i];
      }
    });
    return result;
  }

  static void updateSpeed(double speed) {
    String userEmail = nullCheckEmail();
    SetOptions options = SetOptions(merge: true);
    List<double> speeds;
    FirebaseFirestore.instance.collection("Users").doc(userEmail).get().then((value) {
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      speeds = data['speeds'] ?? [];
      speeds.add(speed);
      FirebaseFirestore.instance.collection("Users").doc(userEmail).set({"speeds": speeds}, options);
    });
  }

  static void getSpeeds(double speed) {
    String userEmail = nullCheckEmail();
    List<double> speeds;
    FirebaseFirestore.instance.collection("Users").doc(userEmail).get().then((value) {
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      speeds = data['speeds'] ?? [];
      speeds.add(speed);
      return speeds;
    });
  }

  static String nullCheckEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw nullDbError;
    }
    String? userEmail = user.email;
    if (userEmail == null) {
      throw nullDbError;
    }
    return userEmail;
  }

  static void addHistoryData(Map<String, dynamic> data) {
    String userEmail = nullCheckEmail();
    SetOptions options = SetOptions(merge: true);
    FirebaseFirestore.instance.collection("Users").doc(userEmail).get().then((value) {
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      List<dynamic> history = data['history'];
      history.add(data);
      FirebaseFirestore.instance.collection("Users").doc(userEmail).set({"history": history}, options);
    });
  }

  static Future<List<Map<String, dynamic>>> getAdvancedRuns() async {
    String userEmail = nullCheckEmail();
    List<Map<String, dynamic>> returnData = [];
    await FirebaseFirestore.instance.collection("Users").doc(userEmail).get().then((value) {
      returnData = value["history"];
    });
    return returnData;
  }
}
