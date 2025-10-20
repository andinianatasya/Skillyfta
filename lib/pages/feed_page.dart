import 'package:flutter/material.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final List<Map<String, dynamic>> feedData = [
    {
      'name': 'Andi Putra',
      'initial': 'A',
      'color': const Color(0xFFFFA726),
      'time': '2 menit yang lalu',
      'badge': 'Progress',
      'badgeIcon': 'assets/images/progress.png',
      'content': 'Hari ini berhasil push up 20x nonstop! Progress dari minggu lalu cuma 10x. Semangat terus!!',
      'likes': 1,
      'comments': 1,
    },
    {
      'name': 'Sari Dewi',
      'initial': 'S',
      'color': const Color(0xFFE91E63),
      'time': '15 menit yang lalu',
      'badge': 'Learning',
      'badgeIcon': 'assets/images/learning.png',
      'content': 'Belajar chord G mayor di gitar akhirnya lancar wk, besok target chord C mayor.\ndoain ya guys.',
      'likes': 2,
      'comments': 0,
    },
    {
      'name': 'Rudi',
      'initial': 'R',
      'color': const Color(0xFF2196F3),
      'time': '1 jam yang lalu',
      'badge': 'Achievement',
      'badgeIcon': 'assets/images/achievement.png',
      'content': 'Flutter widget hari ini:\nCustomPainter, Bikin animasi loading yang keren',
      'likes': 25,
      'comments': 8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              // Navbar Tab Navigation
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
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F5F5),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: feedData.length,
                    itemBuilder: (context, index) {
                      return _buildFeedCard(feedData[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.4),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.add, size: 32, color: Colors.white),
          onPressed: () {},
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
    final isSelected = index == 2; // Tab Feed yang aktif (index 2)
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 0 || index == 1) {
            // Kembali ke halaman Beranda
            Navigator.pop(context);
          }
          // Jika index == 2 (Feed), tetap di halaman ini
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

  Widget _buildFeedCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data['color'].withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: data['color'],
                child: Text(
                  data['initial'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          data['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          data['badgeIcon'],
                          height: 16,
                          width: 16,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.star_border, size: 16, color: Colors.grey),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data['badge'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data['content'],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${data['likes']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${data['comments']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}