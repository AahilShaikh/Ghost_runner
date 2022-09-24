// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wwp_hacks_project/screens/home_page.dart';
import 'package:wwp_hacks_project/screens/sign_up.dart';

import 'constants/palette.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghost Trainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColorDark: darkBlack,
          scaffoldBackgroundColor: Colors.white,
          colorSchemeSeed: lightGreen,
          brightness: Brightness.light,
          textTheme: const TextTheme(
              headline1: TextStyle(
            fontSize: 40,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ))),
      home: FirebaseAuth.instance.currentUser != null ? const HomePage() : SignUpPage(),
    );
  }
}
