import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TambahSkillScreen extends StatefulWidget {
  const TambahSkillScreen({super.key});

  @override
  State<TambahSkillScreen> createState() => _TambahSkillScreenState();
}

class _TambahSkillScreenState extends State<TambahSkillScreen> {
  final TextEditingController _namaSkillController = TextEditingController();
  final TextEditingController _targetWaktuController = TextEditingController(
    text: '15',
  );
  final FocusNode _namaSkillFocus = FocusNode();
  final FocusNode _targetWaktuFocus = FocusNode();

  String? _selectedWaktuUnit;
  String? _selectedKategori;
  bool _isNamaSkillFocused = false;
  bool _isTargetWaktuFocused = false;
  bool _isWaktuDropdownFocused = false;
  bool _isKategoriDropdownFocused = false;

  bool _isLoading = false;

  final List<String> _waktuUnitList = ['Menit', 'Jam'];

  final List<Map<String, dynamic>> _kategoriList = [
    {
      'nama': 'Musik',
      'icon': 'assets/images/alatmusik.png',
      'color': Color(0xFFE57373),
    },
    {
      'nama': 'Teknologi / Digital',
      'icon': 'assets/images/laptop.png',
      'color': Color(0xFF64B5F6),
    },
    {
      'nama': 'Akademik',
      'icon': 'assets/images/akademik.png',
      'color': Color(0xFF4DB6AC),
    },
    {
      'nama': 'Bahasa',
      'icon': 'assets/images/bahasa.png',
      'color': Color(0xFFFFB74D),
    },
    {
      'nama': 'Olahraga',
      'icon': 'assets/images/olahraga.png',
      'color': Color(0xFF81C784),
    },
    {
      'nama': 'Seni / Kreativitas',
      'icon': 'assets/images/lukis.png',
      'color': Color(0xFFBA68C8),
    },
    {
      'nama': 'Lainnya',
      'icon': 'assets/images/lainnya.png',
      'color': Color(0xFF90A4AE),
    },
  ];

  @override
  void initState() {
    super.initState();
    _namaSkillFocus.addListener(() {
      setState(() {
        _isNamaSkillFocused = _namaSkillFocus.hasFocus;
      });
    });
    _targetWaktuFocus.addListener(() {
      setState(() {
        _isTargetWaktuFocused = _targetWaktuFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _namaSkillController.dispose();
    _targetWaktuController.dispose();
    _namaSkillFocus.dispose();
    _targetWaktuFocus.dispose();
    super.dispose();
  }

  void _incrementWaktu() {
    int currentValue = int.tryParse(_targetWaktuController.text) ?? 15;
    setState(() {
      _targetWaktuController.text = (currentValue + 1).toString();
    });
  }

  void _decrementWaktu() {
    int currentValue = int.tryParse(_targetWaktuController.text) ?? 15;
    if (currentValue > 1) {
      setState(() {
        _targetWaktuController.text = (currentValue - 1).toString();
      });
    }
  }

  void _tambahSkill() async {
    if (_namaSkillController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama skill tidak boleh kosong'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori skill'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak ditemukan. Silakan login kembali.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final skillData = {
      'nama': _namaSkillController.text,
      'targetWaktu': int.tryParse(_targetWaktuController.text) ?? 15,
      'TargetUnit': _selectedWaktuUnit ?? 'Menit',
      'kategori': _selectedKategori,
      'userId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'Not Started',
      'progressHariIni': 0,
    };

    try{
      await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('skills')
        .add(skillData);

      if (mounted) {
        Navigator.pop(context, {'nama': skillData['nama']});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambah skill: $e', 
            style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
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
          'Tambah Skill Baru',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nama Skill',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _isNamaSkillFocused
                          ? [
                              BoxShadow(
                                color:
                                    const Color(0xFF764BA2).withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 12,
                                offset: const Offset(0, 0),
                              ),
                            ]
                          : [],
                    ),
                    child: TextField(
                      controller: _namaSkillController,
                      focusNode: _namaSkillFocus,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Belajar Gitar',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF764BA2),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Berikan nama yang mudah diingat untuk skill yang ingin dipelajari',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 36),

                  const Text(
                    'Target Waktu Per Hari',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isTargetWaktuFocused
                                  ? const Color(0xFF764BA2)
                                  : Colors.grey[300]!,
                              width: _isTargetWaktuFocused ? 2 : 1.5,
                            ),
                            boxShadow: _isTargetWaktuFocused
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF764BA2)
                                          .withOpacity(0.3),
                                      spreadRadius: 0,
                                      blurRadius: 12,
                                      offset: const Offset(0, 0),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 0,
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _decrementWaktu,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: Container(
                                    width: 44,
                                    height: 52,
                                    child: const Icon(
                                      Icons.remove,
                                      size: 20,
                                      color: Color(0xFF764BA2),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _targetWaktuController,
                                  focusNode: _targetWaktuFocus,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _incrementWaktu,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  child: Container(
                                    width: 44,
                                    height: 52,
                                    child: const Icon(
                                      Icons.add,
                                      size: 20,
                                      color: Color(0xFF764BA2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isWaktuDropdownFocused = true;
                            });
                          },
                          child: Container(
                            height: 52,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isWaktuDropdownFocused
                                    ? const Color(0xFF764BA2)
                                    : Colors.grey[300]!,
                                width: _isWaktuDropdownFocused ? 2 : 1.5,
                              ),
                              boxShadow: _isWaktuDropdownFocused
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF764BA2)
                                            .withOpacity(0.3),
                                        spreadRadius: 0,
                                        blurRadius: 12,
                                        offset: const Offset(0, 0),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 0,
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedWaktuUnit,
                                hint: Center(
                                  child: Text(
                                    _waktuUnitList[0],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                isExpanded: true,
                                dropdownColor: Colors.white,
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: _isWaktuDropdownFocused
                                      ? const Color(0xFF764BA2)
                                      : Colors.grey[600],
                                  size: 24,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                elevation: 8,
                                menuMaxHeight: 200,
                                alignment: AlignmentDirectional.bottomStart,
                                items: _waktuUnitList.map((String unit) {
                                  return DropdownMenuItem<String>(
                                    value: unit,
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10,
                                                horizontal: 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          unit,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedWaktuUnit = newValue;
                                      _isWaktuDropdownFocused = false;
                                    });
                                  }
                                },
                                onTap: () {
                                  setState(() {
                                    _isWaktuDropdownFocused = true;
                                  });
                                },
                                selectedItemBuilder: (BuildContext context) {
                                  return _waktuUnitList.map((String unit) {
                                    return Center(
                                      child: Text(
                                        _selectedWaktuUnit ?? _waktuUnitList[0],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rekomendasi: 15-60 menit per hari untuk hasil optimal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 36),

                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isKategoriDropdownFocused = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isKategoriDropdownFocused
                              ? const Color(0xFF764BA2)
                              : Colors.grey[300]!,
                          width: _isKategoriDropdownFocused ? 2 : 1.5,
                        ),
                        boxShadow: _isKategoriDropdownFocused
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF764BA2)
                                      .withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 12,
                                  offset: const Offset(0, 0),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedKategori,
                          hint: Center(
                            child: Text(
                              'Pilih Kategori Skill',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: _isKategoriDropdownFocused
                                ? const Color(0xFF764BA2)
                                : Colors.grey[600],
                            size: 24,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          elevation: 8,
                          menuMaxHeight: 400,
                          itemHeight: 68,
                          alignment: AlignmentDirectional.bottomStart,
                          items: _kategoriList.map((kategori) {
                            return DropdownMenuItem<String>(
                              value: kategori['nama'],
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: kategori['color']
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            kategori['icon'],
                                            width: 24,
                                            height: 24,
                                            errorBuilder: (context, error,
                                                stackTrace) {
                                              return Icon(
                                                Icons.category,
                                                size: 24,
                                                color: kategori['color'],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          kategori['nama'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedKategori = newValue;
                              _isKategoriDropdownFocused = false;
                            });
                          },
                          onTap: () {
                            setState(() {
                              _isKategoriDropdownFocused = true;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 90),

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
                      onPressed: _isLoading ? null : _tambahSkill,
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
                              color:
                                  const Color(0xFF667EEA).withOpacity(0.4),
                              spreadRadius: 0,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Tambah Skill',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
