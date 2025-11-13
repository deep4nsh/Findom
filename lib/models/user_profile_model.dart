import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { professional, student, general, company }

class UserProfile {
  // Core Auth Info
  final String uid;
  final String email;
  final String phoneNumber;
  final UserType userType;
  
  // Profile Info
  final String fullName;
  final String headline;
  final String? profilePictureUrl;
  final List<String> specializations;
  final String education;

  // Status
  final bool isVerified;

  UserProfile({
    required this.uid,
    this.email = '',
    this.phoneNumber = '',
    required this.userType,
    this.fullName = '',
    this.headline = '',
    this.profilePictureUrl,
    this.specializations = const [],
    this.education = '',
    this.isVerified = false,
  });

  static UserType _parseUserType(dynamic raw) {
    if (raw == null) return UserType.general;
    final value = raw.toString();
    // Accept both 'UserType.professional' and 'professional'
    for (final e in UserType.values) {
      final full = e.toString();
      final short = full.split('.').last;
      if (value == full || value == short) return e;
    }
    return UserType.general;
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      userType: _parseUserType(data['userType']),
      fullName: data['fullName'] ?? '',
      headline: data['headline'] ?? '',
      profilePictureUrl: data['profilePictureUrl'],
      specializations: List<String>.from(data['specializations'] ?? []),
      education: data['education'] ?? '',
      isVerified: data['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      // Keep existing storage format for backward compatibility
      'userType': userType.toString(),
      'fullName': fullName,
      'headline': headline,
      'profilePictureUrl': profilePictureUrl,
      'specializations': specializations,
      'education': education,
      'isVerified': isVerified,
    };
  }
}
