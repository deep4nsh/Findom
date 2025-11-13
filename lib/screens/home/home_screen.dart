import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/models/post_model.dart';
import 'package:findom/models/user_profile_model.dart';
import 'package:findom/services/locator.dart';
import 'package:findom/services/post_service.dart';
import 'package:findom/services/user_profile_provider.dart';
import 'package:findom/services/following_provider.dart';
import 'package:findom/screens/posts/comments_screen.dart';
import 'package:findom/screens/search/search_screen.dart';
import 'package:findom/screens/posts/create_post_screen.dart';
import 'home_view_model.dart';

// --- Main HomeScreen Widget ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () { /* TODO: Navigate to Messages Screen */ },
          ),
        ],
      ),
      body: Column(
        children: [
          const StartPostWidget(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No posts yet. Be the first to share!"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final post = Post.fromFirestore(snapshot.data!.docs[index]);
                    return PostCard(post: post);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- "Start a Post" Widget ---
class StartPostWidget extends StatelessWidget {
  const StartPostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final userProfile = profileProvider.userProfile;

    if (userProfile != null &&
        userProfile.userType == UserType.professional &&
        userProfile.isVerified) {
      return Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const CreatePostScreen(),
              fullscreenDialog: true,
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: userProfile.profilePictureUrl != null
                      ? NetworkImage(userProfile.profilePictureUrl!)
                      : null,
                  child: userProfile.profilePictureUrl == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text("Start a post", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// --- PostCard Widget (Now with Inline Follow Button) ---
class PostCard extends StatelessWidget {
  final Post post;
  final PostService _postService = locator<PostService>();

  PostCard({super.key, required this.post});

  Future<DocumentSnapshot?> _getAuthorDocument(String uid) async {
    final collections = ['professionals', 'students', 'general_users'];
    for (final collection in collections) {
      final doc = await FirebaseFirestore.instance.collection(collection).doc(uid).get();
      if (doc.exists) {
        return doc;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final isLiked = userId != null && post.likes.contains(userId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorHeader(context, userId),
            const SizedBox(height: 16),
            Text(post.content, style: const TextStyle(fontSize: 15)),
            if (post.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Image.network(post.imageUrl!),
              ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            _buildActionButtons(context, isLiked),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorHeader(BuildContext context, String? currentUserId) {
    return FutureBuilder<DocumentSnapshot?>(
      future: _getAuthorDocument(post.authorId),
      builder: (context, authorSnapshot) {
        if (!authorSnapshot.hasData || authorSnapshot.data == null) {
          return const Row(children: [CircleAvatar(radius: 22), SizedBox(width: 12), Text("Loading...")]);
        }
        final authorProfile = UserProfile.fromFirestore(authorSnapshot.data!);
        return Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: authorProfile.profilePictureUrl != null
                  ? NetworkImage(authorProfile.profilePictureUrl!)
                  : null,
              child: authorProfile.profilePictureUrl == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(authorProfile.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(authorProfile.headline, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            // Inline Follow Button Logic
            if (post.authorId != currentUserId) // Don't show follow button for your own posts
              Consumer<FollowingProvider>(
                builder: (context, followingProvider, child) {
                  final bool isFollowing = followingProvider.isFollowing(post.authorId);
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
                        followingProvider.unfollow(post.authorId);
                      } else {
                        followingProvider.follow(post.authorId);
                      }
                    },
                  );
                },
              )
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLiked) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton.icon(
          onPressed: () => _postService.toggleLike(post.id, post.likes),
          icon: Icon(
            isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
            color: isLiked ? Theme.of(context).primaryColor : Colors.grey,
            size: 20,
          ),
          label: Text("Like (${post.likeCount})"),
        ),
        _buildCommentButton(context),
        TextButton.icon(
          onPressed: () { /* TODO: Implement share */ },
          icon: const Icon(Icons.share, color: Colors.grey, size: 20),
          label: const Text("Share"),
        ),
      ],
    );
  }

  Widget _buildCommentButton(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(post.id)
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
                builder: (context) => CommentsScreen(postId: post.id),
              ),
            );
          },
        );
      },
    );
  }
}
