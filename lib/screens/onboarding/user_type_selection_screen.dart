import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/models/user_model.dart';
import 'package:findom/models/profile_model.dart';
import 'package:findom/screens/home/home_screen.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  Future<void> _createUserAndProfile(BuildContext context, UserType userType) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Create the AppUser document
    final appUser = AppUser(
      uid: user.uid,
      phoneNumber: user.phoneNumber ?? '',
      userType: userType,
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(appUser.toFirestore());

    // Create the Profile document
    final profile = Profile(
      uid: user.uid,
      fullName: user.displayName ?? 'New User', // Placeholder name
    );
    await FirebaseFirestore.instance
        .collection('profiles')
        .doc(user.uid)
        .set(profile.toFirestore());

    // Navigate to the home screen
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome to Findom!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'To get started, please tell us who you are.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              _buildUserTypeButton(
                context,
                icon: Icons.work,
                label: 'I am a Finance Professional',
                userType: UserType.professional,
              ),
              const SizedBox(height: 16),
              _buildUserTypeButton(
                context,
                icon: Icons.school,
                label: 'I am a Student',
                userType: UserType.student,
              ),
              const SizedBox(height: 16),
              _buildUserTypeButton(
                context,
                icon: Icons.person,
                label: 'I am looking for information',
                userType: UserType.general,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeButton(BuildContext context, {required IconData icon, required String label, required UserType userType}) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: () => _createUserAndProfile(context, userType),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
