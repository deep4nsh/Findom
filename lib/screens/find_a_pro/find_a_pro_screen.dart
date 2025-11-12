import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findom/models/user_profile_model.dart';
import 'package:findom/screens/profile/profile_screen.dart';

class FindAProScreen extends StatelessWidget {
  const FindAProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Professional'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('professionals')
            .where('isVerified', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "You don't have permission to view professionals yet.",
                textAlign: TextAlign.center,
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No verified professionals found."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final userProfile = UserProfile.fromFirestore(snapshot.data!.docs[index]);
              return ProfessionalCard(userProfile: userProfile);
            },
          );
        },
      ),
    );
  }
}

class ProfessionalCard extends StatelessWidget {
  // Corrected: Use the new unified UserProfile model.
  final UserProfile userProfile;

  const ProfessionalCard({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: userProfile.profilePictureUrl != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(userProfile.profilePictureUrl!),
              )
            : const CircleAvatar(child: Icon(Icons.person)),
        title: Text(userProfile.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(userProfile.headline),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: userProfile.uid),
          ));
        },
      ),
    );
  }
}
