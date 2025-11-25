import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentLikeButton extends StatelessWidget {
  final String postId;
  final String commentId;
  final int initialLikes;

  const CommentLikeButton({super.key, required this.postId, required this.commentId, required this.initialLikes});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('likes')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        bool isLiked = snapshot.hasData && snapshot.data!.exists;

        return InkWell(
          onTap: () async {
            final commentRef = FirebaseFirestore.instance
                .collection('posts').doc(postId).collection('comments').doc(commentId);
            final likeRef = commentRef.collection('likes').doc(user.uid);

            FirebaseFirestore.instance.runTransaction((transaction) async {
              final likeDoc = await transaction.get(likeRef);
              if (likeDoc.exists) {
                transaction.delete(likeRef);
                transaction.update(commentRef, {'likes': FieldValue.increment(-1)});
              } else {
                transaction.set(likeRef, {'timestamp': FieldValue.serverTimestamp()});
                transaction.update(commentRef, {'likes': FieldValue.increment(1)});
              }
            });
          },
          child: Column(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 14,
                color: isLiked ? Colors.red : Colors.grey,
              ),
              if (initialLikes > 0)
                Text('$initialLikes', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }
}

// like khusus replay
class ReplyLikeButton extends StatelessWidget {
  final String postId;
  final String commentId;
  final String replyId;
  final int initialLikes;

  const ReplyLikeButton({
    super.key,
    required this.postId,
    required this.commentId,
    required this.replyId,
    required this.initialLikes,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    // path database: posts -> comments -> replies -> likes
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .collection('likes')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        bool isLiked = snapshot.hasData && snapshot.data!.exists;

        return InkWell(
          onTap: () async {
            final replyRef = FirebaseFirestore.instance
                .collection('posts')
                .doc(postId)
                .collection('comments')
                .doc(commentId)
                .collection('replies')
                .doc(replyId);
            
            final likeRef = replyRef.collection('likes').doc(user.uid);

            FirebaseFirestore.instance.runTransaction((transaction) async {
              final likeDoc = await transaction.get(likeRef);
              if (likeDoc.exists) {
                transaction.delete(likeRef);
                transaction.update(replyRef, {'likes': FieldValue.increment(-1)});
              } else {
                transaction.set(likeRef, {'timestamp': FieldValue.serverTimestamp()});
                transaction.update(replyRef, {'likes': FieldValue.increment(1)});
              }
            });
          },
          child: Row(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 12,
                color: isLiked ? Colors.red : Colors.grey,
              ),
              if (initialLikes > 0) ...[
                const SizedBox(width: 4),
                Text('$initialLikes', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ],
          ),
        );
      },
    );
  }
}