import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimerPopup extends StatefulWidget {
  final String skillId;
  final String skillNama;
  final int targetWaktu;
  final String targetUnit;
  final int progressAwal;

  const TimerPopup({
    Key? key,
    required this.skillId,
    required this.skillNama,
    required this.targetWaktu,
    required this.targetUnit,
    required this.progressAwal,
  }) : super(key: key);

  @override
  _TimerPopupState createState() => _TimerPopupState();
}

class _TimerPopupState extends State<TimerPopup> {
  Timer? _timer;
  Duration _duration = Duration.zero;
  bool _isRunning = false;

  final TextEditingController _hourController = TextEditingController(text: '00');
  final TextEditingController _minuteController = TextEditingController(text: '00');
  final TextEditingController _secondController = TextEditingController(text: '00');
  
  final FocusNode _hourFocus = FocusNode();
  final FocusNode _minuteFocus = FocusNode();
  final FocusNode _secondFocus = FocusNode();

  bool _isManualInput = false;
  late int _targetTotalDetik;

  @override
  void initState() {
    super.initState();
    _duration = Duration(seconds: widget.progressAwal);

    _targetTotalDetik = (widget.targetUnit == 'Jam')
        ? widget.targetWaktu * 3600
        : widget.targetWaktu * 60;

    _updateManualFieldsFromDuration(_duration);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    _hourFocus.dispose();
    _minuteFocus.dispose();
    _secondFocus.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning || _isManualInput || _duration.inSeconds >= _targetTotalDetik) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_duration.inSeconds >= _targetTotalDetik
              ? 'Target harian sudah tercapai!'
              : 'Timer tidak bisa dimulai saat input manual.'),
          backgroundColor: Colors.orangeAccent,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() { _isRunning = true; });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      
      if (_duration.inSeconds >= _targetTotalDetik) {
         _pauseTimer(); 
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Target harian tercapai!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
         setState(() {
           _duration = Duration(seconds: _targetTotalDetik);
         });
      } else {
        setState(() {
          _duration = _duration + const Duration(seconds: 1);
        });
      }
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    if (mounted) setState(() { _isRunning = false; });
  }

  void _resetTimer() {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _duration = Duration(seconds: widget.progressAwal);
        _isRunning = false;
        _isManualInput = false;
        _updateManualFieldsFromDuration(_duration);
      });
    }
  }

  void _toggleManualInput() {
    if (mounted) {
      _pauseTimer();
      setState(() {
        _isManualInput = !_isManualInput;
        if (_isManualInput) {
          _updateManualFieldsFromDuration(_duration);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _secondFocus.requestFocus();
            _secondController.selectAll();
          });
        }
      });
    }
  }

   void _updateManualFieldsFromDuration(Duration d) {
     String twoDigits(int n) => n.toString().padLeft(2, '0');
     _hourController.text = twoDigits(d.inHours);
     _minuteController.text = twoDigits(d.inMinutes.remainder(60));
     _secondController.text = twoDigits(d.inSeconds.remainder(60));
   }


  void _finishTimer() {
    _pauseTimer();
    int detikTambahan = _duration.inSeconds - widget.progressAwal;
    _saveProgressIncrement(detikTambahan);
  }

  void _saveManualInput() {
    int hours = int.tryParse(_hourController.text) ?? 0;
    int minutes = int.tryParse(_minuteController.text) ?? 0;
    int seconds = int.tryParse(_secondController.text) ?? 0;

    hours = hours.clamp(0, 99);
    minutes = minutes.clamp(0, 59);
    seconds = seconds.clamp(0, 59);

    int totalDetikManual = (hours * 3600) + (minutes * 60) + seconds;

    if (totalDetikManual > _targetTotalDetik) {
      totalDetikManual = _targetTotalDetik;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Input melebihi target, disesuaikan ke target.'),
          backgroundColor: Colors.orangeAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }

    _updateTotalProgressDirectly(totalDetikManual);
  }

  Future<void> _saveProgressIncrement(int detikTambahan) async {
    if (detikTambahan <= 0) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !mounted) return;

    int potentialTotal = widget.progressAwal + detikTambahan;
    int cappedDetikTambahan = detikTambahan;

    if (potentialTotal > _targetTotalDetik) {
      cappedDetikTambahan = _targetTotalDetik - widget.progressAwal;
      if (cappedDetikTambahan < 0) cappedDetikTambahan = 0;
    }

    if (cappedDetikTambahan <= 0 && potentialTotal >= _targetTotalDetik) {
       if (mounted) Navigator.pop(context);
       return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users').doc(user.uid)
          .collection('skills').doc(widget.skillId)
          .update({'progressHariIni': FieldValue.increment(cappedDetikTambahan)});

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan progress: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateTotalProgressDirectly(int totalDetikHariIni) async {
     final user = FirebaseAuth.instance.currentUser;
     if (user == null || !mounted) return;
     totalDetikHariIni = totalDetikHariIni.clamp(0, _targetTotalDetik);
     try {
         await FirebaseFirestore.instance
             .collection('users').doc(user.uid)
             .collection('skills').doc(widget.skillId)
             .update({'progressHariIni': totalDetikHariIni});

         if (mounted) Navigator.pop(context);
     } catch (e) {
         if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Gagal update progress: ${e.toString()}'), backgroundColor: Colors.red),
             );
         }
     } finally {
          if (mounted) {
              setState(() { _isManualInput = false; });
          }
     }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours : $minutes : $seconds";
  }

 @override
 Widget build(BuildContext context) {
   String targetDisplay = "${widget.targetWaktu} ${widget.targetUnit}";
   bool targetMet = _duration.inSeconds >= _targetTotalDetik;

   const manualInputStyle = TextStyle(
     fontSize: 28, fontWeight: FontWeight.w500, color: Colors.black54,
   );
   final twoDigitFormatter = [
     FilteringTextInputFormatter.digitsOnly,
     LengthLimitingTextInputFormatter(2),
   ];

   return AlertDialog(
     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
     titlePadding: const EdgeInsets.only(top: 20, left: 20, right: 10),
     contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
     actionsPadding: const EdgeInsets.only(bottom: 15, right: 15, left: 15),
     title: Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
         Expanded(
           child: Text(
             'Timer ${widget.skillNama}',
             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
             overflow: TextOverflow.ellipsis,
           ),
         ),
         IconButton(
           icon: const Icon(Icons.close, color: Colors.grey),
           onPressed: () => Navigator.pop(context),
           padding: EdgeInsets.zero,
           constraints: const BoxConstraints(),
         ),
       ],
     ),
     content: Column(
       mainAxisSize: MainAxisSize.min,
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             Expanded(
               child: Text(
                 _formatDuration(_duration),
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   fontSize: 36,
                   fontWeight: FontWeight.bold,
                   fontFeatures: const [FontFeature.tabularFigures()],
                   letterSpacing: 2,
                   color: targetMet ? Colors.green : Colors.black87,
                 ),
               ),
             ),
             IconButton(
               icon: Icon(
                 Icons.edit,
                 color: _isManualInput ? Theme.of(context).primaryColor : Colors.grey[400],
                 size: 20,
               ),
               onPressed: _toggleManualInput,
               tooltip: _isManualInput ? "Sembunyikan Input Manual" : "Tampilkan Input Manual (JJ:MM:SS)",
               splashRadius: 20,
             ),
           ],
         ),
         const SizedBox(height: 10),

         Visibility(
           visible: _isManualInput,
           maintainState: true,
           child: Column(
             children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   // jam input
                   _buildTimeInput(
                     controller: _hourController,
                     focusNode: _hourFocus,
                     hint: 'JJ',
                     formatters: twoDigitFormatter,
                     onSubmitted: (_) => FocusScope.of(context).requestFocus(_minuteFocus),
                   ),
                   const Padding(
                     padding: EdgeInsets.symmetric(horizontal: 4.0),
                     child: Text(":", style: manualInputStyle),
                   ),
                   // Menit input
                   _buildTimeInput(
                     controller: _minuteController,
                     focusNode: _minuteFocus,
                     hint: 'MM',
                     formatters: twoDigitFormatter,
                     onChanged: (value) {
                         int minutes = int.tryParse(value) ?? 0;
                         if (minutes > 59) { _minuteController.text = '59'; _minuteController.selectAll(); }
                     },
                     onSubmitted: (_) => FocusScope.of(context).requestFocus(_secondFocus),
                   ),
                   const Padding(
                     padding: EdgeInsets.symmetric(horizontal: 4.0),
                     child: Text(":", style: manualInputStyle),
                   ),
                   _buildTimeInput(
                     controller: _secondController,
                     focusNode: _secondFocus,
                     hint: 'DD',
                     formatters: twoDigitFormatter,
                     readOnly: false,
                     onChanged: (value) {
                         int seconds = int.tryParse(value) ?? 0;
                         if (seconds > 59) { _secondController.text = '59'; _secondController.selectAll(); }
                     },
                     onSubmitted: (_) => FocusScope.of(context).unfocus(),
                   ),
                 ],
               ),
               const SizedBox(height: 15),
             ],
           ),
         ),

         Text(
           'Target: $targetDisplay',
           style: TextStyle(color: Colors.grey[600], fontSize: 13),
         ),
         const SizedBox(height: 10),
       ],
     ),
     actionsAlignment: MainAxisAlignment.spaceEvenly,
     actions: [
       _buildControlButton(
         icon: Icons.refresh,
         onPressed: _resetTimer,
         tooltip: "Reset ke Progress Awal Hari Ini",
       ),
       _buildControlButton(
         icon: _isRunning ? Icons.pause : Icons.play_arrow,
         onPressed: (_isManualInput || targetMet) ? null : (_isRunning ? _pauseTimer : _startTimer),
         isPrimary: true,
         tooltip: _isRunning ? "Jeda" : (targetMet ? "Target Tercapai" : "Mulai"),
       ),
       _buildControlButton(
         icon: Icons.check,
         onPressed: () {
           if (_isManualInput) { _saveManualInput(); } else { _finishTimer(); }
         },
         tooltip: "Selesai & Simpan",
       ),
     ],
   );
 }

 Widget _buildTimeInput({
     required TextEditingController controller,
     required FocusNode focusNode,
     required String hint,
     List<TextInputFormatter>? formatters,
     ValueChanged<String>? onChanged,
     ValueChanged<String>? onSubmitted,
     bool readOnly = false,
 }) {
   return SizedBox(
     width: 60,
     child: TextField(
       controller: controller,
       focusNode: focusNode,
       readOnly: readOnly,
       textAlign: TextAlign.center,
       keyboardType: TextInputType.number,
       inputFormatters: formatters,
       style: TextStyle(
         fontSize: 28,
         fontWeight: FontWeight.w500,
         color: readOnly ? Colors.grey[400] : Colors.black54,
       ),
       decoration: InputDecoration(
         hintText: hint,
         border: InputBorder.none,
         isDense: true,
         contentPadding: const EdgeInsets.symmetric(vertical: 5),
         hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
         focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: readOnly ? Colors.grey : Theme.of(context).primaryColor.withOpacity(0.7), width: 2),
         ),
         enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
         ),
         disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
         ),
       ),
       onChanged: readOnly ? null : onChanged,
       onSubmitted: readOnly ? null : onSubmitted,
     ),
   );
 }

 Widget _buildControlButton({
   required IconData icon,
   required VoidCallback? onPressed,
   bool isPrimary = false,
   String? tooltip,
 }) {
   return Tooltip(
     message: tooltip ?? '',
     child: ElevatedButton(
       onPressed: onPressed,
       style: ElevatedButton.styleFrom(
         backgroundColor: isPrimary ? const Color(0xFF764BA2) : Colors.grey[200],
         foregroundColor: isPrimary ? Colors.white : const Color(0xFF764BA2),
         shape: const CircleBorder(),
         padding: const EdgeInsets.all(15),
         elevation: isPrimary ? 4 : 1,
         disabledBackgroundColor: isPrimary ? const Color(0xFF764BA2).withOpacity(0.5) : Colors.grey[300],
       ),
       child: Icon(icon, size: 28),
     ),
   );
 }
}

extension SelectAllExtension on TextEditingController {
 void selectAll() {
   if (text.isEmpty) return;
   selection = TextSelection(baseOffset: 0, extentOffset: text.length);
 }
}