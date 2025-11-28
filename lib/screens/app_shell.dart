import 'package:flutter/material.dart';
import 'package:findom/screens/home/home_screen.dart';
import 'package:findom/screens/jobs/job_board_screen.dart';
import 'package:findom/screens/profile/profile_screen.dart';
import 'package:findom/screens/learn/learn_screen.dart';
import 'package:findom/screens/connect/connect_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/widgets/bottom_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  List<Widget> get _widgetOptions {
    final user = FirebaseAuth.instance.currentUser;
    return <Widget>[
      const HomeScreen(),
      const LearnScreen(),
      const ConnectScreen(),
      const JobBoardScreen(),
      if (user != null)
        ProfileScreen(userId: user.uid)
      else
        const Center(child: Text("Please log in")),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
