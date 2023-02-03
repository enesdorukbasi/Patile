import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String imageOneUrl;
  final String imageTwoUrl;
  final String imageThreeUrl;
  final String content;
  final Timestamp createdTime;
  final String publishedUserId;

  Post({
    required this.id,
    required this.imageOneUrl,
    required this.imageTwoUrl,
    required this.imageThreeUrl,
    required this.content,
    required this.createdTime,
    required this.publishedUserId,
  });

  factory Post.createPostByDoc(DocumentSnapshot doc) {
    return Post(
      id: doc.id,
      imageOneUrl: doc.get('imageOneUrl'),
      imageTwoUrl: doc.get('imageTwoUrl'),
      imageThreeUrl: doc.get('imageThreeUrl'),
      content: doc.get('content'),
      createdTime: doc.get('createdTime'),
      publishedUserId: doc.get('publishedUserId'),
    );
  }
}
