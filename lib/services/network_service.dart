import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NetworkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Follow a user
  Future<void> followUser(String userIdToFollow) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;
    final now = Timestamp.now();

    // 1. Add the user to the current user's 'following' sub-collection
    final followingRef = _firestore.collection('users').doc(currentUserId).collection('following').doc(userIdToFollow);

    // 2. Add the current user to the other user's 'followers' sub-collection
    final followersRef = _firestore.collection('users').doc(userIdToFollow).collection('followers').doc(currentUserId);

    // Use a batch write to perform both operations atomically
    final batch = _firestore.batch();
    batch.set(followingRef, {'timestamp': now});
    batch.set(followersRef, {'timestamp': now});
    await batch.commit();
  }

  // Unfollow a user
  Future<void> unfollowUser(String userIdToUnfollow) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;

    // 1. Remove the user from the current user's 'following' sub-collection
    final followingRef = _firestore.collection('users').doc(currentUserId).collection('following').doc(userIdToUnfollow);

    // 2. Remove the current user from the other user's 'followers' sub-collection
    final followersRef = _firestore.collection('users').doc(userIdToUnfollow).collection('followers').doc(currentUserId);

    // Use a batch write for atomicity
    final batch = _firestore.batch();
    batch.delete(followingRef);
    batch.delete(followersRef);
    await batch.commit();
  }
}
