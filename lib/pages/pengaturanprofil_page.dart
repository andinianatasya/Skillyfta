import 'package:flutter/material.dart';
import 'package:skillyfta/widgets/gradient_background.dart';
import 'editprofil_page.dart';
import 'ubahpassword_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  final String? userName;
  final String? userInitial;

  const SettingsPage({super.key, this.userName, this.userInitial});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {
  bool _isProfilePublic = true;
  bool _shareProgress = true;
  bool _dailyReminder = true;
  bool _progressUpdate = false;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCurrentUser();
    }
  }

  Future<void> _loadCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // Paksa refresh data (PENTING)
      if (mounted) {
        setState(() {
          _currentUser = FirebaseAuth.instance.currentUser;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _currentUser?.displayName ?? widget.userName ?? 'User';
    final email = _currentUser?.email ?? 'Belum ada email';

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Profil & Pengaturan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          iconPath: 'assets/images/account.png',
                          title: 'Informasi Akun',
                          color: const Color(0xFF667EEA),
                        ),
                        const SizedBox(height: 12),


                        _buildSettingTile(
                          title: 'Edit Profil',
                          subtitle: email,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  userName: _currentUser?.displayName,
                                  userEmail: _currentUser?.email,
                                ),
                              ),
                            );

                            if (result == true) {
                              await _loadCurrentUser();
                            }
                          },
                        ),

                        const SizedBox(height: 12),
                        _buildSettingTile(
                          title: 'Ubah Password',
                          subtitle: 'Perbarui keamanan akun Anda',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const ChangePasswordPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        _buildSectionHeader(
                          iconPath: 'assets/images/lock.png',
                          title: 'Privasi & Keamanan',
                          color: const Color(0xFF667EEA),
                        ),
                        const SizedBox(height: 12),
                        _buildSwitchTile(
                          title: 'Profil Publik',
                          subtitle: 'Tampilkan profil di leaderboard',
                          value: _isProfilePublic,
                          onChanged: (value) {
                            setState(() {
                              _isProfilePublic = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildSwitchTile(
                          title: 'Bagikan Progress',
                          subtitle: 'Izinkan teman melihat kemajuan',
                          value: _shareProgress,
                          onChanged: (value) {
                            setState(() {
                              _shareProgress = value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        _buildSectionHeader(
                          iconPath: 'assets/images/notification.png',
                          title: 'Notifikasi',
                          color: const Color(0xFF667EEA),
                        ),
                        const SizedBox(height: 12),
                        _buildSwitchTile(
                          title: 'Pengingat Latihan',
                          subtitle: 'Notifikasi harian untuk berlatih',
                          value: _dailyReminder,
                          onChanged: (value) {
                            setState(() {
                              _dailyReminder = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildSwitchTile(
                          title: 'Update Progress',
                          subtitle: 'Pemberitahuan pencapaian mingguan',
                          value: _progressUpdate,
                          onChanged: (value) {
                            setState(() {
                              _progressUpdate = value;
                            });
                          },
                        ),
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

  Widget _buildSectionHeader({
    required String iconPath,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              iconPath,
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.settings,
                  size: 20,
                  color: Colors.white,
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Text ini sekarang akan menampilkan EMAIL, bukan teks statis
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF667EEA),
            activeTrackColor: const Color(0xFF667EEA).withOpacity(0.5),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}