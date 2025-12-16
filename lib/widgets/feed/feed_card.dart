import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'like_button.dart';
import 'comment_sheet.dart';

class FeedCard extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> data;

  const FeedCard({super.key, required this.postId, required this.data});

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    final now = DateTime.now();
    final diff = now.difference(timestamp.toDate());
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    if (diff.inDays < 7) return '${diff.inDays}h';
    return '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
  }

  Color _getBadgeColor(String? category) {
    switch (category) {
      case 'Progress': return const Color(0xFF42A5F5);
      case 'Learning': return const Color(0xFFFFA726);
      case 'Challenge': return const Color(0xFFE91E63);
      case 'Tips': return const Color(0xFFFFCA28);
      case 'Achievement': return const Color(0xFF66BB6A);
      default: return const Color(0xFF667EEA);
    }
  }

  String _getBadgeIcon(String? category) {
    String cat = (category ?? 'progress').toLowerCase();
    return 'assets/images/$cat.png';
  }

  Future<void> _deletePost(BuildContext context, String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Postingan?"),
        content: const Text("Postingan ini beserta semua komentar dan like akan dihapus permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final postRef = firestore.collection('posts').doc(postId);

      final batch = firestore.batch();

      final likesSnapshot = await postRef.collection('likes').get();
      for (var doc in likesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      final commentsSnapshot = await postRef.collection('comments').get();
      for (var commentDoc in commentsSnapshot.docs) {

        final repliesSnapshot = await commentDoc.reference.collection('replies').get();
        for (var replyDoc in repliesSnapshot.docs) {
          batch.delete(replyDoc.reference);
        } 
        batch.delete(commentDoc.reference);
      }

      batch.delete(postRef);

      await batch.commit();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Postingan berhasil dihapus."), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showCommentSheet(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentSheet(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String category = data['category'] ?? 'Progress';
    final Color badgeColor = _getBadgeColor(category);
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner = currentUser != null && currentUser.uid == data['userId'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: badgeColor, width: 4)),
        boxShadow: [
          BoxShadow(color: badgeColor.withOpacity(0.1), spreadRadius: 0, blurRadius: 12, offset: const Offset(0, 3)),
          BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 0, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(data['userId'])
                .snapshots(),
            builder: (context, snapshot) {
              
              String displayName = data['userName'] ?? 'User';
              String displayInitial = 'U';

              if (snapshot.hasData && snapshot.data!.exists) {
                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                if (userData != null) {
                  String newName = userData['fullName'] ?? displayName;
                  
                  if (newName.isNotEmpty) {
                    displayName = newName;
                    displayInitial = newName[0].toUpperCase();
                  }
                }
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: badgeColor,
                    child: Text(
                      displayInitial,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 15,
                            color: Colors.black87
                          )
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              _formatTimestamp(data['timestamp'] as Timestamp?), 
                              style: TextStyle(fontSize: 11, color: Colors.grey[600])
                            ),
                            const SizedBox(width: 8),
                            Image.asset(_getBadgeIcon(category), height: 14, width: 14, errorBuilder: (_,__,___) => const SizedBox()),
                            const SizedBox(width: 4),
                            Text(category, style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isOwner)
                    InkWell(
                      onTap: () => _deletePost(context, postId),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.delete_outline, size: 20, color: Colors.grey[400]),
                      ),
                    ),
                ],
              );
            }
          ),
          const SizedBox(height: 12),
          Text(data['content'] ?? '', style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: [
              LikeButton(postId: postId, initialLikes: data['likes'] ?? 0),
              const SizedBox(width: 20),
              InkWell(
                onTap: () => _showCommentSheet(context, postId),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 20, color: const Color(0xFF757575)),
                      const SizedBox(width: 6),
                      Text('${data['comments'] ?? 0}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}