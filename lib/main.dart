import 'package:flutter/material.dart';
import 'package:frontend/auth_gate.dart';
import 'package:frontend/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

//void main() {
//  runApp(MyApp());
//}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase Initialized Successfully!");
  } catch (e) {
    print("Firebase Initialization Failed: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ghina App',
      home: AuthGate(), // Start with flash screen
    );
  }
}
