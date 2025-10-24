import 'package:flutter/material.dart';
import 'editprofil_page.dart';
import 'ubahpassword_page.dart';

class SettingsPage extends StatefulWidget {
  final String? userName;
  final String? userInitial;

  const SettingsPage({
    super.key,
    this.userName,
    this.userInitial,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isProfilePublic = true;
  bool _shareProgress = true;
  bool _dailyReminder = true;
  bool _progressUpdate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          icon: Icons.person,
                          title: 'Informasi Akun',
                          color: const Color(0xFF667EEA),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingTile(
                          title: 'Edit Profil',
                          subtitle: 'Ubah nama, email, dan foto profil',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  userName: widget.userName ?? 'Fadiyah Maisyarah',
                                  userEmail: 'yayi23@gmail.com',
                                ),
                              ),
                            );
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
                                builder: (context) => const ChangePasswordPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        _buildSectionHeader(
                          icon: Icons.security,
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
                          icon: Icons.notifications,
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
    required IconData icon,
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
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
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
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF667EEA),
          ),
        ],
      ),
    );
  }
}