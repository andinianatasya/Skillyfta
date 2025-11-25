import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillyfta/widgets/gradient_background.dart';

class BuatPostScreen extends StatefulWidget {
  const BuatPostScreen({super.key});

  @override
  State<BuatPostScreen> createState() => _BuatPostScreenState();
}

class _BuatPostScreenState extends State<BuatPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  String? _selectedKategori;
  final int _maxCharacters = 500;
  bool _isLoading = false;

  bool get _isFormValid {
    return _contentController.text.trim().isNotEmpty && _selectedKategori != null;
  }

  final List<Map<String, dynamic>> _kategoriList = [
    {
      'nama': 'Progress',
      'icon': 'assets/images/progress.png',
      'color': Color(0xFF42A5F5)
    },
    {
      'nama': 'Learning',
      'icon': 'assets/images/learning.png',
      'color': Color(0xFFFFA726)
    },
    {
      'nama': 'Challenge',
      'icon': 'assets/images/challenge.png',
      'color': Color(0xFFE91E63)
    },
    {
      'nama': 'Tips',
      'icon': 'assets/images/tips.png',
      'color': Color(0xFFFFCA28)
    },
    {
      'nama': 'Achievement',
      'icon': 'assets/images/achievement.png',
      'color': Color(0xFF66BB6A)
    },
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _postFeed() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konten post tidak boleh kosong'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kategori post'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['fullName'] ?? 'User';
      final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

      await FirebaseFirestore.instance.collection('posts').add({
        'content': _contentController.text.trim(),
        'category': _selectedKategori,
        'userId': user.uid,
        'userName': userName,
        'userInitial': userInitial,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil memposting!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memposting: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final characterCount = _contentController.text.length;
    final remainingCharacters = _maxCharacters - characterCount;

    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    final double horizontalPadding = screenWidth > 600 ? 40.0 : 20.0;
   
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Buat Post Baru',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    
                      const Text(
                        'Kategori Post',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                    
                      Container(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 10,
                            alignment: WrapAlignment.start,
                            children: _kategoriList.map((kategori) {
                              final isSelected = _selectedKategori == kategori['nama'];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedKategori = kategori['nama'];
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? kategori['color']
                                          : Colors.grey[700]!,
                                      width: isSelected ? 2 : 0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: kategori['color'].withOpacity(0.3),
                                              spreadRadius: 0,
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        kategori['icon'],
                                        width: 18,
                                        height: 18,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.category,
                                            size: 18,
                                            color: kategori['color'],
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        kategori['nama'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected ? kategori['color'] : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    
                      const SizedBox(height: 32),
                    
                      Container(
                        height: (screenHeight * 0.45).clamp(200, 500),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            TextField(
                              controller: _contentController,
                              maxLength: _maxCharacters,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                hintText: 'Ceritakan progress skill kamu hari ini...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.all(16),
                                counterText: '',
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                    
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: remainingCharacters < 50
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$remainingCharacters/$_maxCharacters',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: remainingCharacters < 50 ? Colors.red : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                      const SizedBox(height: 32),
                    
                      SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: (_isFormValid && !_isLoading) ? _postFeed : null,
                            
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFormValid ? Colors.transparent : Colors.grey[300], 
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.zero,
                              disabledBackgroundColor: Colors.grey[300],
                              disabledForegroundColor: Colors.white,
                            ),
                            child: Ink(
                              decoration: _isFormValid 
                                ? BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF667EEA).withOpacity(0.4),
                                        spreadRadius: 0,
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  )
                                : null,
                            child: Container(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Posting Sekarang',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}