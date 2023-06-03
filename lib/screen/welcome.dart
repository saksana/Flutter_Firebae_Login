import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loginsystem/screen/login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  get auth => FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome")),
      body: Column(children: [
        Text(auth.currentUser.email),
        ElevatedButton(
            onPressed: () {
              auth.signOut().then((value) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const LoginScreen();
                }));
              });
            },
            child: const Text("ອອກຈາກລະບົບ"))
      ]),
    );
  }
}
