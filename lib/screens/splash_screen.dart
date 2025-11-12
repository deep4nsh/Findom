import 'dart:async';
import 'package:flutter/material.dart';
import 'package:findom/screens/auth/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // After a delay, navigate to the AuthWrapper and let it handle everything.
    Timer(const Duration(seconds: 3), _navigate);
  }

  void _navigate() {
    if (mounted) {
      // The AuthWrapper is the single source of truth for routing.
      // This completely removes the faulty database query from the splash screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/profile.png', // Assuming you have a logo here
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Findom',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ), 
      ),
    );
  }
}
