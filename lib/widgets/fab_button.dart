import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wwp_hacks_project/screens/add_new_run_page.dart';
import 'package:wwp_hacks_project/screens/race_page.dart';
import 'package:wwp_hacks_project/services/database_manager.dart';
import 'package:wwp_hacks_project/widgets/action_button.dart';

import '../constants/palette.dart';

class FABBottomSheetButton extends StatelessWidget {
  const FABBottomSheetButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.userChanges().listen((event) {
      if (event != null) {
        user = event;
      }
    });
    return FloatingActionButton(
      backgroundColor: lightGreen,
      onPressed: () {
        Scaffold.of(context).showBottomSheet(
            enableDrag: true,
            (context) => Container(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [BoxShadow(offset: const Offset(0, -1), blurRadius: 5, spreadRadius: 5, color: Colors.grey[300]!)]),
                  child: Column(
                    children: [
                      const Padding(
                          padding: EdgeInsets.all(8), child: Text("Choose a location to run", style: TextStyle(fontSize: 20, color: darkBlack))),
                      Expanded(
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance.collection("Users").doc(user!.email).collection("RunLocations").snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            }
                            List<String> locations = [];
                            QuerySnapshot? query = snapshot.data as QuerySnapshot?;
                            for (var element in query!.docs) {
                              locations.add(element.id);
                            }
                            return ListView.builder(
                              shrinkWrap: false,
                              itemCount: locations.length,
                              itemBuilder: (context, i) {
                                return ListTile(
                                  title: Text(locations[i]),
                                  onTap: () {
                                    DatabaseManager.getLocationData(locations[i])
                                        .then((value) => Navigator.of(context).push(MaterialPageRoute(builder: (context) => RacePage(value, locations[i]))));
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                      ActionButton(
                        child: Row(
                          children: const [Text("Create new running location"), Icon(Icons.chevron_right_rounded, color: Colors.white)],
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddNewRunPage()));
                        },
                      )
                    ],
                  ),
                ));
      },
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}
