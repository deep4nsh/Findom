import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/models/user_profile_model.dart';
import 'package:findom/screens/app_shell.dart';
import 'package:findom/screens/jobs/company_dashboard_screen.dart';
import 'package:findom/screens/auth/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

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

  Future<DocumentSnapshot> _createDefaultUserProfile(User user) async {
    final userProfile = UserProfile(
      uid: user.uid,
      userType: UserType.general, // Default to general user
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
      fullName: user.displayName ?? 'New User',
    );

    await FirebaseFirestore.instance
        .collection('general_users')
        .doc(user.uid)
        .set(userProfile.toFirestore());
        
    return FirebaseFirestore.instance.collection('general_users').doc(user.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Show loading while checking auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If no user is logged in, show login screen
        final user = authSnapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        // User is logged in, now check their profile
        return FutureBuilder<DocumentSnapshot?>(
          future: _getUserDocument(user.uid),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.data == null) {
              // User does not exist in any collection, so create a default profile.
              return FutureBuilder<DocumentSnapshot>(
                future: _createDefaultUserProfile(user),
                builder: (context, newUserSnapshot) {
                  if (newUserSnapshot.connectionState == ConnectionState.waiting) {
                     return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  }
                  // After creation, proceed to the app.
                  return const AppShell();
                },
              );
            }

            // Document exists, so route based on userType.
            final userProfile = UserProfile.fromFirestore(snapshot.data!);

            if (userProfile.userType == UserType.company) {
              return const CompanyDashboardScreen();
            } else {
              return const AppShell();
            }
          },
        );
      },
    );
  }
}
