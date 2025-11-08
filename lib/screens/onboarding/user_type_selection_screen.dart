import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/models/user_profile_model.dart';
import 'package:findom/screens/home/home_screen.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  String _getCollectionForUserType(UserType userType) {
    switch (userType) {
      case UserType.professional:
        return 'professionals';
      case UserType.student:
        return 'students';
      case UserType.company:
        return 'companies';
      case UserType.general:
      default:
        return 'general_users';
    }
  }

  Future<void> _createUserProfile(BuildContext context, UserType userType) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final collectionName = _getCollectionForUserType(userType);

    final userProfile = UserProfile(
      uid: user.uid,
      userType: userType,
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
      fullName: user.displayName ?? 'New User', // Placeholder name
    );

    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(user.uid)
        .set(userProfile.toFirestore());

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
              const Divider(height: 32),
               _buildUserTypeButton(
                context,
                icon: Icons.business,
                label: 'Register as a Company',
                userType: UserType.company,
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
      onPressed: () => _createUserProfile(context, userType),
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
