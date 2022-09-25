import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';

import '../functions/ai.dart';



class DatabaseManager {
  static String nullDbError = "Please Sign in and out, there was a User error!";
  static void addNewRunLocation(
      String locationName, Map<String, dynamic> data, double speed) {
    User user = FirebaseAuth.instance.currentUser!;
    SetOptions options = SetOptions(merge: true);
    FirebaseFirestore.instance
        .collection("Users")
        .doc(user.email)
        .collection("RunLocations")
        .doc(locationName)
        .set(data, options);
    updateSpeed(speed);
  }

  static List<String> getRunningLocations() {
    List<String> locations = [];
    User user = FirebaseAuth.instance.currentUser!;
    FirebaseFirestore.instance
        .collection("Users")
        .doc(user.email)
        .collection("RunLocations")
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                locations.add(element.id);
              })
            });
    return locations;
  }

  static Future<LinkedHashMap<LatLng, int>> getLocationData(
      String runName) async {
    LinkedHashMap<LatLng, int> result = LinkedHashMap();
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw nullDbError;
    }
    String? userEmail = user.email;
    if (userEmail == null) {
      throw nullDbError;
    }
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userEmail)
        .collection("RunLocations")
        .doc(runName)
        .get()
        .then((value) {
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
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw nullDbError;
    }
    String? userEmail = user.email;
    if (userEmail == null) {
      throw nullDbError;
    }    SetOptions options = SetOptions(merge: true);
    List<double> speeds;
    FirebaseFirestore.instance
        .collection("Users")
        .doc(userEmail)
        .get()
        .then((value) {
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      speeds = data['speeds'] ?? [];
      speeds.add(speed);
      FirebaseFirestore.instance
          .collection("Users")
          .doc(user.email)
          .set({"speeds": speeds}, options);
    });
  }

  static void getSpeeds(double speed) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw nullDbError;
    }
    String? userEmail = user.email;
    if (userEmail == null) {
      throw nullDbError;

    }
    List<double> speeds;
    FirebaseFirestore.instance
        .collection("Users")
        .doc(userEmail)
        .get()
        .then((value) {
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      speeds = data['speeds'] ?? [];
      speeds.add(speed);
      return speeds;
    });
  }

  static void sendAdvanceRuns(AIData backData) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw nullDbError;

    }
    String? userEmail = user.email;
    if (userEmail == null) {
      throw nullDbError;

    }
    SetOptions options = SetOptions(merge: true);
    List<double> speeds;
    FirebaseFirestore.instance.collection("Users").doc(user.email).set({
      "advance_data": {
        "distance": backData.distance,
        "avgSpeed": backData.avgSpeed,
        "ahead_by_how_much": backData.extraData.ahead,
        "ahead": backData.extraData.areYouAhead,
      }
    }, options);
  }
}
