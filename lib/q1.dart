import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/q2.dart';

class Q1 extends StatefulWidget {
  final String uid;
  final String email; // Receiving user email
  const Q1({super.key, required this.uid, required this.email});

  @override
  Q1State createState() => Q1State();
}

class Q1State extends State<Q1> {
  final TextEditingController controlName = TextEditingController();
  final _keyForm = GlobalKey<FormState>();

  Future<void> storeAnswer() async {
    if (_keyForm.currentState!.validate()) {
      try {
        // Save name with email in Firestore
        await FirebaseFirestore.instance
            .collection('user_answers')
            .doc(widget.uid)
            .set({
              'uid': widget.uid,
              'email': widget.email,
              'question1': controlName.text.trim(),
              'answeredAt': DateTime.now(),
            }, SetOptions(merge: true));

        // Navigate to Q2 and
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => Q2(
                  uid: widget.uid,
                  email: widget.email,
                  name: controlName.text.trim(),
                ),
          ),
        );
      } catch (e) {
        print("Error saving answer: $e");
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
                          color: Color(0xFF363D7D), // not active line
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
                  const Padding(
                    padding: EdgeInsets.only(right: 15),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "ما هو إسمك ؟",
                        style: TextStyle(
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
                          // Name Input Box
                          Container(
                            width: 390,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextFormField(
                              controller: controlName,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                hintText: "الإسم",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "يرجى إدخال اسمك"; // Validation message
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 10),

                          // Small Note Under the Name Field
                          const Padding(
                            padding: EdgeInsets.only(right: 10, top: 5),
                            child: Text(
                              "ملاحظة: يرجى إدخال اسمك باللغة العربية",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
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
                      onPressed:
                          storeAnswer, // Calls function to save to Firestore
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
