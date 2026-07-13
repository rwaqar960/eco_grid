import 'package:shared_preferences/shared_preferences.dart';

/// Local-only best score/level persistence via shared_preferences.
class HighScoreStore {
  static const _scoreKey = 'best_score';
  static const _levelKey = 'best_level';

  Future<(int score, int level)> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(_scoreKey) ?? 0, prefs.getInt(_levelKey) ?? 0);
  }

  /// Records the run if it beats the stored best. Returns true when a new
  /// best score was set.
  Future<bool> submit({required int score, required int level}) async {
    final prefs = await SharedPreferences.getInstance();
    final bestScore = prefs.getInt(_scoreKey) ?? 0;
    final bestLevel = prefs.getInt(_levelKey) ?? 0;
    if (level > bestLevel) {
      await prefs.setInt(_levelKey, level);
    }
    if (score > bestScore) {
      await prefs.setInt(_scoreKey, score);
      return true;
    }
    return false;
  }
}
