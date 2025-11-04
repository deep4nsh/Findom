import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findom/models/user_model.dart';
import 'package:findom/models/profile_model.dart';
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
            .collection('users')
            .where('userType', isEqualTo: UserType.professional.toString())
            .where('isVerified', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No verified professionals found."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final user = AppUser.fromFirestore(snapshot.data!.docs[index]);
              // We will create ProfessionalCard in the next step
              return ProfessionalCard(user: user);
            },
          );
        },
      ),
    );
  }
}

class ProfessionalCard extends StatelessWidget {
  final AppUser user;

  const ProfessionalCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('profiles').doc(user.uid).get(),
      builder: (context, profileSnapshot) {
        if (!profileSnapshot.hasData) {
          return const ListTile(title: Text("Loading..."));
        }

        final profile = Profile.fromFirestore(profileSnapshot.data!);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
             leading: profile.profilePictureUrl != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(profile.profilePictureUrl!),
                  )
                : const CircleAvatar(child: Icon(Icons.person)),
            title: Text(profile.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(profile.headline),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: user.uid),
              ));
            },
          ),
        );
      },
    );
  }
}
