class Blog {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String content;
  final DateTime publishedAt;
  final String readTime;
  final String url;

  Blog({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.content,
    required this.publishedAt,
    required this.readTime,
    required this.url,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['url'] ?? DateTime.now().toString(), // Use URL as ID if available
      title: json['title'] ?? 'No Title',
      author: json['author'] ?? 'Unknown Author',
      imageUrl: json['urlToImage'] ?? 'https://via.placeholder.com/300',
      content: json['content'] ?? json['description'] ?? '',
      publishedAt: DateTime.parse(json['publishedAt'] ?? DateTime.now().toIso8601String()),
      readTime: '5 min read', // Placeholder or calculate based on content length
      url: json['url'] ?? '',
    );
  }
}
