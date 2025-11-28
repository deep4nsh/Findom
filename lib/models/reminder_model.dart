import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderCategory {
  bill,
  investment,
  insurance,
  tax,
  subscription,
  other,
}

class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final bool isCompleted;
  final String userId;
  final ReminderCategory category;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
    required this.userId,
    this.category = ReminderCategory.other,
  });

  factory Reminder.fromMap(Map<String, dynamic> data, String documentId) {
    return Reminder(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      userId: data['userId'] ?? '',
      category: ReminderCategory.values.firstWhere(
        (e) => e.name == (data['category'] ?? 'other'),
        orElse: () => ReminderCategory.other,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'isCompleted': isCompleted,
      'userId': userId,
      'category': category.name,
    };
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
    String? userId,
    ReminderCategory? category,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      category: category ?? this.category,
    );
  }
}
