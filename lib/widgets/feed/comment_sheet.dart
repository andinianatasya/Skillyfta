import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillyfta/utils/ui_helper.dart';
import 'package:skillyfta/widgets/feed/comment_item.dart';

class CommentSheet extends StatefulWidget {
  final String postId;
  const CommentSheet({super.key, required this.postId});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isReplying = false;
  String? _replyToCommentId;
  String? _replyToUserName;
  bool _isSending = false;
  String? _replyToUserId;

  // Fungsi Kirim Komentar
  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final userName = userData?['fullName'] ?? 'User';
      final userInitial = userData?['fullName'] != null ? userData!['fullName'][0].toUpperCase() : 'U';

      final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      if (_isReplying && _replyToCommentId != null) {
        final commentRef = postRef.collection('comments').doc(_replyToCommentId);
        
        await commentRef.collection('replies').add({
          'content': text,
          'userId': user.uid,
          'userName': userName,
          'userInitial': userInitial,
          'timestamp': FieldValue.serverTimestamp(),
          'likes': 0,
        });
        
        await commentRef.update({'replyCount': FieldValue.increment(1)});

        if (_replyToUserId != null && _replyToUserId != user.uid) {
           await FirebaseFirestore.instance
               .collection('users')
               .doc(_replyToUserId)
               .collection('notifications')
               .add({
                 'type': 'reply',
                 'fromUserId': user.uid,
                 'fromUserName': userName,
                 'fromUserInitial': userInitial,
                 'postId': widget.postId,
                 'content': text,
                 'timestamp': FieldValue.serverTimestamp(),
                 'isRead': false,
               });
        }

      } else {
        await postRef.collection('comments').add({
          'content': text,
          'userId': user.uid,
          'userName': userName,
          'userInitial': userInitial,
          'timestamp': FieldValue.serverTimestamp(),
          'likes': 0,
        });
        await postRef.update({'comments': FieldValue.increment(1)});
      }

      _commentController.clear();
      _cancelReplyMode();
      FocusScope.of(context).unfocus();

    } catch (e) {
      print("Error sending comment: $e");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Komentar?"),
        content: const Text("Komentar ini akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final postRef = firestore.collection('posts').doc(widget.postId);
      final commentRef = postRef.collection('comments').doc(commentId);
      
      final batch = firestore.batch();

      final likesSnapshot = await commentRef.collection('likes').get();
      for (var doc in likesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      final repliesSnapshot = await commentRef.collection('replies').get();
      for (var doc in repliesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(commentRef);

      batch.update(postRef, {'comments': FieldValue.increment(-1)});

      await batch.commit();

    } catch (e) { 
      print("Gagal: $e"); 
    }
  }

  void _startReply(String parentCommentId, String targetUserName, String targetUserId) {
    setState(() {
      _isReplying = true;
      _replyToCommentId = parentCommentId;
      _replyToUserName = targetUserName;
      _replyToUserId = targetUserId;
    });
    
    _commentFocusNode.requestFocus();
    _commentController.text = "@$targetUserName "; 
    
    _commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentController.text.length)
    );
  }

  void _cancelReplyMode() {
    setState(() {
      _isReplying = false;
      _replyToCommentId = null;
      _replyToUserName = null;
      _commentController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
          ),
          const Text(
            "Komentar", 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16, 
              color: Colors.black87
            )
          ),
          const Divider(color: Color(0xFFC1BDBD)),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                    "Belum ada komentar.", 
                      style: TextStyle(
                        color: Colors.grey
                      )
                    )
                  );
                }
                final comments = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: comments.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final commentDoc = comments[index];
                    final data = commentDoc.data() as Map<String, dynamic>;
                    return CommentItem(
                      postId: widget.postId,
                      commentId: commentDoc.id,
                      data: data,
                      onReply: _startReply, 
                      onDelete: _deleteComment,
                    );
                  },
                );
              },
            ),
          ),

          if (_isReplying)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Text("Membalas ${_replyToUserName}...", style: TextStyle(color: Colors.grey[600], fontSize: context.s(14))),
                  const Spacer(),
                  InkWell(
                    onTap: _cancelReplyMode,
                    child: Icon(Icons.close, size: context.s(16), color: Colors.grey),
                  )
                ],
              ),
            ),

          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 10,
              left: 16, 
              right: 16, 
              top: 10
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14, 
                    ),
                      
                    cursorColor: const Color(0xFF667EEA),

                    decoration: InputDecoration(
                      hintText: _isReplying ? "Tulis balasan..." : "Tulis komentar...",
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),

                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isSending 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(onPressed: _sendComment, icon: const Icon(Icons.send, color: Color(0xFF667EEA))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}