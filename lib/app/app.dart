import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findom/services/theme_provider.dart';
import 'package:findom/screens/auth/auth_wrapper.dart';
import 'package:findom/theme/app_theme.dart'; // Import your custom theme

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Findom',
      // Correctly apply the custom theme
      theme: AppTheme.light(), 
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}
