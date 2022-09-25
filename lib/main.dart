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
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException {
    try {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
            iosClientId: "1:279080458713:ios:da7f92194c9d312701e1c8",
            iosBundleId: "com.example.EkamGhai",
            apiKey: "AIzaSyBly9Ka9Fv2g12AFGF6Yahn7deCO2nxvSQ",
            appId: "1:796000883439:web:8121af0ad245b923d3c11a",
            messagingSenderId: "1:796000883439:web:8121af0ad245b923d3c11a",
            projectId: "stop-it-e1eae",
          ));
    } on FirebaseException {
      try {
        await Firebase.initializeApp();
      } on FirebaseException {
        throw 'firebase not initialized error';
      }
    }

  }
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
      home: FirebaseAuth.instance.currentUser != null
          ? const HomePage()
          : SignUpPage(),
    );
  }
}
