import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillyfta/utils/ui_helper.dart';
import 'package:skillyfta/widgets/feed/like_reply_button.dart';

class CommentItem extends StatefulWidget {
  final String postId;
  final String commentId;
  final Map<String, dynamic> data;
  final Function(String commentId, String userName, String targetUserId) onReply;
  final Function(String commentId) onDelete;

  const CommentItem({
    super.key,
    required this.postId,
    required this.commentId,
    required this.data,
    required this.onReply,
    required this.onDelete,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _showReplies = false;

  String _formatTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return "Baru saja";
    
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return "Baru saja";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}j";
    } else if (diff.inDays < 7) {
      return "${diff.inDays}h";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    String timeAgo = _formatTimeAgo(data['timestamp'] as Timestamp?);

    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner = currentUser != null && currentUser.uid == data['userId'];
    
    // jumlah balasan
    final int replyCount = data['replyCount'] ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[200],
            child: Text(
              data['userInitial'] ?? 'U', 
              style: const TextStyle(
                fontSize: 16, color: Color(0xFF667EEA)
              )
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${data['userName'] ?? 'User'} ", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Colors.black, 
                          fontSize: context.s(15) 
                        )
                      ),
                      TextSpan(
                        text: data['content'] ?? '', 
                        style: TextStyle(
                          color: Colors.black87, 
                          fontSize: context.s(15)
                        )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Text(timeAgo, style: TextStyle(fontSize: context.s(12), color: Colors.grey)),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => widget.onReply(widget.commentId, data['userName'], data['userId']),
                      child: Text(
                        "Balas", 
                        style: TextStyle(
                          fontSize: context.s(12), 
                          fontWeight: FontWeight.bold, 
                          color: Colors.grey
                        )
                      ),
                    ),
                    if (isOwner) ...[
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () => widget.onDelete(widget.commentId),
                        child: Text(
                          "Hapus", 
                          style: TextStyle(
                            fontSize: context.s(12), 
                            fontWeight: FontWeight.bold, 
                            color: Colors.redAccent
                          )
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                if (replyCount > 0)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showReplies = !_showReplies;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(width: 30, height: 1, color: Colors.grey[300]),
                          const SizedBox(width: 10),
                          Text(
                            _showReplies 
                                ? "Sembunyikan balasan" 
                                : "Lihat $replyCount balasan lainnya",
                            style: TextStyle(fontSize: context.s(12), color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_showReplies)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                  .collection('posts').doc(widget.postId)
                  .collection('comments').doc(widget.commentId)
                  .collection('replies')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0), 
                        child: SizedBox(
                          height: 10, width: 10, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        )
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
                    
                    final replies = snapshot.data!.docs;
                    return Column(
                      children: replies.map((replyDoc) {
                        final replyData = replyDoc.data() as Map<String, dynamic>;
                        return _buildReplyItem(
                          widget.postId, 
                          widget.commentId, 
                          replyDoc.id, 
                          replyData,
                          context.s,
                          _formatTimeAgo
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          // Like Button
          CommentLikeButton(
            postId: widget.postId,
            commentId: widget.commentId,
            initialLikes: data['likes'] ?? 0
          ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(String postId, String commentId, String replyId, Map<String, dynamic> data, double Function(double) fs, String Function(Timestamp?) formatTime) {

    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner = currentUser != null && currentUser.uid == data['userId'];
    
    String timeAgo = formatTime(data['timestamp'] as Timestamp?);

    Future<void> deleteThisReply() async {
       final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Hapus Balasan?"),
          content: const Text("Balasan ini akan dihapus permanen."),
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
         await FirebaseFirestore.instance
             .collection('posts').doc(postId)
             .collection('comments').doc(commentId)
             .collection('replies').doc(replyId)
             .delete();
         
         // Kurangi replyCount
         await FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').doc(commentId).update({'replyCount': FieldValue.increment(-1)});
       } catch(e) { print(e); }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12, backgroundColor: Colors.grey[200], 
            child: Text(
              data['userInitial'] ?? 'U', 
              style: const TextStyle(
                fontSize: 14, color: Color(0xFF667EEA)
              )
            )
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${data['userName'] ?? 'User'} ", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black, fontSize: context.s(14)
                        )
                      ), 
                      TextSpan(
                        text: data['content'] ?? '', 
                        style: TextStyle(
                          color: Colors.black87, fontSize: context.s(14)
                        )
                      )
                    ],
                  )
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(timeAgo, style: TextStyle(fontSize: context.s(11), color: Colors.grey)),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => widget.onReply(commentId, data['userName'], data['userId']), 
                      child: Text("Balas", style: TextStyle(fontSize: context.s(11), fontWeight: FontWeight.bold, color: Colors.grey))
                    ),
                    if (isOwner) ...[
                      const SizedBox(width: 12), 
                      InkWell(
                        onTap: deleteThisReply, 
                        child: Text("Hapus", style: TextStyle(fontSize: context.s(11), fontWeight: FontWeight.bold, color: Colors.redAccent))
                      )
                    ]
                  ]
                )
              ]
            ),
          ),
          // Like Button Reply
          Padding(
            padding: const EdgeInsets.only(top: 2), 
            child: ReplyLikeButton(
              postId: postId, commentId: commentId, replyId: replyId, initialLikes: data['likes'] ?? 0
            )
          ),
        ],
      ),
    );
  }
}