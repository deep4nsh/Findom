import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:findom/screens/home/home_screen.dart';
import 'package:findom/screens/auth/login_screen.dart';
import 'package:findom/screens/onboarding_screen.dart';
import 'package:findom/app/root_nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _checkLoginStatus);
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingShown = prefs.getBool('onboarding_shown') ?? false;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // Look for user document across collections
    final collections = ['professionals', 'students', 'general_users', 'companies'];
    DocumentSnapshot? foundDoc;
    for (final c in collections) {
      final d = await FirebaseFirestore.instance.collection(c).doc(user.uid).get();
      if (d.exists) {
        foundDoc = d;
        break;
      }
    }

    if (!onboardingShown) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    // If profile exists or not, go to RootNav so user can proceed; new users can fill later
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RootNav()),
    );
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
              'assets/images/profile.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              "Findom",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
