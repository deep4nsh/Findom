import 'package:cloud_firestore/cloud_firestore.dart';

class UsernameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'usernames';

  /// Checks if a username is available.
  /// Returns true if available, false if taken.
  Future<bool> isUsernameAvailable(String username) async {
    final normalizedUsername = username.toLowerCase().trim();
    final doc = await _firestore.collection(_collectionName).doc(normalizedUsername).get();
    return !doc.exists;
  }

  /// Reserves a username for a specific user ID.
  /// Throws an exception if the username is already taken.
  Future<void> reserveUsername(String username, String uid) async {
    final normalizedUsername = username.toLowerCase().trim();
    final docRef = _firestore.collection(_collectionName).doc(normalizedUsername);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        throw Exception('Username is already taken.');
      }
      transaction.set(docRef, {'uid': uid, 'createdAt': FieldValue.serverTimestamp()});
    });
  }

  /// Releases a username (e.g., when changing usernames).
  Future<void> releaseUsername(String username) async {
    final normalizedUsername = username.toLowerCase().trim();
    await _firestore.collection(_collectionName).doc(normalizedUsername).delete();
  }
  
  /// Validates username format
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Only letters, numbers, and underscores allowed';
    }
    return null;
  }
}
