import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final Timestamp createdAt;
  final String imageUrl;
  final String content;

  Post({
    required this.id,
    required this.createdAt,
    required this.imageUrl,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt,
        'imageUrl': imageUrl,
        'content': content
      };
}
