import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/models/user_model.dart';
import 'package:findom/models/profile_model.dart';
import 'package:findom/models/company_model.dart';
import 'package:findom/screens/home/home_screen.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  Future<void> _createUserDocuments(BuildContext context, UserType userType) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();

    // 1. Create the AppUser document
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final appUser = AppUser(
      uid: user.uid,
      phoneNumber: user.phoneNumber ?? '',
      userType: userType,
    );
    batch.set(userRef, appUser.toFirestore());

    // 2. Create either a Profile or a Company document
    if (userType == UserType.company) {
      final companyRef = FirebaseFirestore.instance.collection('companies').doc(user.uid);
      final company = Company(
        id: user.uid,
        name: 'New Company', // Placeholder name
      );
      batch.set(companyRef, company.toFirestore());
    } else {
      final profileRef = FirebaseFirestore.instance.collection('profiles').doc(user.uid);
      final profile = Profile(
        uid: user.uid,
        fullName: user.displayName ?? 'New User', // Placeholder name
      );
      batch.set(profileRef, profile.toFirestore());
    }

    await batch.commit();

    // 3. Navigate to the home screen
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
      onPressed: () => _createUserDocuments(context, userType),
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
