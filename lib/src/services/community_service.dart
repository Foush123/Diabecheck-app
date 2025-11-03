import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../data/models.dart';

class CommunityService {
  CommunityService._internal();
  static final CommunityService instance = CommunityService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Future<fb.User> _ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  Stream<List<CommunityPost>> streamPosts({String? category}) {
    Query<Map<String, dynamic>> q = _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(100);
    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }
    final uid = _auth.currentUser?.uid;
    return q.snapshots().map((snap) => snap.docs.map((d) {
      final data = d.data();
      final likedBy = (data['likedBy'] as List?)?.cast<String>() ?? const <String>[];
      final withDerived = {
        ...data,
        'likesCount': (data['likesCount'] as num?)?.toInt() ?? likedBy.length,
        'commentsCount': (data['commentsCount'] as num?)?.toInt() ?? 0,
      };
      final post = CommunityPost.fromDoc(d.id, withDerived);
      return uid == null ? post : CommunityPost(
        id: post.id,
        userId: post.userId,
        userName: post.userName,
        category: post.category,
        content: post.content,
        createdAt: post.createdAt,
        imageUrl: post.imageUrl,
        likesCount: post.likesCount,
        commentsCount: post.commentsCount,
        isLikedByMe: likedBy.contains(uid),
      );
    }).toList());
  }

  Future<void> createPost({
    required String content,
    required String category,
    String? imageUrl,
  }) async {
    final user = await _ensureSignedIn();
    final data = {
      'userId': user.uid,
      'userName': user.isAnonymous ? 'Anonymous' : (user.displayName ?? 'User'),
      'category': category,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'likesCount': 0,
      'commentsCount': 0,
    };
    await _db.collection('posts').add(data);
  }

  Future<void> toggleLike(String postId) async {
    final user = await _ensureSignedIn();
    final postRef = _db.collection('posts').doc(postId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(postRef);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final likedBy = (data['likedBy'] as List?)?.cast<String>() ?? <String>[];
      final hasLiked = likedBy.contains(user.uid);
      final newLikedBy = List<String>.from(likedBy);
      if (hasLiked) {
        newLikedBy.remove(user.uid);
      } else {
        newLikedBy.add(user.uid);
      }
      final newLikes = newLikedBy.length;
      tx.update(postRef, {
        'likedBy': newLikedBy,
        'likesCount': newLikes,
      });
    });
  }

  Stream<List<PostComment>> streamComments(String postId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .limit(200)
        .snapshots()
        .map((s) => s.docs.map((d) => PostComment.fromDoc(d.id, d.data())).toList());
  }

  Future<void> addComment({required String postId, required String text}) async {
    final user = await _ensureSignedIn();
    final commentsRef = _db.collection('posts').doc(postId).collection('comments');
    await _db.runTransaction((tx) async {
      final postRef = _db.collection('posts').doc(postId);
      final snap = await tx.get(postRef);
      // All reads are completed above; now perform writes
      tx.set(commentsRef.doc(), {
        'userId': user.uid,
        'userName': user.isAnonymous ? 'Anonymous' : (user.displayName ?? 'User'),
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        final count = (data['commentsCount'] as num?)?.toInt() ?? 0;
        tx.update(postRef, {'commentsCount': count + 1});
      }
    });
  }
}


