import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillyfta/pages/statistik_page.dart';
import 'package:skillyfta/widgets/beranda/progress_weekly_card.dart';
import 'package:skillyfta/widgets/beranda/skill_card.dart';
import 'package:skillyfta/widgets/gradient_background.dart';
import 'feed_page.dart';
import 'tambahskill_page.dart';
import 'pengaturanprofil_page.dart';
import '../services/streak_service.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final StreakService _streakService = StreakService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();

    _initializeData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _streakService.checkAndResetDailyProgress();
  }

  Stream<QuerySnapshot> _getSkillsStream() {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('skills')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  String _getIconPathForCategory(String? category) {
    switch (category) {
      case 'Musik':
        return 'assets/images/alatmusik.png';
      case 'Teknologi / Digital':
        return 'assets/images/laptop.png';
      case 'Akademik':
        return 'assets/images/akademik.png';
      case 'Bahasa':
        return 'assets/images/bahasa.png';
      case 'Olahraga':
        return 'assets/images/olahraga.png';
      case 'Seni / Kreativitas':
        return 'assets/images/lukis.png';
      case 'Lainnya':
      default:
        return 'assets/images/lainnya.png';
    }
  }

  double _calculateProgress(dynamic progressHariIniDetik, dynamic targetWaktuMenit) {
    if (progressHariIniDetik == null || targetWaktuMenit == null || targetWaktuMenit == 0) {
      return 0.0;
    }
    double currentSeconds = (progressHariIniDetik as num).toDouble();
    double targetSeconds = (targetWaktuMenit as num).toDouble() * 60;
    if (targetSeconds == 0) return 0.0;
    return (currentSeconds / targetSeconds).clamp(0.0, 1.0);
  }

  void _changeTab(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const StatistikPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
    else if (index == 2) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => FeedPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } 
    else {
      setState(() {
        _selectedTab = index;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, userSnapshot) {
              Map<String, dynamic>? userData;
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                userData = userSnapshot.data!.data() as Map<String, dynamic>?;
              }

              int currentStreak = userData?['currentStreak'] ?? 0;

              return Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _getSkillsStream(),
                    builder: (context, snapshot) {
                      int skillCount = 0;
                      int totalDetik = 0;
                  
                      if (snapshot.hasData) {
                        skillCount = snapshot.data!.docs.length;
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          int progress = (data['progressHariIni'] as num? ?? 0).toInt();
                          totalDetik += progress;
                        }
                      }
                      int totalMenit = (totalDetik / 60).floor();
                  
                      return _buildHeader(skillCount, totalMenit, userData);
                    },
                  ),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
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
                        Container(height: 1, color: Colors.grey[300]),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(_animation),
                      child: FadeTransition(
                        opacity: _animation,
                        child: _buildContent(currentStreak),
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
        floatingActionButton: _selectedTab == 0
            ? Container(
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
            onPressed: () async {
              final result = await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                  const TambahSkillScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;
      
                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
      
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
      
              if (result != null && result is Map<String, dynamic>) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${result['nama']} berhasil ditambahkan!',
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildHeader(int skillCount, int totalMenit, Map<String, dynamic>? userData) {
    String displayName = userData?['fullName'] ?? 'User...';
    String userInitial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'U';
    
    int currentStreak = userData?['currentStreak'] ?? 0;
    //int freezeCount = _userData?['streakFreezeCount'] ?? 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF764BA2).withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    _showProfilePictureDialog(context, displayName, userInitial);
                  },
                  borderRadius: BorderRadius.circular(35),
                  child: Center(
                    child: Text(
                      userInitial,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Halo, $displayName! ',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text('👋', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Semangat belajar hari ini',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Image.asset(
                  'assets/images/settings.png',
                  height: 24,
                  width: 24,
                  color: Colors.white,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.settings, color: Colors.white, size: 24),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          SettingsPage(
                            userName: displayName,
                            userInitial: userInitial,
                          ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOutCubic;
                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  skillCount.toString(),
                  'Skill Aktif',
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem(
                  totalMenit.toString(),
                  'Menit Hari Ini',
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withOpacity(0.3),
                ),

                _buildStatItem(currentStreak.toString(), 'Hari Streak')
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildContent(int currentStreak) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ProgressWeeklyCard(currentStreak: currentStreak),

            const SizedBox(height: 16),

            StreamBuilder<QuerySnapshot>(
              stream: _getSkillsStream(),
              builder: (context, snapshot) {
                // 1. Tampilkan loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF764BA2),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Center(
                      child: Text(
                        'Belum ada skill ditambahkan.\nKlik tombol + untuk memulai!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }
                final skills = snapshot.data!.docs;

                return ListView.separated(
                  itemCount: skills.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final skillDoc = skills[index];
                    final data = skillDoc.data() as Map<String, dynamic>;
                    final skillId = skillDoc.id;

                    final String title = data['nama'] ?? 'Tanpa Nama';
                    final String kategori = data['kategori'] ?? 'Lainnya';
                    final int targetWaktu = (data['targetWaktu'] as num? ?? 0).toInt();
                    final String targetUnit = data['targetUnit'] ?? 'Menit';
                    final int progressHariIniDetik = (data['progressHariIni'] as num? ?? 0).toInt();

                    int targetTotalMenit = (targetUnit == 'Jam')
                        ? targetWaktu * 60
                        : targetWaktu;

                    String status;
                    if (progressHariIniDetik <= 0) {
                      status = 'Not Started';
                    } else if (progressHariIniDetik >= (targetTotalMenit * 60)) {
                      status = 'Done';
                    } else {
                      status = 'In Progress';
                    }

                    final String iconPath = _getIconPathForCategory(kategori);

                    final double progress = _calculateProgress(
                      progressHariIniDetik,
                      targetTotalMenit,
                    );

                    String progressText;
                    int progressMenit = (progressHariIniDetik / 60).floor();

                    if (targetUnit == 'Jam') {
                      progressText = '${(progressHariIniDetik / 3600).toStringAsFixed(1)} / $targetWaktu Jam hari ini';
                    } else {
                      progressText = '$progressMenit / $targetWaktu Menit hari ini';
                    }

                    return SkillCard(
                      skillId: skillId,
                      icon: iconPath,
                      title: title,
                      target: 'Target: $targetWaktu $targetUnit/hari',
                      progress: progress,
                      progressText: progressText,
                      status: status,
                      targetWaktu: targetWaktu,
                      targetUnit: targetUnit,
                      progressAwal: progressHariIniDetik,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F2FE).withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    spreadRadius: -1,
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Progress Mingguan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/piala.png',
                              height: 36,
                              width: 36,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '🏆',
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Streak $currentStreak Hari',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
      ],
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => _changeTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF667EEA)
                    : Colors.transparent,
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


  void _showProfilePictureDialog(BuildContext context, String displayName, String userInitial) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: Hero(
                  tag: 'profile_picture',
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF764BA2).withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        userInitial,
                        style: const TextStyle(
                          fontSize: 120,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}