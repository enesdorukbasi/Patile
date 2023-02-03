import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patile/models/firebase_models/blog.dart';

class BlogFirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime nowTime = DateTime.now();

  Future<void> createBlog(title, content, publishedUserId) async {
    await _firestore.collection("blogs").doc().set({
      "title": title,
      "content": content,
      "createdTime": nowTime,
      "publishedUserId": publishedUserId
    });
  }

  deleteAllBlogsByUserId(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("blogs")
        .where("publishedUserId", isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.map((e) {
        e.reference.delete();
      });
    }
  }

  Future<List<Blog>> getAllBlogs() async {
    QuerySnapshot snapshot = await _firestore.collection("blogs").get();

    List<Blog> blogs =
        snapshot.docs.map((e) => Blog.createBlogByDoc(e)).toList();
    return blogs;
  }

  Future<List<Blog>> getAllBlogsByUserId(publishedUserId) async {
    QuerySnapshot snapshot = await _firestore.collection("blogs").get();

    List<Blog> blogs =
        snapshot.docs.map((e) => Blog.createBlogByDoc(e)).toList();

    List<Blog> filterBlogs = blogs
        .where((element) => element.publishedUserId == publishedUserId)
        .toList();
    return filterBlogs;
  }
}
