import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillyfta/utils/ui_helper.dart';
import 'package:skillyfta/widgets/feed/like_reply_button.dart';

class CommentItem extends StatefulWidget {
  final String postId;
  final String commentId;
  final Map<String, dynamic> data;
  final Function(String commentId, String userName, String targetUserId)
  onReply;
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
    final bool isOwner =
        currentUser != null && currentUser.uid == data['userId'];

    final int replyCount = data['replyCount'] ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(data['userId'])
            .snapshots(),
        builder: (context, snapshot) {
          String displayName = widget.data['userName'] ?? 'User';
          String displayInitial = 'U';

          if (displayName.isNotEmpty) {
            displayInitial = displayName[0].toUpperCase();
          }

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
                radius: 18,
                backgroundColor: Colors.grey[200],
                child: Text(
                  displayInitial,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF667EEA),
                  ),
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
                            text: "$displayName ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: context.s(15),
                            ),
                          ),
                          TextSpan(
                            text: data['content'] ?? '',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: context.s(15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: context.s(12),
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: () => widget.onReply(
                            widget.commentId,
                            displayName,
                            data['userId'],
                          ),
                          child: Text(
                            "Balas",
                            style: TextStyle(
                              fontSize: context.s(12),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
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
                                color: Colors.redAccent,
                              ),
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
                              Container(
                                width: 30,
                                height: 1,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _showReplies
                                    ? "Sembunyikan balasan"
                                    : "Lihat $replyCount balasan lainnya",
                                style: TextStyle(
                                  fontSize: context.s(12),
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (_showReplies)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .doc(widget.postId)
                            .collection('comments')
                            .doc(widget.commentId)
                            .collection('replies')
                            .orderBy('timestamp', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 10,
                                width: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                            return const SizedBox();

                          final replies = snapshot.data!.docs;
                          return Column(
                            children: replies.map((replyDoc) {
                              final replyData =
                                  replyDoc.data() as Map<String, dynamic>;
                              return _buildReplyItem(
                                widget.postId,
                                widget.commentId,
                                replyDoc.id,
                                replyData,
                                context.s,
                                _formatTimeAgo,
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
                initialLikes: data['likes'] ?? 0,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReplyItem(
    String postId,
    String commentId,
    String replyId,
    Map<String, dynamic> data,
    double Function(double) fs,
    String Function(Timestamp?) formatTime,
  ) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner =
        currentUser != null && currentUser.uid == data['userId'];

    String timeAgo = formatTime(data['timestamp'] as Timestamp?);

    final String? targetUserId = data['targetUserId'];

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
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc(replyId)
            .delete();

        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({'replyCount': FieldValue.increment(-1)});
      } catch (e) {
        print(e);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(data['userId'])
            .snapshots(),
        builder: (context, authorSnapshot) {
          String authorName = data['userName'] ?? 'User';
          String authorInitial = 'U';

          if (authorSnapshot.hasData && authorSnapshot.data!.exists) {
            final userData =
                authorSnapshot.data!.data() as Map<String, dynamic>?;
            authorName = userData?['fullName'] ?? authorName;
          }
          if (authorName.isNotEmpty)
            authorInitial = authorName[0].toUpperCase();

          return StreamBuilder<DocumentSnapshot>(
            stream: (targetUserId != null)
                ? FirebaseFirestore.instance
                      .collection('users')
                      .doc(targetUserId)
                      .snapshots()
                : null,
            builder: (context, targetSnapshot) {
              String targetName = "";
              if (targetSnapshot.hasData &&
                  targetSnapshot.data != null &&
                  targetSnapshot.data!.exists) {
                final targetData =
                    targetSnapshot.data!.data() as Map<String, dynamic>?;
                targetName = targetData?['fullName'] ?? "";
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey[200],
                    child: Text(
                      authorInitial,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "$authorName ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: fs(14),
                                ),
                              ),

                              if (targetName.isNotEmpty)
                                TextSpan(
                                  text:
                                      "@$targetName ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                    fontSize: fs(14),
                                  ),
                                ),

                              TextSpan(
                                text: data['content'] ?? '',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: fs(14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              timeAgo,
                              style: TextStyle(
                                fontSize: fs(10),
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () => widget.onReply(
                                commentId,
                                authorName,
                                data['userId'],
                              ),
                              child: Text(
                                "Balas",
                                style: TextStyle(
                                  fontSize: fs(10),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            if (isOwner) ...[
                              const SizedBox(width: 12),
                              InkWell(
                                onTap:
                                    deleteThisReply,
                                child: Text(
                                  "Hapus",
                                  style: TextStyle(
                                    fontSize: fs(10),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: ReplyLikeButton(
                      postId: postId,
                      commentId: commentId,
                      replyId: replyId,
                      initialLikes: data['likes'] ?? 0,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}