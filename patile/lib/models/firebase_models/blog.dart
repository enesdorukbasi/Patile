import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  final String id;
  final String title;
  final String content;
  final Timestamp createdTime;
  final String publishedUserId;

  Blog(
      {required this.id,
      required this.title,
      required this.content,
      required this.createdTime,
      required this.publishedUserId});

  factory Blog.createBlogByDoc(DocumentSnapshot doc) {
    return Blog(
        id: doc.id,
        title: doc.get("title"),
        content: doc.get("content"),
        createdTime: doc.get("createdTime"),
        publishedUserId: doc.get("publishedUserId"));
  }
}
