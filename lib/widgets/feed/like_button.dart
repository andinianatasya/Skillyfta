import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final String postId;
  final int initialLikes;

  const LikeButton({super.key, required this.postId, required this.initialLikes});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        bool isLiked = snapshot.hasData && snapshot.data!.exists;

        return InkWell(
          onTap: () async {
            final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
            final likeRef = postRef.collection('likes').doc(user.uid);

            FirebaseFirestore.instance.runTransaction((transaction) async {
              final likeDoc = await transaction.get(likeRef);
              if (likeDoc.exists) {
                transaction.delete(likeRef);
                transaction.update(postRef, {'likes': FieldValue.increment(-1)});
              } else {
                transaction.set(likeRef, {'timestamp': FieldValue.serverTimestamp()});
                transaction.update(postRef, {'likes': FieldValue.increment(1)});
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isLiked ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  '$initialLikes', 
                  style: TextStyle(
                    fontSize: 13, 
                    color: isLiked ? Colors.red : Colors.grey[600],
                    fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}