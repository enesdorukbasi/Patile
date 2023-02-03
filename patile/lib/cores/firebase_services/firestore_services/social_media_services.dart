import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patile/cores/firebase_services/storage_services/storage_service.dart';
import 'package:patile/models/firebase_models/post.dart';

class SocialMediaFireStoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//Post

  Future<void> createPost({
    required List<String> images,
    required List<String> likedUsers,
    required String content,
    required String publishedUserId,
  }) async {
    await _firestore.collection('posts').doc().set({
      'imageOneUrl': images[0],
      'imageTwoUrl': images[1],
      'imageThreeUrl': images[2],
      'content': content,
      'createdTime': DateTime.now(),
      'publishedUserId': publishedUserId,
    });
  }

  Future<void> deletePost(postId) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('posts').doc(postId).get();

    snapshot.reference.delete();
  }

  Stream<QuerySnapshot> getAllPosts() {
    Stream<QuerySnapshot> snapshot = _firestore
        .collection("posts")
        .orderBy("createdTime", descending: true)
        .snapshots();

    return snapshot;
  }

  Future<List<Post>> getAllPostsByUserId(String currentUserId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('posts')
        .where('publishedUserId', isEqualTo: currentUserId)
        .get();

    List<Post> posts =
        snapshot.docs.map((e) => Post.createPostByDoc(e)).toList();

    posts.sort(
      (a, b) {
        return a.createdTime.toDate().compareTo(b.createdTime.toDate());
      },
    );

    return posts.reversed.toList();
  }

  deleteAllPostsByUserId(String currentUserId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('posts')
        .where('publishedUserId', isEqualTo: currentUserId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.map(
        (e) {
          if (e.exists) {
            if (e.get('imageOneUrl').toString().isNotEmpty) {
              StorageService().postImageDelete(e.get('imageOneUrl'));
            }
            if (e.get('imageTwoUrl').toString().isNotEmpty) {
              StorageService().postImageDelete(e.get('imageTwoUrl'));
            }
            if (e.get('imageThreeUrl').toString().isNotEmpty) {
              StorageService().postImageDelete(e.get('imageThreeUrl'));
            }
            e.reference.delete();
          }
        },
      );
    }
  }

  Future<List<Post>> getAllPostsByFilterUsers(List<String> users) async {
    QuerySnapshot snapshot = await _firestore
        .collection('posts')
        .where('publishedUserId', whereIn: users)
        .get();

    List<Post> posts =
        snapshot.docs.map((e) => Post.createPostByDoc(e)).toList();
    // List<Post> asd = posts.reversed.toList();
    posts.sort(
      (a, b) {
        return a.createdTime.toDate().compareTo(b.createdTime.toDate());
      },
    );

    return posts.reversed.toList();
  }

  //Comment
  Stream<QuerySnapshot> getAllCommentByPostId(String postId) {
    Stream<QuerySnapshot> snapshot = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots();

    return snapshot;
  }

  Stream<QuerySnapshot> getAllChildCommentsByPostAndParentId(
      String postId, String parentCommentId) {
    Stream<QuerySnapshot> snapshot = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(parentCommentId)
        .collection('childComments')
        .snapshots();

    return snapshot;
  }

  Future<void> createCommentPost(
      String postId, String content, String publishedUserId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc()
        .set(
      {
        'content': content,
        'publishedUserId': publishedUserId,
        'postId': postId,
        'createdTime': DateTime.now(),
      },
    );
  }

  Future<void> createChildCommentPost(String postId, String content,
      String publishedUserId, String parentCommentId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(parentCommentId)
        .collection('childComments')
        .doc()
        .set({
      'content': content,
      'publishedUserId': publishedUserId,
      'postId': postId,
      'parentCommentId': parentCommentId,
      'createdTime': DateTime.now(),
    });
  }

//Like

  Stream<QuerySnapshot> getLikesCountByPostId(postId) {
    Stream<QuerySnapshot> snapshot = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likedUsers')
        .snapshots();

    return snapshot;
  }

  Future<void> likePost(
      {required String postId, required String userId}) async {
    await _firestore
        .collection("posts")
        .doc(postId)
        .collection("likedUsers")
        .doc(userId)
        .set({});
  }

  Future<void> unlikePost(
      {required String postId, required String userId}) async {
    DocumentSnapshot snapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('likedUsers')
        .doc(userId)
        .get();

    if (snapshot.exists) {
      snapshot.reference.delete();
    }
  }

  Stream<DocumentSnapshot> userIsLikePost(
      {required String postId, required String userId}) {
    Stream<DocumentSnapshot>? snapshot = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likedUsers')
        .doc(userId)
        .snapshots();

    return snapshot;
  }
}
