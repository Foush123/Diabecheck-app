import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class UserDataService {
  UserDataService._internal();
  static final UserDataService instance = UserDataService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Future<fb.User> _ensureSignedIn() async {
    final u = _auth.currentUser;
    if (u != null) return u;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) => _db.collection('users').doc(uid);

  Future<void> upsertProfile({required Map<String, dynamic> profile}) async {
    final u = await _ensureSignedIn();
    await _userDoc(u.uid).set({'profile': profile}, SetOptions(merge: true));
  }

  Future<void> saveReminder({required Map<String, dynamic> reminder}) async {
    final u = await _ensureSignedIn();
    await _userDoc(u.uid).collection('reminders').add({
      ...reminder,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addMealLog({required Map<String, dynamic> meal}) async {
    final u = await _ensureSignedIn();
    final data = {
      ...meal,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _userDoc(u.uid).collection('mealLogs').add(data);
    await _updateDailyReport(u.uid, deltaCalories: (meal['calories'] as num?)?.toInt() ?? 0, deltaCarbs: (meal['carbs'] as num?)?.toDouble() ?? 0.0);
  }

  Future<void> addExerciseLog({required Map<String, dynamic> exercise}) async {
    final u = await _ensureSignedIn();
    await _userDoc(u.uid).collection('exerciseLogs').add({
      ...exercise,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<Map<String, dynamic>> streamSummary() async* {
    final u = await _ensureSignedIn();
    final userRef = _userDoc(u.uid);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final mealsQuery = userRef
        .collection('mealLogs')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay));
    yield* mealsQuery.snapshots().map((snap) {
      int totalCalories = 0;
      double totalCarbs = 0;
      for (final d in snap.docs) {
        final data = d.data();
        totalCalories += (data['calories'] as num?)?.toInt() ?? 0;
        totalCarbs += (data['carbs'] as num?)?.toDouble() ?? 0.0;
      }
      return {
        'calories': totalCalories,
        'carbs': totalCarbs,
      };
    });
  }

  Stream<List<Map<String, dynamic>>> streamTodayMealLogs() async* {
    final u = await _ensureSignedIn();
    final userRef = _userDoc(u.uid);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    yield* userRef
        .collection('mealLogs')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Future<void> _updateDailyReport(String uid, {required int deltaCalories, required double deltaCarbs}) async {
    final today = DateTime.now();
    final key = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final ref = _userDoc(uid).collection('reports_daily').doc(key);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        final cals = (data['calories'] as num?)?.toInt() ?? 0;
        final carbs = (data['carbs'] as num?)?.toDouble() ?? 0.0;
        tx.update(ref, {
          'calories': cals + deltaCalories,
          'carbs': carbs + deltaCarbs,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        tx.set(ref, {
          'date': key,
          'calories': deltaCalories,
          'carbs': deltaCarbs,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Stream<List<Map<String, dynamic>>> streamReports({required String period}) async* {
    final u = await _ensureSignedIn();
    final col = _userDoc(u.uid).collection('reports_daily');
    DateTime from;
    final now = DateTime.now();
    if (period == 'weekly') {
      from = now.subtract(const Duration(days: 6));
    } else if (period == 'monthly') {
      from = DateTime(now.year, now.month, 1);
    } else {
      from = DateTime(now.year, now.month, now.day);
    }
    yield* col
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(from.year, from.month, from.day)))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }
}


