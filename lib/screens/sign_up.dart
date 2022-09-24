import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wwp_hacks_project/screens/login_page.dart';

import '../constants/palette.dart';
import '../services/login_validators.dart';
import '../widgets/buttons.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final int containerSpacing = 0;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _secondPasswordController;

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _secondPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _secondPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/background_waves.png'), fit: BoxFit.fill)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text("Create Account", textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline1),
                    )
                  ],
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.mail_outline_outlined)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outlined),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    obscureText: true,
                    controller: _secondPasswordController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock_outlined),
                      labelText: "Confirm Password",
                    ),
                  ),
                ),
              ],
            ),
            Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: ActionButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Sign up'),
                          Icon(
                            Icons.keyboard_arrow_right_rounded,
                            color: Colors.white,
                          )
                        ],
                      ),
                      onPressed: () {
                        if (!isValidEmail(_emailController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                              'Invalid email',
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: pastelGreen,
                            duration: Duration(seconds: 1),
                          ));
                          return;
                        }
                        if (!isValidPassword(_passwordController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                              'Invalid password. Must have 1 upper case, 1 lower case, 1 special character, 1 digit, and  be 8 characters long',
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: pastelGreen,
                            duration: Duration(seconds: 2),
                          ));
                          return;
                        }
                        if (_passwordController.text != _secondPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                              'Passwords do not match.',
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: pastelGreen,
                            duration: Duration(seconds: 2),
                          ));
                          return;
                        }
                        auth.createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ((context) => const HomePage())));
                      }),
                )),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: RichText(
                text: TextSpan(
                    text: 'Already have an account?',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    children: const [TextSpan(text: ' Sign in', style: TextStyle(color: lightGreen))],
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        print("asdas");
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
                      }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
