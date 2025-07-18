import 'package:findom/screens/auth/login_screen.dart';
import 'package:findom/screens/auth/signup_screen.dart';
import 'package:findom/screens/home/home_screen.dart';
import 'package:findom/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Findom',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(), // or LoginScreen
        '/home': (context) => const HomeScreen(), // <-- add this line
      },
    );
  }
}
