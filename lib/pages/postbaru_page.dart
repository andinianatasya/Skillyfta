import 'package:flutter/material.dart';

class BuatPostScreen extends StatefulWidget {
  const BuatPostScreen({Key? key}) : super(key: key);

  @override
  State<BuatPostScreen> createState() => _BuatPostScreenState();
}

class _BuatPostScreenState extends State<BuatPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  String? _selectedKategori;
  final int _maxCharacters = 500;

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

  void _postFeed() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konten post tidak boleh kosong'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_selectedKategori == null || _selectedKategori!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori post'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final Map<String, String> postData = {
      'content': _contentController.text.trim(),
      'kategori': _selectedKategori ?? 'Progress',
    };

    print('Sending data: $postData'); // Debug
    Navigator.pop(context, postData);
  }

  @override
  Widget build(BuildContext context) {
    final characterCount = _contentController.text.length;
    final remainingCharacters = _maxCharacters - characterCount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'Kategori Post',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _kategoriList.map((kategori) {
                  final isSelected = _selectedKategori == kategori['nama'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedKategori = kategori['nama'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? kategori['color'].withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? kategori['color']
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1.5,
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
                            width: 20,
                            height: 20,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.category,
                                size: 20,
                                color: kategori['color'],
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          Text(
                            kategori['nama'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? kategori['color'] : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              Container(
                height: 280,
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
                        counterText: '', // Hide default counter
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

              const SizedBox(height: 100),

              Divider(
                color: Colors.grey[300],
                thickness: 1,
                height: 1,
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _postFeed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
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
                    ),
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
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide.none,
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}