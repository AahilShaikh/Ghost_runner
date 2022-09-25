import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wwp_hacks_project/screens/sign_up.dart';
import 'package:wwp_hacks_project/services/location.dart';
import 'package:wwp_hacks_project/widgets/fab_button.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double cutOffYValue = 5.0;

  final Stream<QuerySnapshot> data =
      FirebaseFirestore.instance.collection('Updates').snapshots();
  List<double> firestoreData = [];
  List<FlSpot> display = [];
  String? email = FirebaseAuth.instance.currentUser?.email;
  bool isNull = true;

  void checkData() {
    try {
      if (email != null) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(email.toString())
            .get()
            .then((everything) {
          for (int x = 0; x < everything["speed"].length; x++) {
            try {
              firestoreData.add(everything["speed"][x].toDouble());
            } catch (_) {}
          }
          for (int x = 0; x < firestoreData.length; x++) {
            isNull = false;
            display.add(FlSpot(x.toDouble(), firestoreData[x]));
          }
          setState(() {});
        });
      } else {
        throw 'Bad User Id, Please Sign Out';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    checkLocationPermissions(context);
  }

  static const _dateTextStyle = TextStyle(
    fontSize: 10,
    color: Colors.purple,
    fontWeight: FontWeight.bold,
  );

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
          } else {
            //Todo add null handling also I do love sucking cock bitch
            if (!isNull) {
              throw "go suck a cock bomber killer";
            }
          }
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
                children: [
                  AspectRatio(
                    aspectRatio: 2.4,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 24),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: display,
                              isCurved: false,
                              barWidth: 8,
                              color: Colors.purpleAccent,
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.deepPurple.withOpacity(0.4),
                                cutOffY: cutOffYValue,
                                applyCutOffY: true,
                              ),
                              aboveBarData: BarAreaData(
                                show: true,
                                color: Colors.orange.withOpacity(0.6),
                                cutOffY: cutOffYValue,
                                applyCutOffY: true,
                              ),
                              dotData: FlDotData(
                                show: false,
                              ),
                            ),
                          ],
                          minY: 0,
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: const Text(
                                'Speed Over Your Runs',
                                style: _dateTextStyle,
                              ),
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 18,
                                interval: 1,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              axisNameSize: 20,
                              axisNameWidget: const Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: Text('Your Speed'),
                              ),
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                reservedSize: 40,
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: 1,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            floatingActionButton: const FABBottomSheetButton(),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        });
  }
}
