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
import 'package:findom/models/blog_model.dart';
import 'package:findom/models/trending_topic_model.dart';
import 'package:findom/screens/home/blog_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<NewsArticle>> _newsFuture;
  late Future<List<TrendingTopic>> _trendingFuture;
  late Future<List<Blog>> _blogsFuture;
  final NewsService _newsService = NewsService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _newsFuture = _newsService.getTopHeadlines();
      _trendingFuture = _newsService.getTrendingTopics();
      _blogsFuture = _newsService.getBlogs();
    });
  }

  Future<void> _refresh() async {
    _loadData();
    await Future.wait([_newsFuture, _trendingFuture, _blogsFuture]);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProfileProvider>(context);
    final isPro = userProvider.userProfile?.isProfessional ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
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
                  const SizedBox(height: 24),
                  
                  // Market Updates
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Market Updates',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        // Optional: Add See All button if needed
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _NewsCarousel(newsFuture: _newsFuture),
                  
                  const SizedBox(height: 32),
                  
                  // Trending Topics
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Trending Topics',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TrendingTopicsSection(trendingFuture: _trendingFuture),
                  
                  const SizedBox(height: 32),
                  
                  // Latest Blogs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Latest Blogs',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to all blogs
                          },
                          child: Text(
                            'See All',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8), // Reduced spacing as BlogsSection has padding
                  _BlogsSection(blogsFuture: _blogsFuture),
                  
                  const SizedBox(height: 32),
                  
                  // Community Feed Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Community Feed',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
  final Future<List<NewsArticle>> newsFuture;
  const _NewsCarousel({required this.newsFuture});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: FutureBuilder<List<NewsArticle>>(
        future: newsFuture,
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
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          article.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      Padding(
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


class _TrendingTopicsSection extends StatelessWidget {
  final Future<List<TrendingTopic>> trendingFuture;
  const _TrendingTopicsSection({required this.trendingFuture});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: FutureBuilder<List<TrendingTopic>>(
        future: trendingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, index) => Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox.shrink();
          }

          final topics = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      topic.isTrendingUp ? Icons.trending_up : Icons.trending_down,
                      color: topic.isTrendingUp ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      topic.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BlogsSection extends StatelessWidget {
  final Future<List<Blog>> blogsFuture;
  const _BlogsSection({required this.blogsFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Blog>>(
      future: blogsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No blogs available"));
        }

        final blogs = snapshot.data!;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: blogs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final blog = blogs[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BlogDetailScreen(blog: blog)),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        blog.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blog.title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.blue[100],
                                child: Text(
                                  blog.author.isNotEmpty ? blog.author[0].toUpperCase() : 'A',
                                  style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  blog.author,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                blog.readTime,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}


