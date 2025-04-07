import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/main_page.dart';
import 'package:frontend/q2.dart';

class Q3 extends StatefulWidget {
  final String uid;
  final String email;
  const Q3({super.key, required this.uid, required this.email});

  @override
  Q3State createState() => Q3State();
}

class Q3State extends State<Q3> {

  // List of Banks
  List<String> banks = [
    "بنك الأهلي",
    "بنك الراجحي",
    "بنك الرياض",
    "بنك البلاد",
    "بنك السعودي الفرنسي",
    "بنك العربي",
    "بنك ساب",
    "بنك السعودي للإستثمار",
    "بنك الجزيرة",
    "بنك الإنماء",
  ];
  String? bankSelection; // Selected bank
  bool isAgreed = false; // Checkbox state

  Future<void> _completedMark(String uid) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        'hasCompletedQuestions': true,
      });
      print("CompletedQuestions is updated to true in firebase");
    } catch (e) {
      print(" Error updating hasCompletedQuestions: $e");
    }
  }

  Future<void> storeAnswer() async {
    if (bankSelection == null || !isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("يرجى اختيار البنك والموافقة على الشروط")),
      );
      return;
    }
    try {
      // Save selected bank to Firestore
      await FirebaseFirestore.instance
          .collection('user_answers')
          .doc(widget.uid)
          .set({
            'question3': bankSelection,
            'completedAt': DateTime.now(),
          }, SetOptions(merge: true));

      //  Mark questions as completed in Firestore
      await _completedMark(widget.uid);

      // Move to MainPage1
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Mainpage1()),
      );
    } catch (e) {
      print("Error saving answer: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save answer.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF363D7D),
      body: Stack(
        children: [
          // Back Button
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
                        (context) =>
                            Q2(uid: widget.uid, email: widget.email, name: ""),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 75),

                    // questions line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 70,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 70,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),

                    // Question
                    const Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "الرجاء اختيار حسابك البنكي",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    //  Dropdown for banks
                    Container(
                      width: 380,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: bankSelection,
                        isExpanded: true,
                        menuMaxHeight: 250,
                        decoration: InputDecoration(border: InputBorder.none),
                        hint: const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "حساب البنك",
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                        items:
                            banks.map((String bank) {
                              return DropdownMenuItem<String>(
                                value: bank,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(bank, textAlign: TextAlign.right),
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            bankSelection = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 35),

                    // Conditions
                    const Padding(
                      padding: EdgeInsets.only(right: 10, left: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "الشروط والأحكام",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 7),
                    const Padding(
                      padding: EdgeInsets.only(right: 10, left: 10),
                      child: Text(
                        "عند استخدامك لتطبيق غنًى، فإنك تمنحنا الإذن للوصول إلى الرسائل النصية الخاصة بك بشكل آلي بهدف البحث عن اسم البنك المرتبط بحساباتك. نضمن لك أن هذه العملية تتم بأمان تام دون تخزين أو مشاركة أي بيانات حساسة مع أي طرف ثالث.",
                        style: TextStyle(color: Colors.white, fontSize: 14.5),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Checkbox to confirm the conditions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Checkbox(
                          value: isAgreed,
                          onChanged: (bool? value) {
                            setState(() {
                              isAgreed = value!;
                            });
                          },
                          activeColor: Colors.white,
                          checkColor: Color(0xFF363D7D),
                        ),
                        const Text(
                          "أوافق على الشروط والأحكام",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        SizedBox(width: 15),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Next Button
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed:
                            storeAnswer, // Calls Firestore saving function
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
          ),
        ],
      ),
    );
  }
}
