import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String createdBy;
  final Timestamp createdAt;
  final String imageUrl;
  final String content;
  final dynamic likes;

  Post({
    required this.id,
    required this.userId,
    required this.createdBy,
    required this.createdAt,
    required this.imageUrl,
    required this.content,
    required this.likes,
  });

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'userId': userId,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'imageUrl': imageUrl,
        'content': content,
        'likes': likes
      };

  static Post fromJson(Map<String, dynamic> json) =>
      Post(
          id: json['id'],
          userId: json['userId'],
          createdBy: json['createdBy'],
          createdAt: json['createdAt'],
          imageUrl: json['imageUrl'],
          content: json['content'],
          likes: json['likes']
      );
}
