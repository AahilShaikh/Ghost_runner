import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseManager {
  static void   addNewRunLocation(String locationName, Map<String, dynamic> data) {
    User user = FirebaseAuth.instance.currentUser!;
    SetOptions options = SetOptions(merge: true);
    FirebaseFirestore.instance.collection("Users").doc(user.email).collection("RunLocations").doc(locationName).set(data, options);
  }
}
