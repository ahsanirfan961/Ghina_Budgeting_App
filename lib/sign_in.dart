// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/forget_pass.dart';
import 'package:frontend/main_page.dart';
import 'package:frontend/sign_up.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:frontend/q1.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController controlEmail = TextEditingController();
  final TextEditingController controlPassword = TextEditingController();
  String _errorMessage = "";
  String? _emailError;
  String? _passwordError;
  final RegExp emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  Future<void> _checkUserStatus(String uid, String email) async {
    try {
      // check if the user is in firestore
      print("Checking user status for UID: $uid");

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (userDoc.exists) {
        bool hasCompletedQuestions = userDoc["hasCompletedQuestions"] ?? false;
        print(
          "User found in Firestore. hasCompletedQuestions = $hasCompletedQuestions",
        );

        if (hasCompletedQuestions) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Mainpage1()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Q1(uid: uid, email: email)),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Q1(uid: uid, email: email)),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = "خطأ في جلب بيانات المستخدم: $e";
      });
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    String email = controlEmail.text.trim();
    String password = controlPassword.text.trim();

    setState(() {
      _emailError = null;
      _passwordError = null;
      _errorMessage = "";
    });

    if (email.isEmpty) {
      setState(() {
        _emailError = "البريد الإلكتروني لا يمكن أن يكون فارغًا";
      });
      return;
    } else if (!emailRegExp.hasMatch(email)) {
      setState(() {
        _emailError = "البريد الإلكتروني غير صالح";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = "كلمة المرور لا يمكن أن تكون فارغة";
      });
      return;
    }
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        print("User Signed In Successfully: ${user.uid}");

        await _checkUserStatus(user.uid, user.email ?? "");
      } else {
        print("User credential is null.");
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "خطأ: ${e.toString()}",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      }
    }
  }

  //catch (e) {
  //  setState(() {
  //    _passwordError =
  //        "فشل تسجيل الدخول: يرجى التحقق من صحة البريد الإلكتروني وكلمة المرور";
  //    _errorMessage = "Error: $e";
  //  });
  //}
  //}

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            "97519894390-7dm4nvuask7klma48fi6i9otu48haaat.apps.googleusercontent.com",
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        print("Google Sign-In Successful: ${user.email}");

        //  Check if this email already exists in Firestore
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .get();

        if (userDoc.exists) {
          //check the status of competedQuestion
          bool hasCompletedQuestions =
              userDoc["hasCompletedQuestions"] ?? false;
          print(
            " User found in Firestore. hasCompletedQuestions = $hasCompletedQuestions",
          );

          if (hasCompletedQuestions) {
            // if all question filled > mainPage1
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Mainpage1()),
            );
          } else {
            //if not go to q1
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => Q1(uid: user.uid, email: user.email ?? ""),
              ),
            );
          }
        } else {
          //  If user doesnt exist in Firestore, save them and go to Q1
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .set({
                'uid': user.uid,
                'email': user.email ?? "",
                'createdAt': DateTime.now(),
                'hasCompletedQuestions':
                    false, // New users should start with false
              });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Q1(uid: user.uid, email: user.email ?? ""),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = "خطأ أثناء تسجيل الدخول باستخدام جوجل: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "تسجيل الدخول",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_errorMessage.isNotEmpty)
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    SizedBox(height: 35),
                    TextField(
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
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: controlPassword,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: "* الرقم السري",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 25),
                    const Text(
                      "ـــــــــــــــــــ او ـــــــــــــــــــ",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                    SizedBox(height: 27),

                    //______________________________________________
                    //Sign In with google account
                    GestureDetector(
                      onTap: _signInWithGoogle,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'تسجيل الدخول باستخدام جوجل',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(width: 10),
                            Image.asset(
                              'assets/images/google_icon.png',
                              height: 20,
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    //___________________________________________________
                    // forget password button
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Forgetpass()),
                        );
                      },
                      child: Text(
                        'هل نسيت الرقم السري؟',
                        style: TextStyle(
                          color: Color.fromARGB(255, 26, 30, 62),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    //__________________________________________
                    //Sign In button
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _signInWithEmailAndPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: Size(150, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'الدخول',
                            style: TextStyle(
                              color: Color.fromARGB(255, 26, 30, 62),
                              fontSize: 16,
                            ),
                          ),
                        ),

                        //___________________________________________________
                        // SignUp button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF9FB5DA),
                            minimumSize: Size(150, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'مستخدم جديد',
                            style: TextStyle(
                              color: Color.fromARGB(255, 26, 30, 62),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
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
