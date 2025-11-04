import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/models/user_model.dart';
import 'package:findom/screens/home/home_screen.dart';
import 'package:findom/screens/onboarding/user_type_selection_screen.dart';
import 'package:findom/screens/jobs/company_dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // This should not happen if we are in a logged-in state, but as a fallback:
      return const Scaffold(body: Center(child: Text('Something went wrong')));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text("Something went wrong")));
        }

        // If the document does not exist, it's a new user.
        if (!snapshot.data!.exists) {
          return const UserTypeSelectionScreen();
        }

        // Document exists, so route based on userType.
        final appUser = AppUser.fromFirestore(snapshot.data!);

        if (appUser.userType == UserType.company) {
          return const CompanyDashboardScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
