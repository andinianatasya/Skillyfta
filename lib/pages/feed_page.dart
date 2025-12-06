import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillyfta/pages/notification_page.dart';
import 'package:skillyfta/pages/statistik_page.dart';
import 'package:skillyfta/widgets/feed/feed_card.dart';
import 'package:skillyfta/widgets/gradient_background.dart';
import 'postbaru_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  bool _showMyPostsOnly = false;

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
    
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildTab('Beranda', 0),
                        _buildTab('Statistik', 1),
                        _buildTab('Feed', 2),
                      ],
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          _buildFilterChip("Semua", !_showMyPostsOnly, () {
                            setState(() => _showMyPostsOnly = false);
                          }),
                          const SizedBox(width: 12),
                          _buildFilterChip("Postingan Saya", _showMyPostsOnly, () {
                            setState(() => _showMyPostsOnly = true);
                          }),

                          const Spacer(),

                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser?.uid)
                                .collection('notifications')
                                .where('isRead', isEqualTo: false) // Hanya hitung yang belum dibaca
                                .snapshots(),
                            builder: (context, snapshot) {
                              int unreadCount = 0;
                              if (snapshot.hasData) {
                                unreadCount = snapshot.data!.docs.length;
                              }

                              return IconButton(
                                icon: Badge(
                                  isLabelVisible: unreadCount > 0, 
                                  
                                  backgroundColor: Colors.red, 
                                  
                                  label: Text(
                                    '$unreadCount', 
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                  
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.grey,
                                    size: 26,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const NotificationPage()),
                                  );
                                },
                                tooltip: "Notifikasi",
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1, color: Colors.grey[200]),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F5F5),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getFeedStream(), 
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            _showMyPostsOnly 
                                ? 'Kamu belum memposting apapun.' 
                                : 'Belum ada postingan.\nJadilah yang pertama!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      final posts = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final postDoc = posts[index];
                          final postData = postDoc.data() as Map<String, dynamic>;
                          return FeedCard(postId: postDoc.id, data: postData);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton()
      ),
    );
  }

  Stream<QuerySnapshot> _getFeedStream() {
    final user = FirebaseAuth.instance.currentUser;
    Query query = FirebaseFirestore.instance.collection('posts');

    if (_showMyPostsOnly && user != null) {
      query = query.where('userId', isEqualTo: user.uid);
    }

    return query.orderBy('timestamp', descending: true).snapshots();
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF667EEA).withOpacity(0.4), spreadRadius: 0, blurRadius: 12, offset: const Offset(0, 4))]),
      child: IconButton(icon: const Icon(Icons.add, size: 32, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuatPostScreen()))),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF667EEA),
                    Color(0xFF764BA2),
                  ],
                )
              : null, 
          color: isActive ? null : Colors.grey[100], 

          border: Border.all(
            color: isActive 
                ? Colors.transparent 
                : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive 
                ? Colors.white 
                : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.star, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 12),
              const Text(
                'Skillyfta',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Pantau perkembangan skill mu setiap hari',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildTab(String title, int index) {
    final isSelected = index == 2;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } 
          else if (index == 1) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>const StatistikPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF667EEA) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF667EEA) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}