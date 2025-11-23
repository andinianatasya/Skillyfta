import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'feed_page.dart';

class StatistikPage extends StatefulWidget {
  const StatistikPage({super.key});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  bool _showGraph = true;
  bool _showStreak = true;

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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
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
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF5F5F5),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.settings_outlined, color: Colors.grey),
                            onPressed: _showSettingsModal,
                          ),
                        ),

                        _buildStatGrid(),

                        const SizedBox(height: 20),

                        if (_showGraph) _buildWeeklyProgress(),
                        if (_showGraph && _showStreak) const SizedBox(height: 20),
                        if (_showStreak) _buildStreakCard(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                const Icon(Icons.auto_graph, color: Colors.white, size: 40),
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
    final isSelected = index == 1;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 2) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>const FeedPage(),
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

  Widget _buildStatGrid() {
    return Column(
      children: [
        Row(
          children: [
            _buildInfoCard("TOTAL SKILLS", "5", Colors.blueAccent),
            const SizedBox(width: 16),
            _buildInfoCard("MENIT HARI INI", "75", Colors.blueAccent),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildInfoCard("HARI STREAK", "7", Colors.blueAccent),
            const SizedBox(width: 16),
            _buildInfoCard("TOTAL MENIT", "450", Colors.blueAccent),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF667EEA),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    final List<double> heights = [40, 60, 65, 50, 80, 100, 30];
    final List<String> days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Progress Mingguan",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              return Column(
                children: [
                  Container(
                    width: 20,
                    height: heights[index],
                    decoration: BoxDecoration(
                      color: index == 6 ? Colors.lightBlue[300] : Colors.cyan[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
          const SizedBox(width: 16),
          const Text(
            "Streak 7 Hari",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsModal() {
    bool tempShowGraph = _showGraph;
    bool tempShowStreak = _showStreak;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Pengaturan Statistik",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Tampilkan Grafik", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("Progress mingguan", style: TextStyle(color: Colors.grey)),
                    value: tempShowGraph,
                    activeColor: const Color(0xFF667EEA),
                    onChanged: (bool value) {
                      setModalState(() {
                        tempShowGraph = value;
                      });
                    },
                  ),
                  const Divider(),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Tampilkan Streak", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("Badge pencapaian hari", style: TextStyle(color: Colors.grey)),
                    value: tempShowStreak,
                    activeColor: const Color(0xFF667EEA),
                    onChanged: (bool value) {
                      setModalState(() {
                        tempShowStreak = value;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showGraph = tempShowGraph;
                          _showStreak = tempShowStreak;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Simpan Pengaturan",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}