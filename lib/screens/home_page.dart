import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_new_run_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Hi"),
          TextButton(
            child: Text("adasd"),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddNewRunPage()));
        },
      ),
    );
  }
}
