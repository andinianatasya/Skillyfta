import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skillyfta/widgets/gradient_background.dart';

class EditSkillDialog extends StatefulWidget {
  final String skillId;
  final String skillNama;
  final int currentTarget;
  final String currentUnit;
  final int currentProgress;

  const EditSkillDialog({
    super.key,
    required this.skillId,
    required this.skillNama,
    required this.currentTarget,
    required this.currentUnit,
    required this.currentProgress,
  });

  @override
  State<EditSkillDialog> createState() => _EditSkillDialogState();
}

class _EditSkillDialogState extends State<EditSkillDialog> {
  late TextEditingController _targetController;
  late String _selectedUnit;

  bool _isConfirmingDelete = false;

  @override
  void initState() {
    super.initState();
    _targetController = TextEditingController(text: widget.currentTarget.toString());
    _selectedUnit = widget.currentUnit;
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Target tidak bisa diubah karena sudah ada progress hari ini. Coba lagi besok!"),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _validateAndClampInput() {
    int current = int.tryParse(_targetController.text) ?? 1;
    int maxLimit = (_selectedUnit == 'Menit') ? 60 : 15;

    if (current < 1) current = 1;
    if (current > maxLimit) current = maxLimit;

    if (_targetController.text != current.toString()) {
      _targetController.text = current.toString();
      _targetController.selection = TextSelection.fromPosition(
        TextPosition(offset: _targetController.text.length)
      );
    }
  }

  void _incrementTarget() {
    if (widget.currentProgress > 0) { _showLockedMessage(); return; }
    int current = int.tryParse(_targetController.text) ?? 0;
    int maxLimit = (_selectedUnit == 'Menit') ? 60 : 15;
    
    if (current < maxLimit) {
      setState(() => _targetController.text = (current + 1).toString());
    }
  }

  void _decrementTarget() {
    if (widget.currentProgress > 0) { _showLockedMessage(); return; }
    int current = int.tryParse(_targetController.text) ?? 0;
    if (current > 1) {
      setState(() => _targetController.text = (current - 1).toString());
    }
  }

  Future<void> _processDelete() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('skills')
          .doc(widget.skillId)
          .delete();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Skill berhasil dihapus"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateTarget() async {
    _validateAndClampInput();
    
    int inputTarget = int.parse(_targetController.text);
    
    int finalTarget = inputTarget;
    String finalUnit = _selectedUnit;

    if (_selectedUnit == 'Jam') {
      finalTarget = inputTarget * 60;
      finalUnit = 'Menit';
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('skills')
          .doc(widget.skillId)
          .update({
            'targetWaktu': finalTarget,
            'targetUnit': finalUnit,
          });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Target berhasil diupdate!"), 
            backgroundColor: Colors.green
          ),
        );
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal update: $e"), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isConfirmingDelete) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text("HAPUS SKILL?", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
        content: Text(
          "Skill '${widget.skillNama}' akan dihapus permanen.",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black87),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GradientBackground(
              child: ElevatedButton(
                onPressed: () => setState(() => _isConfirmingDelete = false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), 
                ),
                child: const Text(
                  "Batal",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          OutlinedButton(
            onPressed: _processDelete,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              foregroundColor: Colors.red,
              backgroundColor: const Color(0xFFFFEBEE),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Hapus", 
              style: TextStyle(fontWeight: FontWeight.bold)
            )
          ),
        ],
      );
    }

    bool isLocked = widget.currentProgress > 0;
    Color inputColor = isLocked ? Colors.grey[200]! : Colors.white;
    Color textColor = isLocked ? Colors.grey : Colors.black87;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          const Text(
            "Edit Target Harian",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLocked)
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Target terkunci karena sudah ada progress hari ini. Edit lagi besok ya!",
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),
          const Text("Target Waktu", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 10),
          
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: inputColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF9575CD)), 
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _targetController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          enabled: !isLocked,
                          onChanged: (val) {
                            _validateAndClampInput();
                          },
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: isLocked ? null : _incrementTarget,
                            child: const Icon(Icons.arrow_drop_up, size: 18, color: Colors.grey),
                          ),
                          InkWell(
                            onTap: isLocked ? null : _decrementTarget,
                            child: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),

              Expanded(
                flex: 5,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: inputColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isLocked ? Colors.grey[300]! : const Color(0xFF9575CD)), 
                  ),
                  child: IgnorePointer(
                    ignoring: isLocked,
                    child: PopupMenuButton<String>(
                      offset: const Offset(0, 50),
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      initialValue: _selectedUnit,
                      
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedUnit,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textColor),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: textColor),
                        ],
                      ),
                      itemBuilder: (context) {
                        String optionToShow = (_selectedUnit == 'Menit') ? 'Jam' : 'Menit';
                        
                        return [
                          PopupMenuItem<String>(
                            value: optionToShow,
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                optionToShow,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
                              ),
                            ),
                          ),
                        ];
                      },
                      onSelected: (newValue) {
                        setState(() {
                          _selectedUnit = newValue;
                          _validateAndClampInput();
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),

      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isConfirmingDelete = true;
                });
              },
              icon: const Icon(Icons.delete, color: Colors.red, size: 30),
              tooltip: "Hapus Skill",
            ),
            
            InkWell(
              onTap: isLocked ? null : _updateTarget,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey[400] : null,
                  gradient: isLocked 
                      ? null 
                      : const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isLocked ? [] : [BoxShadow(color: const Color(0xFF764BA2).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }
}