// Basic widget tests for the Findom app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';
import 'package:findom/models/user_profile_model.dart';
import 'package:findom/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('UserProfile toFirestore converts correctly', () {
      final profile = UserProfile(
        uid: 'test123',
        email: 'test@example.com',
        phoneNumber: '+911234567890',
        userType: UserType.professional,
        fullName: 'Test User',
        headline: 'CA Professional',
        specializations: ['Tax', 'Audit'],
        education: 'CA',
        isVerified: true,
      );

      final data = profile.toFirestore();

      expect(data['uid'], 'test123');
      expect(data['email'], 'test@example.com');
      expect(data['userType'], 'UserType.professional');
      expect(data['fullName'], 'Test User');
      expect(data['isVerified'], true);
      expect(data['specializations'], ['Tax', 'Audit']);
    });
  });

  group('Post Model Tests', () {
    test('Post likeCount returns correct count', () {
      final post = Post(
        id: 'post1',
        authorId: 'user1',
        content: 'Test post content',
        timestamp: Timestamp.now(),
        likes: ['user1', 'user2', 'user3'],
      );

      expect(post.likeCount, 3);
    });

    test('Post toFirestore converts correctly', () {
      final timestamp = Timestamp.now();
      final post = Post(
        id: 'post1',
        authorId: 'user1',
        content: 'Test content',
        timestamp: timestamp,
        likes: ['user1'],
      );

      final data = post.toFirestore();

      expect(data['authorId'], 'user1');
      expect(data['content'], 'Test content');
      expect(data['timestamp'], timestamp);
      expect(data['likes'], ['user1']);
    });
  });

  group('UserType Enum Tests', () {
    test('UserType enum has all required values', () {
      expect(UserType.values.length, 4);
      expect(UserType.values.contains(UserType.professional), true);
      expect(UserType.values.contains(UserType.student), true);
      expect(UserType.values.contains(UserType.general), true);
      expect(UserType.values.contains(UserType.company), true);
    });
  });
}
