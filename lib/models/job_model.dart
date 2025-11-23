import 'package:cloud_firestore/cloud_firestore.dart';

enum EmploymentType { fullTime, partTime, contract, internship }

class Job {
  final String id;
  final String companyId;
  final String title;
  final String description;
  final String location;
  final EmploymentType employmentType;
  final Timestamp postedDate;
  final String? salaryRange;
  final String? experienceLevel;
  final String? requirements;
  final String? benefits;
  final String? companyName;

  Job({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.location,
    required this.employmentType,
    required this.postedDate,
    this.salaryRange,
    this.experienceLevel,
    this.requirements,
    this.benefits,
    this.companyName,
  });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Job(
      id: doc.id,
      companyId: data['companyId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      employmentType: EmploymentType.values.firstWhere(
        (e) => e.toString() == 'EmploymentType.${data['employmentType']}',
        orElse: () => EmploymentType.fullTime,
      ),
      postedDate: data['postedDate'] ?? Timestamp.now(),
      salaryRange: data['salaryRange'],
      experienceLevel: data['experienceLevel'],
      requirements: data['requirements'],
      benefits: data['benefits'],
      companyName: data['companyName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'companyId': companyId,
      'title': title,
      'description': description,
      'location': location,
      'employmentType': employmentType.toString().split('.').last,
      'postedDate': postedDate,
      'salaryRange': salaryRange,
      'experienceLevel': experienceLevel,
      'requirements': requirements,
      'benefits': benefits,
      'companyName': companyName,
    };
  }
}
