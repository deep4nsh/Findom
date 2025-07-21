import 'package:findom/screens/auth/login_screen.dart';
import 'package:findom/screens/auth/otp_verification_screen.dart';
import 'package:findom/services/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:findom/screens/home/home_screen.dart';
import 'package:findom/services/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/otp': (context) => OtpVerificationScreen(
          verificationId: '', phoneNumber: '', // placeholders
        ),
        '/home': (context) => HomeScreen(), // ✅ this must be present
      },
    );
  }
}
