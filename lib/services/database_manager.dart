import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';

class DatabaseManager {
  static void addNewRunLocation(String locationName, Map<String, dynamic> data) {
    User user = FirebaseAuth.instance.currentUser!;
    SetOptions options = SetOptions(merge: true);
    FirebaseFirestore.instance.collection("Users").doc(user.email).collection("RunLocations").doc(locationName).set(data, options);
  }

  static List<String> getRunningLocations() {
    List<String> locations = [];
    User user = FirebaseAuth.instance.currentUser!;
    FirebaseFirestore.instance.collection("Users").doc(user.email).collection("RunLocations").get().then((value) => {
          value.docs.forEach((element) {
            locations.add(element.id);
          })
        });
    return locations;
  }

  static Future<LinkedHashMap<LatLng, int>> getLocationData(String runName) async {
    LinkedHashMap<LatLng, int> result = LinkedHashMap();
    User user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection("Users").doc(user.email).collection("RunLocations").doc(runName).get().then((value) {
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      List<dynamic> location = data['Location Data'];
      List<dynamic> time = data['elapsed_time_intervals'];
      print("data: $location");
      for (int i = 0; i < time.length; i++) {
        GeoPoint point = location[i];
        result[LatLng(point.latitude, point.longitude)] = time[i];
      }
    });
    return result;
  }
}
