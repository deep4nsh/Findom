class NewsArticle {
  final String title;
  final String imageUrl;
  final String source;
  final String timeAgo;
  final String url;
  final String description;

  NewsArticle({
    required this.title,
    required this.imageUrl,
    required this.source,
    required this.timeAgo,
    required this.url,
    required this.description,
  });
}

class NewsService {
  // Simulating API call
  Future<List<NewsArticle>> getTopHeadlines() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    return [
      NewsArticle(
        title: "Sensex jumps 500 points as banking stocks rally",
        imageUrl: "https://images.unsplash.com/photo-1611974765270-ca1258634369?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
        source: "MarketWatch",
        timeAgo: "2h ago",
        url: "https://example.com/news1",
        description: "The benchmark Sensex rallied over 500 points in early trade today, led by gains in HDFC Bank, ICICI Bank, and SBI. Nifty reclaimed the 19,500 mark.",
      ),
      NewsArticle(
        title: "RBI keeps repo rate unchanged at 6.5%",
        imageUrl: "https://images.unsplash.com/photo-1621981386829-9b747604ecf2?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
        source: "Finance India",
        timeAgo: "4h ago",
        url: "https://example.com/news2",
        description: "The Reserve Bank of India's Monetary Policy Committee (MPC) has decided to keep the repo rate unchanged at 6.5% for the fourth consecutive time.",
      ),
      NewsArticle(
        title: "Gold prices dip ahead of festive season",
        imageUrl: "https://images.unsplash.com/photo-1610375461490-67a3386e9a3b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
        source: "Commodity News",
        timeAgo: "6h ago",
        url: "https://example.com/news3",
        description: "Gold prices saw a slight correction today, falling by ₹200 per 10 grams, providing a buying opportunity for investors ahead of Diwali.",
      ),
      NewsArticle(
        title: "Tech startups see 20% rise in funding in Q3",
        imageUrl: "https://images.unsplash.com/photo-1519389950473-47ba0277781c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
        source: "Startup Beat",
        timeAgo: "1d ago",
        url: "https://example.com/news4",
        description: "Indian tech startups raised \$2.5 billion in Q3 2024, marking a 20% increase from the previous quarter, signaling a revival in investor sentiment.",
      ),
    ];
  }
}
