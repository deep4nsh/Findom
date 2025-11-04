import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findom/services/theme_provider.dart';
import 'package:findom/screens/auth/login_screen.dart';
import 'package:findom/screens/auth/otp_verification_screen.dart';
import 'package:findom/screens/home/home_screen.dart';
import 'package:findom/services/locator.dart';
import 'package:findom/screens/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator(); // Initialize the service locator
  runApp(
    ChangeNotifierProvider(
      create: (_) => locator<ThemeProvider>(),
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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            // User is logged in, so go to the AuthWrapper
            return const AuthWrapper();
          }
          // User is not logged in
          return const LoginScreen();
        },
      ),

      routes: {
        '/otp': (context) => const OtpVerificationScreen(
          verificationId: '',
          phoneNumber: '',
        ),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
