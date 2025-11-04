import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  final String id;
  final String name;
  final String website;
  final String? logoUrl;

  Company({
    required this.id,
    required this.name,
    this.website = '',
    this.logoUrl,
  });

  factory Company.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Company(
      id: doc.id,
      name: data['name'] ?? '',
      website: data['website'] ?? '',
      logoUrl: data['logoUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'website': website,
      'logoUrl': logoUrl,
    };
  }
}
