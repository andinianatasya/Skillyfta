import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> checkAndResetDailyProgress() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) return;

    final data = userDoc.data()!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // jam 00:00:00 hari ini

    // Cek kapan terakhir kali skill direset
    Timestamp? lastResetTs = data['lastSkillResetDate'];
    DateTime? lastResetDate = lastResetTs?.toDate();
    
    // Jika belum pernah reset atau tanggal terakhir reset < hari ini (kemarin dst)
    if (lastResetDate == null || lastResetDate.isBefore(today)) {
      // Reset semua skill progressHariIni ke 0
      final skillsSnapshot = await userRef.collection('skills').get();
      final batch = _firestore.batch();

      for (var doc in skillsSnapshot.docs) {
        batch.update(doc.reference, {'progressHariIni': 0});
      }
      
      // Update tanggal reset terakhir ke hari ini
      batch.update(userRef, {'lastSkillResetDate': Timestamp.fromDate(today)});
      await batch.commit();
      print("Skill harian telah direset.");
    }

    // cek streak (Lazy Calculation)
    await _calculateStreak(userRef, data, today);
  }

  Future<void> _calculateStreak(DocumentReference userRef, Map<String, dynamic> data, DateTime today) async {
    int streakFreeze = data['streakFreezeCount'] ?? 1;
    Timestamp? lastStreakTs = data['lastStreakDate'];
    
    // jika lastFreezeResetDate > 7 hari lalu, refill freeze jadi 1.
    Timestamp? lastFreezeResetTs = data['lastFreezeResetDate'];
    if (lastFreezeResetTs != null) {
       final diffFreeze = today.difference(lastFreezeResetTs.toDate()).inDays;
       if (diffFreeze >= 7 && streakFreeze < 1) {
         streakFreeze = 1; // refill
         await userRef.update({'streakFreezeCount': 1, 'lastFreezeResetDate': Timestamp.fromDate(today)});
       }
    } else {
       await userRef.update({'lastFreezeResetDate': Timestamp.fromDate(today)});
    }


    if (lastStreakTs == null) {
      return;
    }

    DateTime lastDate = lastStreakTs.toDate();
    // Normalisasi ke jam 00:00:00 untuk perbandingan hari yang akurat
    DateTime lastDateMidnight = DateTime(lastDate.year, lastDate.month, lastDate.day);

    final difference = today.difference(lastDateMidnight).inDays;

    if (difference == 0) {
      return;
    } else if (difference == 1) {
      // Kemarin dikerjakan, streak lanjut belum putus
      return; 
    } else {
      // difference >= 2 (user melewatkan 1 hari atau lebih)
      // Contoh: Terakhir tgl 1, Skrg tgl 3. Selisih 2 hari. Absen tgl 2.
      
      // Hitung berapa hari bolong
      int daysMissed = difference - 1;

      if (daysMissed <= streakFreeze) {
        // Streak Freeze menyelamatkan
        // Kurangi freeze, tp ga reset streak
        
        int newFreeze = streakFreeze - daysMissed;
        if(newFreeze < 0) newFreeze = 0;

        await userRef.update({
          'streakFreezeCount': newFreeze,
        });
        print("Streak Freeze terpakai! Sisa: $newFreeze");

      } else {
        // Freeze tidak cukup atau habis mk reset streak
        await userRef.update({'currentStreak': 0});
        print("Streak terputus! Reset ke 0.");
      }
    }
  }

  Future<void> updateStreakOnSkillComplete() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final userRef = _firestore.collection('users').doc(user.uid);
    
    final userDoc = await userRef.get();
    if (!userDoc.exists) return;
    final data = userDoc.data()!;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    Timestamp? lastStreakTs = data['lastStreakDate'];
    
    bool alreadyIncrementedToday = false;
    if (lastStreakTs != null) {
      DateTime lastDate = lastStreakTs.toDate();
      DateTime lastDateMidnight = DateTime(lastDate.year, lastDate.month, lastDate.day);
      if (lastDateMidnight.isAtSameMomentAs(today)) {
        alreadyIncrementedToday = true;
      }
    }

    if (!alreadyIncrementedToday) {
      await userRef.update({
        'currentStreak': FieldValue.increment(1),
        'lastStreakDate': Timestamp.fromDate(today) // Tandai hari ini selesai
      });
      print("Streak bertambah! +1");
    }
  }
}