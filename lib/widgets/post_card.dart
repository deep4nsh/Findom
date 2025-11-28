import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:findom/models/user_profile_model.dart';
import 'package:findom/services/following_provider.dart';
import 'package:findom/screens/posts/comments_screen.dart';

class PostCard extends StatelessWidget {
  final String postId;
  final String userId;
  final String userName;
  final String? userImage;
  final String content;
  final String? imageUrl;
  final List<String> likes;
  final DateTime timestamp;

  const PostCard({
    super.key,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.timestamp,
  });

  Future<void> _toggleLike() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    if (likes.contains(currentUser.uid)) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([currentUser.uid])
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([currentUser.uid])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isLiked = currentUser != null && likes.contains(currentUser.uid);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 1), // Full width or minimal spacing
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorHeader(context, currentUser?.uid),
            const SizedBox(height: 12),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                height: 1.4,
              ),
            ),
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(imageUrl!),
                ),
              ),
            const SizedBox(height: 12),
            _buildActionButtons(context, isLiked),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorHeader(BuildContext context, String? currentUserId) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage: userImage != null && userImage!.isNotEmpty
              ? NetworkImage(userImage!)
              : null,
          child: userImage == null || userImage!.isEmpty ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              // Timestamp could go here
            ],
          ),
        ),
        if (currentUserId != null && userId.trim() != currentUserId.trim())
          Consumer<FollowingProvider>(
            builder: (context, followingProvider, child) {
              final bool isFollowing = followingProvider.isFollowing(userId);
              return TextButton.icon(
                icon: Icon(
                  isFollowing ? Icons.check : Icons.add,
                  size: 18,
                  color: isFollowing ? Colors.grey : Theme.of(context).primaryColor,
                ),
                label: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isFollowing ? Colors.grey : Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: () {
                  if (isFollowing) {
                    followingProvider.unfollow(userId);
                  } else {
                    followingProvider.follow(userId);
                  }
                },
              );
            },
          )
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLiked) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: _toggleLike,
          icon: Icon(
            isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
            color: isLiked ? Theme.of(context).primaryColor : Colors.grey,
            size: 20,
          ),
          label: Text("Like (${likes.length})"),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        _buildCommentButton(context),
        TextButton.icon(
          onPressed: () { /* TODO: Implement share */ },
          icon: const Icon(Icons.share, color: Colors.grey, size: 20),
          label: const Text("Share"),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }


  Widget _buildCommentButton(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .snapshots(),
      builder: (context, snapshot) {
        final commentCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return TextButton.icon(
          icon: const Icon(Icons.comment_outlined, color: Colors.grey, size: 20),
          label: Text("Comment ($commentCount)"),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CommentsScreen(postId: postId),
              ),
            );
          },
        );
      },
    );
  }
}
