import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findom/services/theme_provider.dart';
import 'package:findom/services/user_profile_provider.dart'; // Import the new provider
import 'package:findom/screens/auth/login_screen.dart';
import 'package:findom/screens/auth/otp_verification_screen.dart';
import 'package:findom/screens/home/home_screen.dart';
import 'package:findom/services/locator.dart';
import 'package:findom/screens/auth/auth_wrapper.dart';
import 'package:findom/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator(); // Initialize the service locator
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<ThemeProvider>()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()), // Add the new provider
      ],
      child: const MyApp(),
    ),
  );
}
