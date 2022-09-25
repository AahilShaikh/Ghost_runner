import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wwp_hacks_project/screens/sign_up.dart';
import 'package:wwp_hacks_project/services/location.dart';
import 'package:wwp_hacks_project/widgets/fab_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wwp_hacks_project/widgets/line_chart_speed.dart';

import '../constants/palette.dart';
import '../services/database_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> display = [{}];

  @override
  void initState() {
    getData();
    super.initState();
    checkLocationPermissions(context);
  }

  getData() async {
    display = await DatabaseManager.getAdvancedRuns();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                color: Theme.of(context).backgroundColor,
                child: Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).textTheme.headline1!.color as Color),
                  ),
                ));
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: lightGreen,
              elevation: 2,
              centerTitle: true,
              title: const Text(
                "Ghost Trainer",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  color: Colors.black,
                  icon: const Icon(
                    Icons.account_circle_rounded,
                    color: Colors.white,
                  ),
                  tooltip: 'Sign Out',
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const SignUpPage()));
                  },
                ),
              ],
            ),
            body: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Users")
                    .doc(FirebaseAuth.instance.currentUser!.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  DocumentSnapshot doc = snapshot.data as DocumentSnapshot;
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  List<dynamic> speeds = [];
                  speeds = data['speeds'];
                  List<FlSpot> speedData = [];
                  double i = 0;
                  for (dynamic element in speeds) {
                    speedData.add(FlSpot(i, double.parse(element)));
                    i++;
                  }
                  double averageSpeed = 0;
                  int x = 0;
                  while (x < speeds.length || x == 6) {
                    averageSpeed += speeds[x];
                    x++;
                  }
                  averageSpeed /= i;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration:
                                BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white, boxShadow: [BoxShadow(offset: const Offset(0, 1), blurRadius: 5, spreadRadius: 5, color: Colors.grey[300]!)]),
                            child: Row(
                              children: [
                                const Spacer(),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Welcome Back",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Average Speed/\nLast 7 runs: ",
                                          textAlign: TextAlign.center,
                                        ),
                                        Text("${averageSpeed.toStringAsFixed(3)} mph")
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        Expanded(child: SpeedLineChart(speedData)),
                        Expanded(
                            flex: 1,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: display.length,
                              itemBuilder: (BuildContext context, int index) {
                                return SizedBox(
                                  height: 150,
                                  child: Column(
                                    children: [
                                      const Spacer(),
                                      const Text(
                                        "Last Run Data",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      const Spacer(),
                                      Text(
                                          "Your Last run distance is:  ${display[index]["distance"].toString()}"),
                                      const Spacer(),
                                      Text(
                                          "Your Last run speed is:  ${display[index]["speed"].toString()}"),
                                      const Spacer(),
                                    ],
                                  ),
                                );
                              },
                            ))
                      ],
                    ),
                  );
                }),
            floatingActionButton: const FABBottomSheetButton(),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        });
  }
}
