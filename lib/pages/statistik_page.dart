import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/gradient_background.dart';
import 'feed_page.dart';

class StatistikPage extends StatefulWidget {
  const StatistikPage({super.key});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  static bool _showGraph = true;
  static bool _showStreak = true;

  final Color _textDark = const Color(0xFF333333);
  final Color _textFaded = const Color(0x99333333);
  final Color _purpleGradient = const Color(0xFF764BA2);
  final Color _blueGradient = const Color(0xFF667EEA);

  User? _currentUser;

  int _totalSkills = 0;
  int _menitHariIni = 0;
  int _totalMenitLifetime = 0;
  int _streak = 0;

  List<double> _weeklyData = [0, 0, 0, 0, 0, 0, 0];
  final List<String> _daysLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchUserData();
  }

  Stream<QuerySnapshot> _getSkillsStream() {
    if (_currentUser == null) return Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('skills')
        .snapshots();
  }

  Future<void> _fetchUserData() async {
    if (_currentUser == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        int dbStreak = (data['currentStreak'] ?? 0).toInt();
        int dbTotalMinutes = (data['totalMinutes'] ?? 0).toInt();

        List<double> tempWeeklyData = [0, 0, 0, 0, 0, 0, 0];
        Map<String, dynamic> dailyHistory = data['dailyHistory'] ?? {};

        DateTime now = DateTime.now();
        DateTime monday = now.subtract(Duration(days: now.weekday - 1));

        for (int i = 0; i < 7; i++) {
          DateTime checkDate = monday.add(Duration(days: i));
          String dateKey = DateFormat('yyyy-MM-dd').format(checkDate);

          if (dailyHistory.containsKey(dateKey)) {
            tempWeeklyData[i] = (dailyHistory[dateKey] as num).toDouble();
          }
        }

        if (mounted) {
          setState(() {
            _streak = dbStreak;
            _totalMenitLifetime = dbTotalMinutes;
            _weeklyData = tempWeeklyData;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching user stats: $e");
    }
  }

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
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getSkillsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        _totalSkills = snapshot.data!.docs.length;
                        int totalDetikHariIni = 0;

                        for (var doc in snapshot.data!.docs) {
                          var data = doc.data() as Map<String, dynamic>;
                          totalDetikHariIni += (data['progressHariIni'] as num? ?? 0).toInt();
                        }
                        _menitHariIni = (totalDetikHariIni / 60).floor();
                      }

                      return Stack(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
                            child: Column(
                              children: [
                                _buildDynamicStatGrid(),
                                const SizedBox(height: 20),
                                if (_showGraph || _showStreak)
                                  _buildCombinedChartAndStreakCard(),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 10,
                            child: IconButton(
                              icon: Icon(Icons.settings_outlined, color: _textFaded, size: 20),
                              onPressed: _showSettingsModal,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDynamicStatGrid() {
    double aspectRatio;
    if (_showGraph || _showStreak) {
      aspectRatio = 1.4;
    } else {
      aspectRatio = 0.8;
    }

    int displayTotalMinutes = _totalMenitLifetime + _menitHariIni;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: aspectRatio,
      children: [
        _buildInfoCard("TOTAL SKILLS", _totalSkills.toString(), Colors.blueAccent),
        _buildInfoCard("MENIT HARI INI", _menitHariIni.toString(), Colors.orangeAccent),
        _buildInfoCard("HARI STREAK", _streak.toString(), Colors.purpleAccent),
        _buildInfoCard("TOTAL MENIT", displayTotalMinutes.toString(), Colors.greenAccent),
      ],
    );
  }

  Widget _buildCombinedChartAndStreakCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 320),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: (!_showGraph && _showStreak)
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          if (_showGraph) ...[
            Text(
              "Progress Mingguan",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textDark),
            ),
            const SizedBox(height: 24),
            _buildBarChart(),
            if (!_showStreak) const SizedBox(height: 40),
          ],
          if (_showGraph && _showStreak) const SizedBox(height: 40),
          if (_showStreak)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/piala.png',
                  width: 36,
                  height: 36,
                ),
                const SizedBox(width: 12),
                Text(
                  "Streak $_streak Hari",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    double maxValue = 100;
    int todayIndex = DateTime.now().weekday - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        double value = _weeklyData[index];
        if (value > 100) value = 100;
        double barHeight = (value / maxValue) * 120;
        if (barHeight < 10 && value > 0) barHeight = 10;
        if (value == 0) barHeight = 4;
        bool isToday = index == todayIndex;

        return Column(
          children: [
            if (value > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  "${value.toInt()}",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isToday ? const Color(0xFF764BA2) : Colors.grey[600]),
                ),
              ),
            Container(
              width: 18,
              height: barHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isToday
                      ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
                      : [Colors.cyanAccent.shade200, Colors.blueAccent.shade100],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: value >= 100 ? [
                  BoxShadow(color: (isToday ? const Color(0xFF667EEA) : Colors.cyanAccent).withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2))
                ] : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _daysLabels[index],
              style: TextStyle(fontSize: 12, color: isToday ? _purpleGradient : Colors.grey[400], fontWeight: isToday ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        );
      }),
    );
  }

  void _showSettingsModal() {
    bool tempShowGraph = _showGraph;
    bool tempShowStreak = _showStreak;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                      Text("Pengaturan Statistik", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
                      IconButton(icon: Icon(Icons.close, color: _textFaded), onPressed: () => Navigator.pop(context))
                    ],
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("Tampilkan Grafik", style: TextStyle(fontWeight: FontWeight.w600, color: _textDark)),
                    subtitle: Text("Progress mingguan", style: TextStyle(color: _textFaded)),
                    value: tempShowGraph,
                    activeColor: _blueGradient,
                    onChanged: (bool value) => setModalState(() => tempShowGraph = value),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("Tampilkan Streak", style: TextStyle(fontWeight: FontWeight.w600, color: _textDark)),
                    subtitle: Text("Badge pencapaian hari", style: TextStyle(color: _textFaded)),
                    value: tempShowStreak,
                    activeColor: _blueGradient,
                    onChanged: (bool value) => setModalState(() => tempShowStreak = value),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [_purpleGradient, _blueGradient], begin: Alignment.centerLeft, end: Alignment.centerRight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showGraph = tempShowGraph;
                          _showStreak = tempShowStreak;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("Simpan Pengaturan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 40, height: 40, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.star, color: Colors.white, size: 40)),
              const SizedBox(width: 12),
              const Text('Skillyfta', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Pantau perkembangan skill mu setiap hari', style: TextStyle(fontSize: 14, color: Colors.white)),
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
            Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => const FeedPage(), transitionsBuilder: (context, animation, secondaryAnimation, child) { return FadeTransition(opacity: animation, child: child); }, transitionDuration: const Duration(milliseconds: 300)));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isSelected ? const Color(0xFF667EEA) : Colors.transparent, width: 3))),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF667EEA) : Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color accentColor) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: const Color(0xFF667EEA))),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textFaded, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}