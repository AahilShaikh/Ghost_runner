import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wwp_hacks_project/screens/sign_up.dart';
import 'package:wwp_hacks_project/services/location.dart';
import 'package:wwp_hacks_project/widgets/fab_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> data =
      FirebaseFirestore.instance.collection('Updates').snapshots();
  List<Map<String, dynamic>> firestoreData = [];
  String? email = FirebaseAuth.instance.currentUser?.email;
  bool data_exists = false;
  void checkData() {
    try {
      if (email != null) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(email)
            .collection("RunLocations")
            .get()
            .then((everything) {
          for (var data in everything.docs) {
            firestoreData.add({
              "LocationData": data['Location Data'],
              "elapsed_time_intervals": data['elapsed_time_intervals'],
              "name": data['name'],
            });
            data_exists = true;
          }
        });
      } else {
        throw 'Bad User Id, Please Sign Out';

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
    setState(() {});
  }

  @override
  void initState() {
    checkData();
    super.initState();
    checkLocationPermissions(context);
  }

  @override
  Widget build(BuildContext context) {
    if (data_exists) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: <Widget>[
            IconButton(
              color: Colors.black,
              icon: const Icon(Icons.account_circle_sharp),
              tooltip: 'Sign Out',
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const SignUpPage()));
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: const [Text("fard")],
          ),
        ),
        floatingActionButton: const FABBottomSheetButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: <Widget>[
            IconButton(
              color: Colors.black,
              icon: const Icon(Icons.account_circle_sharp),
              tooltip: 'Sign Out',
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const SignUpPage()));
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: const [Text("No Running Data To Start A run Press +")],
          ),
        ),
        floatingActionButton: const FABBottomSheetButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    }
  }
}
