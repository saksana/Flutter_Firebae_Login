import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:loginsystem/model/profile.dart';
import 'package:loginsystem/screen/home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
                title: const Text("ສ້າງບັນຊີຜູ້ໃຊ້"),
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
                                  "ລົງທະບຽນ",
                                  style: TextStyle(fontSize: 20),
                                ),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    formKey.currentState!.save();
                                    try {
                                      await FirebaseAuth.instance
                                          .createUserWithEmailAndPassword(
                                              email: profile.email,
                                              password: profile.password);
                                      Fluttertoast.showToast(
                                          msg: "ສ້າງບັນຊີຜູ້ໃຊ້ສຳເຫຼັດ",
                                          gravity: ToastGravity.TOP);
                                      formKey.currentState!.reset();
                                      // ignore: use_build_context_synchronously
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const HomeScreen();
                                      }));
                                    } on FirebaseAuthException catch (e) {
                                      debugPrint(e.code);
                                      String message = "";
                                      if (e.code == "email-already-in-use") {
                                        message =
                                            "ອີເມວນີ້ມີໃນລະບົບແລ້ວ ກະລຸນາໃຊ້ອີເມວໃໝ່";
                                      } else if (e.code == "weak-password") {
                                        message =
                                            "ລະຫັດຜ່ານຕ້ອງມີຄວາມຍາວ 4 ໂຕອັກສອນຂື້ນໄປ";
                                      } else {
                                        message = e.message.toString();
                                      }
                                      Fluttertoast.showToast(
                                          msg: message,
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
