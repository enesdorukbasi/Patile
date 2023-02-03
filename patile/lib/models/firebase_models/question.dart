import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String title;
  final String content;
  final String publishedUserId;
  final Timestamp createdTime;
  final bool isOk;

  Question(
      {required this.id,
      required this.title,
      required this.content,
      required this.publishedUserId,
      required this.createdTime,
      required this.isOk});

  factory Question.createQuestionByDoc(DocumentSnapshot doc) {
    return Question(
        id: doc.id,
        title: doc.get("title"),
        content: doc.get("content"),
        publishedUserId: doc.get("publishedUserId"),
        createdTime: doc.get("createdTime"),
        isOk: doc.get("isOk"));
  }
}
