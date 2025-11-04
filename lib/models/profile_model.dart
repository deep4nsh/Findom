import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String uid;
  final String fullName;
  final String headline;
  final String? profilePictureUrl;
  final List<String> specializations;
  final Map<String, String> experience;
  final String education;

  Profile({
    required this.uid,
    required this.fullName,
    this.headline = '',
    this.profilePictureUrl,
    this.specializations = const [],
    this.experience = const {},
    this.education = '',
  });

  factory Profile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Profile(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      headline: data['headline'] ?? '',
      profilePictureUrl: data['profilePictureUrl'],
      specializations: List<String>.from(data['specializations'] ?? []),
      experience: Map<String, String>.from(data['experience'] ?? {}),
      education: data['education'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'headline': headline,
      'profilePictureUrl': profilePictureUrl,
      'specializations': specializations,
      'experience': experience,
      'education': education,
    };
  }
}
