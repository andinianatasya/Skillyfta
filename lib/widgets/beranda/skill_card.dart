import 'package:flutter/material.dart';
import 'package:skillyfta/widgets/beranda/edit_skill_dialog.dart';
import 'package:skillyfta/widgets/beranda/timer_popup.dart';

class SkillCard extends StatelessWidget {
  final String skillId;
  final String icon;
  final String title;
  final String target;
  final double progress;
  final String progressText;
  final String status;
  final int targetWaktu;
  final String targetUnit;
  final int progressAwal;

  const SkillCard({
    super.key,
    required this.skillId,
    required this.icon,
    required this.title,
    required this.target,
    required this.progress,
    required this.progressText,
    required this.status,
    required this.targetWaktu,
    required this.targetUnit,
    required this.progressAwal,
  });

  String _getStatusIconPath(String status) {
    switch (status) {
      case 'Done': return 'assets/images/done.png';
      case 'In Progress': return 'assets/images/inprogress.png';
      case 'Not Started': default: return 'assets/images/notstarted.png';
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Done': return const Color(0xFF4CAF50);
      case 'In Progress': return const Color(0xFFFFA726);
      case 'Not Started': default: return const Color(0xFF9E9E9E);
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'Done': return const Color(0xFFE8F5E9);
      case 'In Progress': return const Color(0xFFFFF3E0);
      case 'Not Started': default: return const Color(0xFFF5F5F5);
    }
  }

  Color _getIconContainerColor(String status) {
    switch (status) {
      case 'Done': return const Color(0xFFC8E6C9);
      case 'In Progress': return const Color(0xFFFFE0B2);
      case 'Not Started': default: return const Color(0xFFEEEEEE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusTextColor = _getStatusTextColor(status);
    final statusBgColor = _getStatusBackgroundColor(status);
    final iconContainerColor = _getIconContainerColor(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                icon,
                height: 44,
                width: 44,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.school,
                  size: 44,
                  color: Color(0xFF764BA2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          target,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => EditSkillDialog(
                                skillId: skillId,
                                skillNama: title,
                                currentTarget: targetWaktu,
                                currentUnit: targetUnit,
                                currentProgress: progressAwal,
                              ),
                            );
                          },
                          child: Padding( // Padding agar area sentuh lebih besar
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.edit, size: 14, color: Colors.grey[400]), // Ukuran icon sedikit dibesarkan agar enak dilihat
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF764BA2).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/alarm.png',
                    height: 18,
                    width: 18,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.alarm,
                      color: Color(0xFF764BA2),
                      size: 18,
                    ),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return TimerPopup(
                        skillId: skillId,
                        skillNama: title,
                        targetWaktu: targetWaktu,
                        targetUnit: targetUnit,
                        progressAwal: progressAwal,
                      );
                    },
                  );
                },
                tooltip: "Mulai Timer / Input Progress",
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressText,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: iconContainerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.asset(
                        _getStatusIconPath(status),
                        height: 10,
                        width: 10,
                        color: statusTextColor,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          status == 'Done' ? Icons.check : Icons.close,
                          size: 10,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}