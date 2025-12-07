import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skillyfta/auth/login_page.dart';
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
      await user.reload();
      if (mounted) {
        setState(() {
          _currentUser = FirebaseAuth.instance.currentUser;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final userId = user.uid;

        try {
          final skillsSnapshot = await firestore
              .collection('users')
              .doc(userId)
              .collection('skills')
              .get();
          for (var doc in skillsSnapshot.docs) {
            await doc.reference.delete();
          }
        } catch (e) {
          print("Warning: Gagal hapus skill (diabaikan): $e");
        }

        // hpus postingan sendiri
        try {
          final myPostsSnapshot = await firestore
              .collection('posts')
              .where('userId', isEqualTo: userId)
              .get();

          for (var postDoc in myPostsSnapshot.docs) {
            final postComments = await postDoc.reference.collection('comments').get();
            for (var c in postComments.docs) {
               final replies = await c.reference.collection('replies').get();
               for (var r in replies.docs) await r.reference.delete();
               
               await c.reference.delete();
            }
            await postDoc.reference.delete();
          }
        } catch (e) {
          print("Warning: Gagal hapus postingan (diabaikan): $e");
        }

        try {
          final myCommentsElsewhere = await firestore
              .collectionGroup('comments')
              .where('userId', isEqualTo: userId)
              .get();

          for (var commentDoc in myCommentsElsewhere.docs) {
            try {
               final replies = await commentDoc.reference.collection('replies').get();
               for (var r in replies.docs) await r.reference.delete();
            } catch (_) {}

            await commentDoc.reference.delete();
          }
        } catch (e) {
          print("⚠️ Gagal bersihkan komentar global (Mungkin Index belum siap), tapi lanjut hapus akun: $e");
        }

        try {
           await firestore.collection('users').doc(userId).delete();
        } catch (e) {
           print("Gagal hapus doc user: $e");
        }
        
        await user.delete();

        if (mounted) {
          Navigator.of(context).pop();
          
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
            (route) => false,
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Akun dihapus permanen. Sampai jumpa! 👋')),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context).pop();
      
      if (e.code == 'requires-recent-login') {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Demi keamanan, silakan Login ulang, lalu coba hapus akun lagi.')),
         );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal Auth: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      print("Critical Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan, tapi data mungkin sudah terhapus sebagian.')),
      );
    }
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Hapus Akun Permanen?', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: const Text(
          'Tindakan ini tidak dapat dibatalkan. Semua data progres skill dan profil Anda akan hilang selamanya.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Hapus Akun', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        content: const Text('Apakah Anda yakin ingin keluar?', style: TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
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
                      const Spacer(),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _showLogoutConfirmDialog,
                          icon: const Icon(Icons.logout, color: Color(0xFF667EEA)),
                          label: const Text(
                            'Keluar Akun',
                            style: TextStyle(
                              color: Color(0xFF667EEA),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF667EEA), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          onPressed: _showDeleteConfirmDialog,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Hapus Akun Permanen',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
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
}