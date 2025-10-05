import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findom/services/theme_provider.dart';
import 'package:findom/screens/auth/login_screen.dart';
import 'package:findom/screens/auth/otp_verification_screen.dart';
import 'package:findom/screens/home/home_screen.dart';
//import "io.flutter.embedding.android.FlutterActivity";


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

    // Check if user is already logged in
    final User? user = FirebaseAuth.instance.currentUser;
    
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode:
      themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,

      // ✅ Conditional home screen
      home: user != null ? HomeScreen() : LoginScreen(),

      routes: {
        '/otp': (context) => const OtpVerificationScreen(
          verificationId: '',
          phoneNumber: '',
        ),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
