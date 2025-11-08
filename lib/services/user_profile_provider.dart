import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/models/user_profile_model.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  UserProfileProvider() {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    final doc = await _getUserDocument(user.uid);
    if (doc != null) {
      _userProfile = UserProfile.fromFirestore(doc);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<DocumentSnapshot?> _getUserDocument(String uid) async {
    final collections = ['professionals', 'students', 'general_users', 'companies'];
    for (final collection in collections) {
      final doc = await FirebaseFirestore.instance.collection(collection).doc(uid).get();
      if (doc.exists) {
        return doc;
      }
    }
    return null;
  }
}
