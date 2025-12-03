import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
    final today = DateTime(now.year, now.month, now.day);

    Timestamp? lastResetTs = data['lastSkillResetDate'];
    DateTime? lastResetDate = lastResetTs?.toDate();

    if (lastResetDate == null || lastResetDate.isBefore(today)) {
      final skillsSnapshot = await userRef.collection('skills').get();
      final batch = _firestore.batch();

      int totalSecondsYesterday = 0;

      for (var doc in skillsSnapshot.docs) {
        int progress = (doc.data()['progressHariIni'] ?? 0) as int;
        totalSecondsYesterday += progress;

        batch.update(doc.reference, {'progressHariIni': 0});
      }

      int minutesToAdd = (totalSecondsYesterday / 60).floor();

      if (minutesToAdd > 0) {
        batch.update(userRef, {
          'totalMinutes': FieldValue.increment(minutesToAdd),
          'lastSkillResetDate': Timestamp.fromDate(today)
        });
        print("Menyimpan $minutesToAdd menit ke Total Lifetime & Reset Harian.");
      } else {
        batch.update(userRef, {'lastSkillResetDate': Timestamp.fromDate(today)});
      }

      await batch.commit();
      print("Skill harian telah direset.");
    }

    await _calculateStreak(userRef, data, today);
  }

  Future<void> _calculateStreak(DocumentReference userRef, Map<String, dynamic> data, DateTime today) async {
    int streakFreeze = data['streakFreezeCount'] ?? 1;
    Timestamp? lastStreakTs = data['lastStreakDate'];

    Timestamp? lastFreezeResetTs = data['lastFreezeResetDate'];
    if (lastFreezeResetTs != null) {
      final diffFreeze = today.difference(lastFreezeResetTs.toDate()).inDays;
      if (diffFreeze >= 7 && streakFreeze < 1) {
        streakFreeze = 1;
        await userRef.update({'streakFreezeCount': 1, 'lastFreezeResetDate': Timestamp.fromDate(today)});
      }
    } else {
      await userRef.update({'lastFreezeResetDate': Timestamp.fromDate(today)});
    }

    if (lastStreakTs == null) return;

    DateTime lastDate = lastStreakTs.toDate();
    DateTime lastDateMidnight = DateTime(lastDate.year, lastDate.month, lastDate.day);

    final difference = today.difference(lastDateMidnight).inDays;

    if (difference == 0 || difference == 1) {
      return;
    } else {
      int daysMissed = difference - 1;

      if (daysMissed <= streakFreeze) {
        int newFreeze = streakFreeze - daysMissed;
        if(newFreeze < 0) newFreeze = 0;

        await userRef.update({
          'streakFreezeCount': newFreeze,
        });
        print("Streak Freeze terpakai! Sisa: $newFreeze");
      } else {
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
        'lastStreakDate': Timestamp.fromDate(today)
      });
      print("Streak bertambah! +1");
    }

    await updateDailyGraph(user.uid);
  }

  Future<void> updateDailyGraph(String uid) async {
    try {
      String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

      QuerySnapshot skillsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('skills')
          .get();

      bool isAnyTargetReached = false;

      for (var doc in skillsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        int progress = (data['progressHariIni'] ?? 0).toInt();
        int targetWaktu = (data['targetWaktu'] ?? 0).toInt();
        String unit = data['targetUnit'] ?? 'Menit';

        int targetDetik = (unit == 'Jam') ? targetWaktu * 3600 : targetWaktu * 60;

        if (progress >= targetDetik && targetDetik > 0) {
          isAnyTargetReached = true;
          break;
        }
      }

      if (isAnyTargetReached) {
        await _firestore.collection('users').doc(uid).set({
          'dailyHistory': {
            todayKey: 100
          }
        }, SetOptions(merge: true));

        print("Grafik diperbarui: $todayKey = 100");
      }
    } catch (e) {
      print("Error update daily graph: $e");
    }
  }
}