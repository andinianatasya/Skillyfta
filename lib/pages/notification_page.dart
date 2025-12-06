import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillyfta/widgets/gradient_background.dart';
import 'package:skillyfta/widgets/feed/comment_sheet.dart'; // Import untuk buka komentar

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final diff = now.difference(timestamp.toDate());
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    return '${diff.inDays}h';
  }

  void _openPost(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentSheet(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final unreadSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .where('isRead', isEqualTo: false)
            .get();

        if (unreadSnapshot.docs.isNotEmpty) {
          final batch = FirebaseFirestore.instance.batch();
          for (var doc in unreadSnapshot.docs) {
            batch.update(doc.reference, {'isRead': true});
          }
          await batch.commit();
        }
      });
    }

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("Notifikasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: user == null 
              ? const Center(child: Text("Silakan login.")) 
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('notifications')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Belum ada notifikasi baru.", style: TextStyle(color: Colors.grey)));
                    }

                    final notifs = snapshot.data!.docs;

                    return ListView.separated(
                      itemCount: notifs.length,
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final data = notifs[index].data() as Map<String, dynamic>;
                        final String postId = data['postId'] ?? '';
                        
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () => _openPost(context, postId),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                            child: Text(data['fromUserInitial'] ?? 'U', style: const TextStyle(color: Color(0xFF667EEA), fontWeight: FontWeight.bold)),
                          ),
                          title: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${data['fromUserName']} ",
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
                                ),
                                const TextSpan(
                                  text: "membalas komentar Anda: ",
                                  style: TextStyle(color: Colors.black87, fontSize: 14),
                                ),
                                TextSpan(
                                  text: "\"${data['content']}\"",
                                  style: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                          trailing: Text(
                            _formatTime(data['timestamp']),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}