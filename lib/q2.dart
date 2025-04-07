import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/q1.dart';
import 'package:frontend/q3.dart';

class Q2 extends StatefulWidget {
  final String uid;
  final String email;
  final String name; // Accepts the name from Q1
  const Q2({super.key, required this.uid, required this.email, required this.name});

  @override
  Q2State createState() => Q2State();
}

class Q2State extends State<Q2> {
  final TextEditingController controlMoney = TextEditingController();
  final _keyForm = GlobalKey<FormState>();

  Future<void> storeAnswer() async {
    if (_keyForm.currentState!.validate()) {
      try {
        // Store income with uid and email in Firestore
        await FirebaseFirestore.instance
            .collection('user_answers')
            .doc(widget.uid)
            .set({
              'question2': controlMoney.text.trim(),
              'answeredAt': DateTime.now(),
            }, SetOptions(merge: true));

        // Navigate to Q3
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Q3(uid: widget.uid, email: widget.email),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to save answer.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF363D7D),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            right: 15,
            child: IconButton(
              icon: Icon(Icons.arrow_forward, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => Q1(uid: widget.uid, email: widget.email),
                  ),
                );
              },
            ),
          ),

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
              height: 550,
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(
                color: Color(0xFF6062A0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(110),
                  topRight: Radius.circular(110),
                ),
              ),

              // Questions lines
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 75),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFF363D7D), // not active question
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 70,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white, // active line
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 70,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white, // active line
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "أهلاً ${widget.name} ، ما هو دخلك الشهري ؟",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form with required field
                  Form(
                    key: _keyForm,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 390,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextFormField(
                              controller: controlMoney,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                hintText: "مقدار الدخل",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "يرجى إدخال دخلك الشهري";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 140),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: storeAnswer, // Calls Firestore saving function
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF363D7D),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "التالي",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
