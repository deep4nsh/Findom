import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findom/services/theme_provider.dart';
import 'package:findom/services/user_profile_provider.dart';
import 'package:findom/services/following_provider.dart'; // Import the new provider
import 'package:findom/services/locator.dart';
import 'package:findom/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator(); 
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<ThemeProvider>()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => FollowingProvider()), // Add the new provider
      ],
      child: const MyApp(),
    ),
  );
}
