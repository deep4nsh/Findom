import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:findom/models/blog_model.dart';
import 'package:findom/models/trending_topic_model.dart';

class NewsArticle {
  final String title;
  final String imageUrl;
  final String source;
  final String timeAgo;
  final String url;
  final String description;
  final DateTime publishedAt;

  NewsArticle({
    required this.title,
    required this.imageUrl,
    required this.source,
    required this.timeAgo,
    required this.url,
    required this.description,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      imageUrl: json['urlToImage'] ?? 'https://via.placeholder.com/300',
      source: json['source']?['name'] ?? 'Unknown Source',
      timeAgo: '', // Calculated later
      url: json['url'] ?? '',
      description: json['description'] ?? 'No description available.',
      publishedAt: DateTime.parse(json['publishedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class NewsService {
  static const String _apiKey = '2666247635a74b72a27b8be47d168cce'; // Replace with real key or use fallback
  static const String _baseUrl = 'https://newsapi.org/v2';

  Future<List<NewsArticle>> getTopHeadlines() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/top-headlines?country=in&category=business&apiKey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List)
            .where((json) => json['title'] != null && json['title'] != '[Removed]') // Filter removed articles
            .map((json) => NewsArticle.fromJson(json))
            .toList();
        
        if (articles.isEmpty) {
          return _getMockNews();
        }

        // Calculate timeAgo
        return articles.map((article) {
          final timeDiff = DateTime.now().difference(article.publishedAt);
          String timeAgo;
          if (timeDiff.inHours > 0) {
            timeAgo = '${timeDiff.inHours}h ago';
          } else {
            timeAgo = '${timeDiff.inMinutes}m ago';
          }
          return NewsArticle(
            title: article.title,
            imageUrl: article.imageUrl,
            source: article.source,
            timeAgo: timeAgo,
            url: article.url,
            description: article.description,
            publishedAt: article.publishedAt,
          );
        }).toList();
      } else {
        print('News API Error: ${response.statusCode} ${response.body}');
        return _getMockNews();
      }
    } catch (e) {
      print('Error fetching news: $e');
      return _getMockNews();
    }
  }

  Future<List<Blog>> getBlogs() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/everything?q=finance+investment&language=en&sortBy=publishedAt&apiKey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final blogs = (data['articles'] as List)
            .where((json) => json['title'] != null && json['title'] != '[Removed]')
            .map((json) => Blog.fromJson(json))
            .take(10) // Limit to 10 blogs
            .toList();
            
        if (blogs.isEmpty) {
          return _getMockBlogs();
        }
        
        return blogs;
      } else {
        return _getMockBlogs();
      }
    } catch (e) {
      print('Error fetching blogs: $e');
      return _getMockBlogs();
    }
  }

  Future<List<TrendingTopic>> getTrendingTopics() async {
    // Since NewsAPI doesn't have a direct "trending topics" endpoint, we'll mock this or derive it.
    // For now, returning curated trending topics in finance.
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      TrendingTopic(id: '1', name: 'Nifty 50', articleCount: 1250, isTrendingUp: true),
      TrendingTopic(id: '2', name: 'Crypto Regulation', articleCount: 850, isTrendingUp: true),
      TrendingTopic(id: '3', name: 'Gold Prices', articleCount: 620, isTrendingUp: false),
      TrendingTopic(id: '4', name: 'IPO Season', articleCount: 450, isTrendingUp: true),
      TrendingTopic(id: '5', name: 'RBI Policy', articleCount: 300, isTrendingUp: false),
    ];
  }

  List<NewsArticle> _getMockNews() {
    return [
      NewsArticle(
        title: "Sensex jumps 500 points as banking stocks rally",
        imageUrl: "https://plus.unsplash.com/premium_photo-1681487769650-a0c3fbaed85a?q=80&w=2955&auto=format&fit=crop",
        source: "MarketWatch",
        timeAgo: "2h ago",
        url: "https://example.com/news1",
        description: "The benchmark Sensex rallied over 500 points in early trade today, led by gains in HDFC Bank, ICICI Bank, and SBI. Nifty reclaimed the 19,500 mark.",
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NewsArticle(
        title: "RBI keeps repo rate unchanged at 6.5%",
        imageUrl: "https://images.unsplash.com/photo-1580519542036-c47de6196ba5?q=80&w=2942&auto=format&fit=crop",
        source: "Finance India",
        timeAgo: "4h ago",
        url: "https://example.com/news2",
        description: "The Reserve Bank of India's Monetary Policy Committee (MPC) has decided to keep the repo rate unchanged at 6.5% for the fourth consecutive time.",
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      NewsArticle(
        title: "Gold prices dip ahead of festive season",
        imageUrl: "https://images.unsplash.com/photo-1610375461490-67a3386e9a3b?q=80&w=2836&auto=format&fit=crop",
        source: "Commodity News",
        timeAgo: "6h ago",
        url: "https://example.com/news3",
        description: "Gold prices saw a slight correction today, falling by ₹200 per 10 grams, providing a buying opportunity for investors ahead of Diwali.",
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      NewsArticle(
        title: "Tech startups see 20% rise in funding in Q3",
        imageUrl: "https://images.unsplash.com/photo-1559136555-9303baea8ebd?q=80&w=2940&auto=format&fit=crop",
        source: "Startup Beat",
        timeAgo: "1d ago",
        url: "https://example.com/news4",
        description: "Indian tech startups raised \$2.5 billion in Q3 2024, marking a 20% increase from the previous quarter, signaling a revival in investor sentiment.",
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  List<Blog> _getMockBlogs() {
    return [
      Blog(
        id: '1',
        title: "5 Tips for Smart Investing in 2024",
        author: "Warren Buffet Fan",
        imageUrl: "https://images.unsplash.com/photo-1579535984712-a8f7d8b955f9?q=80&w=2874&auto=format&fit=crop",
        content: "Investing is a marathon, not a sprint. Here are 5 tips to help you navigate the market...",
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        readTime: "5 min read",
        url: "https://example.com/blog1",
      ),
      Blog(
        id: '2',
        title: "Understanding Mutual Funds: A Beginner's Guide",
        author: "Deepansh",
        imageUrl: "https://images.unsplash.com/photo-1565514020176-dbf2277cc168?q=80&w=2940&auto=format&fit=crop",
        content: "Mutual funds are a great way to diversify your portfolio. Let's break down how they work...",
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
        readTime: "8 min read",
        url: "https://example.com/blog2",
      ),
      Blog(
        id: '3',
        title: "The Future of Cryptocurrency in India",
        author: "Crypto King",
        imageUrl: "https://images.unsplash.com/photo-1518546305927-5a555bb7020d?q=80&w=2940&auto=format&fit=crop",
        content: "With new regulations on the horizon, what does the future hold for crypto investors in India?",
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        readTime: "6 min read",
        url: "https://example.com/blog3",
      ),
    ];
  }
}

