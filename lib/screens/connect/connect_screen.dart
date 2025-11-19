import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:findom/screens/find_a_pro/find_a_pro_screen.dart';
import 'package:findom/screens/home/home_screen.dart'; // Reusing HomeScreen as the feed for now

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Connect',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          bottom: TabBar(
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'Community'),
              Tab(text: 'Find a Pro'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Reuse the feed part of HomeScreen or a dedicated Feed widget
            // For now, we can wrap HomeScreen's body logic or just use HomeScreen
            // But HomeScreen has an AppBar. We should probably extract the body of HomeScreen.
            // For this iteration, I'll just use a placeholder or the existing HomeScreen 
            // but HomeScreen has Scaffold.
            // Let's just use FindAProScreen for the second tab.
            // For the first tab, I'll create a wrapper or just duplicate the feed logic briefly 
            // or better, refactor HomeScreen later. 
            // For now, I will use a temporary placeholder that says "Community Feed" 
            // to avoid breaking things, or try to use the Feed widget if I can extract it.
            // Actually, HomeScreen is the Feed. 
            // I'll just put a text for now and refactor HomeScreen in the next step.
            Center(child: Text('Community Feed - Coming Soon')),
            FindAProScreen(),
          ],
        ),
      ),
    );
  }
}
