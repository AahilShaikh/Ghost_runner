import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wwp_hacks_project/screens/sign_up.dart';
import 'package:wwp_hacks_project/services/location.dart';
import 'package:wwp_hacks_project/widgets/fab_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SignUpPage()));
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
        });
  }
}
