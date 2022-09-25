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
  List<int>? firestoreData;
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
          isNull = false;
          firestoreData?.add(everything["speed"]);
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
                              spots: const [
                                FlSpot(0, 4),
                                FlSpot(1, 3.5),
                                FlSpot(2, 4.5),
                                FlSpot(3, 1),
                                FlSpot(4, 4),
                                FlSpot(5, 6),
                                FlSpot(6, 6.5),
                                FlSpot(7, 6),
                                FlSpot(8, 4),
                                FlSpot(9, 6),
                                FlSpot(10, 6),
                                FlSpot(11, 7),
                              ],
                              isCurved: true,
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
                                '2019',
                                style: _dateTextStyle,
                              ),
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 18,
                                interval: 1,
                                getTitlesWidget: bottomTitleWidgets,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              axisNameSize: 20,
                              axisNameWidget: const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text('Value'),
                              ),
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                reservedSize: 40,
                                getTitlesWidget: leftTitleWidgets,
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            checkToShowHorizontalLine: (double value) {
                              return value == 1 ||
                                  value == 6 ||
                                  value == 4 ||
                                  value == 5;
                            },
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

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  String text;
  switch (value.toInt()) {
    case 0:
      text = 'Jan';
      break;
    case 1:
      text = 'Feb';
      break;
    case 2:
      text = 'Mar';
      break;
    case 3:
      text = 'Apr';
      break;
    case 4:
      text = 'May';
      break;
    case 5:
      text = 'Jun';
      break;
    case 6:
      text = 'Jul';
      break;
    case 7:
      text = 'Aug';
      break;
    case 8:
      text = 'Sep';
      break;
    case 9:
      text = 'Oct';
      break;
    case 10:
      text = 'Nov';
      break;
    case 11:
      text = 'Dec';
      break;
    default:
      return Container();
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 4,
    child: Text(text, style: _dateTextStyle),
  );
}

const _dateTextStyle = TextStyle(
  fontSize: 10,
  color: Colors.purple,
  fontWeight: FontWeight.bold,
);

Widget leftTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(color: Colors.black, fontSize: 12.0);
  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text('\$ ${value + 0.5}', style: style),
  );
}
