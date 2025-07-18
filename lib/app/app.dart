import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart'; // depending on auth

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Findom',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // or use logic to check if user is logged in
    );
  }
}
