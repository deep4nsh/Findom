import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/services/locator.dart';
import 'package:findom/services/network_service.dart';

class FollowingProvider with ChangeNotifier {
  final NetworkService _networkService = locator<NetworkService>();
  Set<String> _followingIds = {};
  bool _isLoading = false;

  Set<String> get followingIds => _followingIds;
  bool get isLoading => _isLoading;

  FollowingProvider() {
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    final followingDocs = await FirebaseFirestore.instance
        .collection('following')
        .doc(user.uid)
        .collection('userFollowing')
        .get();

    _followingIds = followingDocs.docs.map((doc) => doc.id).toSet();
    
    _isLoading = false;
    notifyListeners();
  }

  bool isFollowing(String userId) {
    return _followingIds.contains(userId);
  }

  Future<void> follow(String userId) async {
    if (isFollowing(userId)) return;

    _followingIds.add(userId);
    notifyListeners(); // Update UI instantly

    await _networkService.followUser(userId);
  }

  Future<void> unfollow(String userId) async {
    if (!isFollowing(userId)) return;

    _followingIds.remove(userId);
    notifyListeners(); // Update UI instantly

    await _networkService.unfollowUser(userId);
  }
}
