import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String content;
  final Timestamp timestamp;
  final List<String> likes;

  Post({
    required this.id,
    required this.authorId,
    required this.content,
    required this.timestamp,
    this.likes = const [],
  });

  int get likeCount => likes.length;

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'content': content,
      'timestamp': timestamp,
      'likes': likes,
    };
  }
}
