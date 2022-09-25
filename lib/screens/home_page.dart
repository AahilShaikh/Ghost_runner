import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wwp_hacks_project/screens/sign_up.dart';
import 'package:wwp_hacks_project/services/location.dart';
import 'package:wwp_hacks_project/widgets/fab_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wwp_hacks_project/widgets/line_chart_speed.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, String> display = {};
  @override
  void initState() {
    super.initState();
    checkLocationPermissions(context);
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
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).textTheme.headline1!.color as Color),
                  ),
                ));
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
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SignUpPage()));
                  },
                ),
              ],
            ),
            body: StreamBuilder(
                stream: FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.email).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  DocumentSnapshot doc = snapshot.data as DocumentSnapshot;
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  List<dynamic> speeds = [];
                  speeds = data['speeds'];
                  List<FlSpot> speedData = [];
                  double i = 0;
                  for (dynamic element in speeds) {
                    speedData.add(FlSpot(i, double.parse(element)));
                    i++;
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(child: SpeedLineChart(speedData)),
                        Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const Spacer(),
                                const Text(
                                  "Last Run Data",
                                  style: TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                Text("Your Last run  Distance is:  ${display["avgSpeed"].toString()}"),
                                const Spacer(),
                                Text("Your Last run Distance is:  ${display["distance"].toString()}"),
                                const Spacer(),
                                 Text("Did you beat the ai? ${display["Your are ahead"].toString()}"),
                              ],
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
