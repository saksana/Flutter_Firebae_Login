import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:loginsystem/model/profile.dart';
import 'package:loginsystem/screen/welcome.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  Profile profile = Profile();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  void _email(name) {
    setState(() {
      profile.email = name;
    });
  }

  void _password(pass) {
    setState(() {
      profile.password = pass;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text("error")),
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("ລົງຊື່ເຂົ້າໃຊ້"),
              ),
              // ignore: avoid_unnecessary_containers
              body: Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("ອີເມວ", style: TextStyle(fontSize: 18)),
                            TextFormField(
                              validator: MultiValidator([
                                RequiredValidator(errorText: "ກະລຸນາປ້ອນອີເມວ"),
                                EmailValidator(
                                    errorText: "ຮູບແບບອີເມວບໍ່ຖືກຕ້ອງ")
                              ]),
                              keyboardType: TextInputType.emailAddress,
                              onSaved: (name) {
                                _email(name);
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            const Text("ລະຫັດຜ່ານ",
                                style: TextStyle(fontSize: 18)),
                            TextFormField(
                              validator: RequiredValidator(
                                  errorText: "ກະລຸນາປ້ອນລະຫັດຜ່ານ"),
                              obscureText: true,
                              onSaved: (String? pass) {
                                _password(pass);
                              },
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                child: const Text(
                                  "ລົງຊື່ເຂົ້າໃຊ້",
                                  style: TextStyle(fontSize: 20),
                                ),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    formKey.currentState!.save();
                                    try {
                                      await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                              email: profile.email,
                                              password: profile.password)
                                          .then((value) {
                                        formKey.currentState!.reset();
                                        Navigator.pushReplacement(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return const WelcomeScreen();
                                        }));
                                      });
                                    } on FirebaseAuthException catch (e) {
                                      Fluttertoast.showToast(
                                          msg: e.message.toString(),
                                          gravity: ToastGravity.CENTER);
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            );
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        });
  }
}
