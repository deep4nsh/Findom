import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findom/models/user_profile_model.dart';
import 'package:findom/services/user_profile_provider.dart';
import 'package:findom/screens/posts/create_post_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:findom/widgets/post_card.dart';
import 'package:findom/screens/home/search_screen.dart';
import 'package:findom/screens/learn/calculator_list_screen.dart';
import 'package:findom/services/news_service.dart';
import 'package:findom/screens/home/news_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProfileProvider>(context);
    final isPro = userProvider.userProfile?.isProfessional ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Findom',
              style: GoogleFonts.poppins(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black87),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SearchScreen()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.message_outlined, color: Colors.black87),
                onPressed: () {
                  // TODO: Navigate to Messages
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _QuickActions(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Market Updates',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const _NewsCarousel(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Community Feed',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text("No posts yet. Be the first to share!")),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return PostCard(
                      postId: doc.id,
                      userId: data['authorId'] ?? '',
                      userName: data['authorName'] ?? 'Unknown',
                      userImage: data['authorProfilePictureUrl'],
                      content: data['content'] ?? '',
                      imageUrl: data['imageUrl'],
                      likes: List<String>.from(data['likes'] ?? []),
                      timestamp: (data['timestamp'] as Timestamp).toDate(),
                    );
                  },
                  childCount: snapshot.data!.docs.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: isPro
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostScreen()));
              },
              backgroundColor: Colors.blue[800],
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildActionItem(context, Icons.calculate_outlined, 'Tax Calc', () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculatorListScreen()));
          }),
          const SizedBox(width: 24),
          _buildActionItem(context, Icons.percent_outlined, 'GST', () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculatorListScreen()));
          }),
          const SizedBox(width: 24),
          _buildActionItem(context, Icons.work_outline, 'Post Job', () {
             // TODO: Navigate to Post Job
          }),
          const SizedBox(width: 24),
          _buildActionItem(context, Icons.newspaper_outlined, 'News', () {
             // Scroll to news section or open news tab
          }),
          const SizedBox(width: 24),
          _buildActionItem(context, Icons.alarm, 'Reminders', () {
             Navigator.pushNamed(context, '/reminders');
          }),
          const SizedBox(width: 24),
          _buildActionItem(context, Icons.explore_outlined, 'Explore', () {
             Navigator.pushNamed(context, '/explore');
          }),
          const SizedBox(width: 24),
          _buildActionItem(context, Icons.calculate_outlined, 'SIP Calc', () {
             Navigator.pushNamed(context, '/sip-calculator');
          }),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsCarousel extends StatelessWidget {
  const _NewsCarousel();

  @override
  Widget build(BuildContext context) {
    final newsService = NewsService();

    return SizedBox(
      height: 180,
      child: FutureBuilder<List<NewsArticle>>(
        future: newsService.getTopHeadlines(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Failed to load news"));
          }

          final articles = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewsDetailScreen(article: article)),
                  );
                },
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(article.imageUrl),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.source,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
