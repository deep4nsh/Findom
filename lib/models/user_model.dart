import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { professional, student, general, company }

class AppUser {
  final String uid;
  final String email;
  final String phoneNumber;
  final UserType userType;
  final bool isVerified;

  AppUser({
    required this.uid,
    this.email = '',
    this.phoneNumber = '',
    required this.userType,
    this.isVerified = false,
  });

  // Factory constructor to create a User from a Firestore document
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      userType: UserType.values.firstWhere(
        (e) => e.toString() == data['userType'],
        orElse: () => UserType.general, // Default value
      ),
      isVerified: data['isVerified'] ?? false,
    );
  }

  // Method to convert a User object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType.toString(),
      'isVerified': isVerified,
    };
  }
}
