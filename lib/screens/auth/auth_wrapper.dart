import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/models/user_profile_model.dart';
import 'package:findom/screens/home/home_screen.dart';
import 'package:findom/screens/onboarding/user_type_selection_screen.dart';
import 'package:findom/screens/jobs/company_dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // This function now checks all possible user collections.
  Future<DocumentSnapshot?> _getUserDocument(String uid) async {
    final collections = ['professionals', 'students', 'general_users', 'companies'];
    for (final collection in collections) {
      final doc = await FirebaseFirestore.instance.collection(collection).doc(uid).get();
      if (doc.exists) {
        return doc;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Something went wrong')));
    }

    return FutureBuilder<DocumentSnapshot?>(
      future: _getUserDocument(user.uid),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text("Something went wrong")));
        }

        // If no document is found in any collection, it's a new user.
        if (snapshot.data == null) {
          return const UserTypeSelectionScreen();
        }

        // Document exists, so route based on userType.
        final userProfile = UserProfile.fromFirestore(snapshot.data!);

        if (userProfile.userType == UserType.company) {
          return const CompanyDashboardScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
