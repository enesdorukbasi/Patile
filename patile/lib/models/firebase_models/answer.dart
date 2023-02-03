import 'package:cloud_firestore/cloud_firestore.dart';

class Answer {
  final String id;
  final String content;
  final String questionId;
  final String publishedUserId;
  final String parentCommentId;
  final Timestamp createdTime;

  Answer(
      {required this.id,
      required this.content,
      required this.questionId,
      required this.publishedUserId,
      required this.parentCommentId,
      required this.createdTime});

  factory Answer.createCommentByDoc(DocumentSnapshot doc) {
    return Answer(
        id: doc.id,
        content: doc.get("content"),
        questionId: doc.get("questionId"),
        publishedUserId: doc.get("publishedUserId"),
        parentCommentId: doc.get("parentCommentId"),
        createdTime: doc.get("createdTime"));
  }
}
