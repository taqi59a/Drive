import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakData {
  final int streakCount;
  final String? lastStudyDate;
  final bool studiedToday;

  StreakData({
    required this.streakCount,
    this.lastStudyDate,
    required this.studiedToday,
  });
}

class StreakNotifier extends StateNotifier<AsyncValue<StreakData>> {
  StreakNotifier() : super(const AsyncValue.loading()) {
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt('study_streak') ?? 0;
      final lastDateStr = prefs.getString('last_study_date');
      
      final todayStr = _getTodayStr();
      final studiedToday = lastDateStr == todayStr;
      
      state = AsyncValue.data(StreakData(
        streakCount: count,
        lastStudyDate: lastDateStr,
        studiedToday: studiedToday,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String _getTodayStr() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _getYesterdayStr() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
  }

  Future<void> recordStudySession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt('study_streak') ?? 0;
      final lastDateStr = prefs.getString('last_study_date');
      
      final todayStr = _getTodayStr();
      final yesterdayStr = _getYesterdayStr();
      
      int newCount = currentCount;
      if (lastDateStr == todayStr) {
        // Already studied today
        return;
      } else if (lastDateStr == yesterdayStr) {
        // Studied yesterday, increment streak
        newCount = currentCount + 1;
      } else {
        // Missed a day or first time studying
        newCount = 1;
      }
      
      await prefs.setInt('study_streak', newCount);
      await prefs.setString('last_study_date', todayStr);
      
      state = AsyncValue.data(StreakData(
        streakCount: newCount,
        lastStudyDate: todayStr,
        studiedToday: true,
      ));
    } catch (e) {
      // ignore
    }
  }
}

final streakProvider = StateNotifierProvider<StreakNotifier, AsyncValue<StreakData>>((ref) {
  return StreakNotifier();
});
