import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findom/services/theme_provider.dart';
import 'package:findom/screens/auth/auth_wrapper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Findom',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,

      // Corrected: AuthWrapper is the single entry point.
      // The old, broken SplashScreen is no longer used.
      home: const AuthWrapper(),
    );
  }
}
