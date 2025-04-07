import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/q1.dart';
import 'package:frontend/sign_in.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  final TextEditingController controlEmail = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController controlPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // to clear the widget when i don't need it
    controlEmail.dispose();
    phoneController.dispose();
    controlPassword.dispose();
    super.dispose();
  }

  Future<void> signUpHandling() async {
    if (_formKey.currentState!.validate()) {
      setState(() {}); // Ensures error messages displayed to user
      try {
        // Firebase Authentication - Create user
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: controlEmail.text.trim(),
              password: controlPassword.text.trim(),
            );

        User? user = userCredential.user;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'uid': user.uid,
                'email': controlEmail.text.trim(),
                'phone': phoneController.text.trim(),
                'createdAt': DateTime.now(),
                'hasCompletedQuestions': false,
              });

          print("Signup Successful!");

          // Navigate to Q1 after signup
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Q1(uid: user.uid, email: user.email!),
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup Failed: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // template for the logo and background color
      backgroundColor: Color(0xFF363D7D),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/G_Logo.png', width: 130),
                SizedBox(height: 500),
              ],
            ),
          ),
          // back border box
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 600,
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(
                color: Color(0xFF6062A0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(110),
                  topRight: Radius.circular(110),
                ),
              ),
              // form questions
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    const Text(
                      "تسجيل جديد",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      width: 380,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 70,
                            child: TextFormField(
                              controller: controlEmail,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: "* البريد الإلكتروني ",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !RegExp(
                                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                                    ).hasMatch(value)) {
                                  return 'البريد الإلكتروني غير صالح';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: 380,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 70,
                            child: TextFormField(
                              controller: phoneController,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: "* رقم الجوال",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال رقم الجوال';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: 380,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 70,
                            child: TextFormField(
                              controller: controlPassword,
                              textAlign: TextAlign.right,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: "* الرقم السري",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال الرقم السري';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // Sign Up Button
                    SizedBox(
                      height: 50,
                      width: 130,
                      child: ElevatedButton(
                        onPressed: signUpHandling, // Calls Firebase Signup
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "الدخول",
                          style: TextStyle(
                            color: Color.fromARGB(255, 26, 30, 62),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    // for signin page
                    SizedBox(height: 28),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignIn()),
                        );
                      },
                      child: const Text(
                        "لديك حساب من قبل ؟",
                        style: TextStyle(
                          color: Color.fromARGB(255, 26, 30, 62),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
