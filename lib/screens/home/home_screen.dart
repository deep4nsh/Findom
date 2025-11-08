import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:findom/models/post_model.dart';
import 'package:findom/models/user_profile_model.dart';
import 'package:findom/services/locator.dart';
import 'package:findom/services/post_service.dart';
import 'package:findom/services/user_profile_provider.dart';
import 'package:findom/screens/posts/comments_screen.dart';
import 'package:findom/screens/search/search_screen.dart';
import 'package:findom/screens/posts/create_post_screen.dart';
import 'package:findom/screens/auth/login_screen.dart';
import 'home_view_model.dart';

// --- Main HomeScreen Widget ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, model, child) {
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
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
            body: StreamBuilder<QuerySnapshot>(
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
            floatingActionButton: const CreatePostButton(), // Use the refactored button
          );
        },
      ),
    );
  }
}

// --- CreatePostButton (Refactored to use Provider) ---
class CreatePostButton extends StatelessWidget {
  const CreatePostButton({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final userProfile = profileProvider.userProfile;

    if (userProfile != null &&
        userProfile.userType == UserType.professional) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        child: const Icon(Icons.add),
      );
    }

    return const SizedBox.shrink();
  }
}

// --- PostCard Widget ---
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
            _buildAuthorHeader(context),
            const SizedBox(height: 16),
            Text(post.content, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            const Divider(height: 1),
            _buildActionButtons(context, isLiked),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorHeader(BuildContext context) {
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(authorProfile.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(authorProfile.headline, style: Theme.of(context).textTheme.bodySmall),
              ],
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
