import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // এই লাইনটি যোগ করো
import 'firebase_options.dart'; // এই লাইনটিও যোগ করো
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase Initialize করার মেইন কোড
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CareerPath',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthPage(), // তোমার লগইন পেজ
    );
  }
}