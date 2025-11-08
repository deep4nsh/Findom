import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findom/models/post_model.dart';
import 'package:findom/models/user_profile_model.dart';
import 'package:findom/services/locator.dart';
import 'package:findom/services/post_service.dart';
import 'package:findom/screens/auth/login_screen.dart';
import 'package:findom/screens/profile/profile_screen.dart';
import 'package:findom/screens/posts/create_post_screen.dart';
import 'package:findom/screens/posts/comments_screen.dart';
import 'package:findom/screens/search/search_screen.dart';
import 'package:findom/screens/jobs/job_board_screen.dart';
import 'package:findom/screens/find_a_pro/find_a_pro_screen.dart';
import 'home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: model.isDarkMode ? Colors.grey[900] : const Color(0xFFF4F6FA),
            drawer: buildDrawer(context, model),
            appBar: buildAppBar(context, model),
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
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final post = Post.fromFirestore(snapshot.data!.docs[index]);
                    return PostCard(post: post);
                  },
                );
              },
            ),
            floatingActionButton: const CreatePostButton(),
          );
        },
      ),
    );
  }

  Drawer buildDrawer(BuildContext context, HomeViewModel model) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3E4A89), Color(0xFF6C7ABF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Findom Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          buildDrawerTile(Icons.person_outline, 'Profile', () {
            final userId = FirebaseAuth.instance.currentUser?.uid;
            if (userId != null && context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: userId),
                ),
              );
            }
          }),
          buildDrawerTile(Icons.work_outline, 'Job Board', () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const JobBoardScreen()));
          }),
          buildDrawerTile(Icons.search, 'Find a Professional', () {
             Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FindAProScreen()));
          }),
          const Divider(),
          buildDrawerTile(Icons.logout, 'Logout', () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          }),
          const Divider(),
          darkModeToggle(model),
        ],
      ),
    );
  }

  Widget buildDrawerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(onTap: onTap, leading: Icon(icon), title: Text(title));
  }

  AppBar buildAppBar(BuildContext context, HomeViewModel model) {
    return AppBar(
      title: const Text("Feed"),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchScreen()));
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget darkModeToggle(HomeViewModel model) {
    return SwitchListTile(
      value: model.isDarkMode,
      title: const Text("Dark Mode"),
      onChanged: (value) {
        model.saveDarkModePreference(value);
      },
    );
  }
}

class CreatePostButton extends StatelessWidget {
  const CreatePostButton({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<DocumentSnapshot>(
      // Only professionals can create posts.
      future: FirebaseFirestore.instance.collection('professionals').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
           final userProfile = UserProfile.fromFirestore(snapshot.data!);
           if(userProfile.isVerified){
             return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                );
              },
              child: const Icon(Icons.add),
            );
           }
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final PostService _postService = locator<PostService>();

  PostCard({super.key, required this.post});

  Future<DocumentSnapshot?> _getAuthorDocument(String uid) async {
    final collections = ['professionals', 'students', 'general_users', 'companies'];
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
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<DocumentSnapshot?>(
              future: _getAuthorDocument(post.authorId),
              builder: (context, authorSnapshot) {
                if (!authorSnapshot.hasData) {
                  return const Text("Loading user...");
                }
                final authorProfile = UserProfile.fromFirestore(authorSnapshot.data!);
                return Text(authorProfile.fullName, style: const TextStyle(fontWeight: FontWeight.bold));
              },
            ),
            const SizedBox(height: 8),
            Text(post.content),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => _postService.toggleLike(post.id, post.likes),
                ),
                Text(post.likeCount.toString()),
                const SizedBox(width: 16),
                _buildCommentButton(context),
              ],
            )
          ],
        ),
      ),
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
          icon: const Icon(Icons.comment_outlined, color: Colors.grey),
          label: Text(commentCount.toString(), style: const TextStyle(color: Colors.grey)),
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
