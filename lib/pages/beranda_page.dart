import 'package:flutter/material.dart';
import 'feed_page.dart'; // Import halaman Feed

class BerandaPage extends StatefulWidget {
  const BerandaPage({Key? key}) : super(key: key);

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changeTab(int index) {
    if (index == 2) {
      // Navigasi ke halaman Feed dengan animasi fade
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => FeedPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      setState(() {
        _selectedTab = index;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

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
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_animation),
                  child: FadeTransition(
                    opacity: _animation,
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          ),
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
          onPressed: () {},
        ),
      )
          : null,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'F',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                      children: const [
                        Text(
                          'Halo, Fadiyah! ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '👋',
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Semangat belajar hari ini',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
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
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('4', 'Skill Aktif'),
                Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem('75', 'Menit Hari Ini'),
                Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem('12', 'Hari Streak'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedTab == 0) {
      return Container(
        color: const Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tetap Konsisten!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Kamu sudah latihan 12 hari berturut-turut.\nJangan sampai streak mu putus!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSkillCard(
                icon: 'assets/images/alatmusik.png',
                title: 'Belajar Piano',
                target: 'Target: 30 menit/hari',
                progress: 0.5,
                progressText: '15 menit hari ini',
                status: 'In Progress',
                statusColor: const Color(0xFFFFA726),
              ),
              const SizedBox(height: 12),
              _buildSkillCard(
                icon: 'assets/images/laptop.png',
                title: 'Belajar Flutter',
                target: 'Target: 60 menit/hari',
                progress: 1.0,
                progressText: '60 menit hari ini',
                status: 'Done',
                statusColor: const Color(0xFF66BB6A),
              ),
              const SizedBox(height: 12),
              _buildSkillCard(
                icon: 'assets/images/lukis.png',
                title: 'Belajar Menggambar',
                target: 'Target: 20 menit/hari',
                progress: 0.0,
                progressText: '0 menit hari ini',
                status: 'Not Started',
                statusColor: const Color(0xFFBDBDBD),
              ),
              const SizedBox(height: 12),
              _buildSkillCard(
                icon: 'assets/images/olahraga.png',
                title: 'Latihan Futsal',
                target: 'Target: 60 menit/hari',
                progress: 0.0,
                progressText: '0 menit hari ini',
                status: 'Not Started',
                statusColor: const Color(0xFFBDBDBD),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF26E5A2), Color(0xFF4FC3F7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
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
                              color: Colors.black45,
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
                                const Text('🏆', style: TextStyle(fontSize: 36)),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Streak 7 Hari',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45,
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
    } else {
      return Container(
        color: const Color(0xFFF5F5F5),
        child: const Center(
          child: Text(
            'Halaman Statistik\n(Coming Soon)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
          ),
        ),
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

  String _getStatusIconPath(String status) {
    switch (status) {
      case 'Done':
        return 'assets/images/done.png';
      case 'In Progress':
        return 'assets/images/inprogress.png';
      case 'Not Started':
        return 'assets/images/notstarted.png';
      default:
        return 'assets/images/notstarted.png';
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Done':
        return const Color(0xFF4CAF50);
      case 'In Progress':
        return const Color(0xFFFFA726);
      case 'Not Started':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'Done':
        return const Color(0xFFE8F5E9);
      case 'In Progress':
        return const Color(0xFFFFF3E0);
      case 'Not Started':
        return const Color(0xFFF5F5F5);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color _getIconContainerColor(String status) {
    switch (status) {
      case 'Done':
        return const Color(0xFFC8E6C9);
      case 'In Progress':
        return const Color(0xFFFFE0B2);
      case 'Not Started':
        return const Color(0xFFEEEEEE);
      default:
        return const Color(0xFFEEEEEE);
    }
  }

  Widget _buildSkillCard({
    required String icon,
    required String title,
    required String target,
    required double progress,
    required String progressText,
    required String status,
    required Color statusColor,
  }) {
    final statusTextColor = _getStatusTextColor(status);
    final statusBgColor = _getStatusBackgroundColor(status);
    final iconContainerColor = _getIconContainerColor(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
              Image.asset(
                icon,
                height: 44,
                width: 44,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.school,
                  size: 44,
                  color: Color(0xFF764BA2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
                          target,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit,
                          size: 13,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF764BA2).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/alarm.png',
                  height: 18,
                  width: 18,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.alarm,
                    color: Color(0xFF764BA2),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: iconContainerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.asset(
                        _getStatusIconPath(status),
                        height: 10,
                        width: 10,
                        color: statusTextColor,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          status == 'Done' ? Icons.check : Icons.close,
                          size: 10,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusTextColor,
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