import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patile/models/firebase_models/question.dart';

class QuestionAndAnswersFirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime nowTime = DateTime.now();

  Future<void> createQuestion(title, content, publishedUserId, isOk) async {
    await _firestore.collection("questions").doc().set({
      "title": title,
      "content": content,
      "publishedUserId": publishedUserId,
      "createdTime": nowTime,
      "isOk": isOk
    });
  }

  Future<void> updateQuestion(Question question) async {
    await _firestore.collection("questions").doc(question.id).update({
      "title": question.title,
      "content": question.content,
      "publishedUserId": question.publishedUserId,
      "createdTime": question.createdTime,
      "isOk": !question.isOk,
    });
  }

  Future<void> deleteQuestion(questionId) async {
    DocumentSnapshot doc =
        await _firestore.collection('questions').doc(questionId).get();
    if (doc.exists) {
      doc.reference.delete();
    }
  }

  deleteAllQuestionsByUserId(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("questions")
        .where("publishedUserId", isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.map(
        (e) {
          if (e.exists) {
            deleteAnswersByQuestionId(e.id);
            e.reference.delete();
          }
        },
      );
    }
  }

  deleteAnswersByQuestionId(questionId) async {
    await _firestore.collection('answers').doc(questionId).get().then(
      (value) {
        if (value.exists) {
          value.reference.delete();
        }
      },
    );
  }

  Future<void> createComment(
      content, questionId, publishedUserId, parentCommentId) async {
    if (parentCommentId == "" || parentCommentId == null) {
      await _firestore
          .collection("answers")
          .doc(questionId)
          .collection("questionInAnswer")
          .doc()
          .set({
        "content": content,
        "questionId": questionId,
        "publishedUserId": publishedUserId,
        "parentCommentId": "",
        "createdTime": nowTime,
      });
    } else {
      await _firestore
          .collection("answers")
          .doc(questionId)
          .collection("answerInAnswer")
          .doc()
          .set({
        "content": content,
        "questionId": questionId,
        "publishedUserId": publishedUserId,
        "parentCommentId": parentCommentId,
        "createdTime": nowTime,
      });
    }
  }

  Stream<QuerySnapshot> getAllQuestions() {
    Stream<QuerySnapshot> snapshot = _firestore
        .collection("questions")
        .orderBy("createdTime", descending: true)
        .snapshots();

    return snapshot;
  }

  // ignore: non_constant_identifier_names
  Stream<DocumentSnapshot> getQuestionById(String QuestionId) {
    Stream<DocumentSnapshot> doc =
        _firestore.collection('questions').doc(QuestionId).snapshots();
    return doc;
  }

  Stream<QuerySnapshot> getAllAnswers(questionId) {
    Stream<QuerySnapshot> snapshot = _firestore
        .collection("answers")
        .doc(questionId)
        .collection("questionInAnswer")
        .orderBy("createdTime", descending: true)
        .snapshots();
    return snapshot;
  }
}
