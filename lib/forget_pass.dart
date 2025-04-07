import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Forgetpass extends StatefulWidget {
  const Forgetpass({super.key});

  @override
  ForgetpassState createState() => ForgetpassState();
}

class ForgetpassState extends State<Forgetpass> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> resetPassword() async {
  String email = emailController.text.trim();
  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('يرجى إدخال البريد الإلكتروني'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    await _auth.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تحقق من بريدك الإلكتروني , تم إرسال رابط تعيين كلمة المرور'),
        backgroundColor: Colors.green,
      ),
    );

    //navigate the user back to login after succussfly reset the password
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Go back to login screen
    });

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حدث خطأ: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF363D7D),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 100),
              Center(
                child: Image.asset('assets/images/G_Logo.png', width: 130),
              ),
              SizedBox(height: 30),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 600,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF6062A0),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(110),
                    topRight: Radius.circular(110)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // Align text to right
                  children: [
                    const Text(
                      "هل نسيت الرقم السري؟",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 60),
                    const Text(
                      "يرجى إدخال البريد الإلكتروني المرتبط بحسابك",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity, // Ensures text field stretches fully
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "* البريد الإلكتروني",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 70),
                    Center( // Centering the button
                      child: ElevatedButton(
                        onPressed: resetPassword,
                        style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF363D7D),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("إرسال الرمز" ,  style: TextStyle(fontSize: 18),),
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
