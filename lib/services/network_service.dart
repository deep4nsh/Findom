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

    // 1. Add followed user to the current user's 'following' collection
    final followingRef = _firestore.collection('following').doc(currentUserId).collection('userFollowing').doc(userIdToFollow);

    // 2. Add current user to the other user's 'followers' collection
    final followersRef = _firestore.collection('followers').doc(userIdToFollow).collection('userFollowers').doc(currentUserId);

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

    // 1. Remove followed user from the current user's 'following' collection
    final followingRef = _firestore.collection('following').doc(currentUserId).collection('userFollowing').doc(userIdToUnfollow);

    // 2. Remove current user from the other user's 'followers' collection
    final followersRef = _firestore.collection('followers').doc(userIdToUnfollow).collection('userFollowers').doc(currentUserId);

    final batch = _firestore.batch();
    batch.delete(followingRef);
    batch.delete(followersRef);
    await batch.commit();
  }
}
