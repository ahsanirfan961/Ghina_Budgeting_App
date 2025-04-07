import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/main_page.dart';
import 'package:frontend/q1.dart'; // Make sure to import your Q1 widget.
import 'package:frontend/sign_in.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (authSnapshot.hasData) {
          // User is signed in. Now check if they have completed Q1.
          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(authSnapshot.data!.uid)
                    .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasData) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                // Check the flag that indicates if questions are completed.
                final hasCompletedQuestions =
                    userData['hasCompletedQuestions'] as bool? ?? false;
                if (!hasCompletedQuestions) {
                  // If not completed, navigate to Q1.
                  return Q1(
                    uid: authSnapshot.data!.uid,
                    email: authSnapshot.data!.email!,
                  );
                }
              }
              // Default: if questions are complete, go to Mainpage1.
              return Mainpage1();
            },
          );
        } else {
          return SignIn();
        }
      },
    );
  }
}
