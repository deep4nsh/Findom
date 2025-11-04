import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> toggleLike(String postId, List<String> currentLikes) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final postRef = _firestore.collection('posts').doc(postId);
    final isLiked = currentLikes.contains(userId);

    if (isLiked) {
      // User has already liked the post, so we remove the like
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } else {
      // User has not liked the post, so we add the like
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId])
      });
    }
  }
}
