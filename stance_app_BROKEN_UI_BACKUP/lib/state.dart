// ============================================================
// State store — persistent app state via shared_preferences.
// Mirrors js/state.js semantics but uses ChangeNotifier.
// ============================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/content.dart';
import 'models/models.dart';

class AppState extends ChangeNotifier {
  static const _key = 'stance.app.v1';
  static const double meaningfulCompletionThreshold = 0.3;

  UserProfile profile = const UserProfile();
  bool onboarded = false;
  ThemeMode themeMode = ThemeMode.dark;
  bool musicEnabled = true;
  bool voiceEnabled = true;
  int xp = 0;
  int level = 1;
  int currentStreak = 0;
  int longestStreak = 0;
  int workoutsCompleted = 0;
  int totalTrainingMinutes = 0;
  List<String> learnedTechniques = [];
  Set<String> completedToday = {};
  List<Combo> combos = [];
  List<ScheduledDay> schedule = [];
  List<String> unlockedAchievements = [];
  DateTime? lastTrainingDate;
  Map<String, double> skillProgress = {};
  List<String> favoriteQuotes = [];


  /// Listeners used for screens to react to state changes without
  /// needing to read every property.
  final _changes = StreamController<AppState>.broadcast();
  Stream<AppState> get changes => _changes.stream;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final j = json.decode(raw) as Map<String, dynamic>;
      profile = j['profile'] != null
          ? UserProfile.fromJson(j['profile'] as Map<String, dynamic>)
          : const UserProfile();
      onboarded = j['onboarded'] as bool? ?? false;
      themeMode = j['themeMode'] == 'light' ? ThemeMode.light : (j['themeMode'] == 'system' ? ThemeMode.system : ThemeMode.dark);
      musicEnabled = j['musicEnabled'] as bool? ?? true;
      voiceEnabled = j['voiceEnabled'] as bool? ?? true;
      xp = j['xp'] as int? ?? 0;
      level = j['level'] as int? ?? 1;
      currentStreak = j['currentStreak'] as int? ?? 0;
      longestStreak = j['longestStreak'] as int? ?? 0;
      workoutsCompleted = j['workoutsCompleted'] as int? ?? 0;
      totalTrainingMinutes = j['totalTrainingMinutes'] as int? ?? 0;
      learnedTechniques = (j['learnedTechniques'] as List?)?.cast<String>() ?? [];
      combos = (j['combos'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(Combo.fromJson)
              .toList() ??
          [];
      unlockedAchievements = (j['unlockedAchievements'] as List?)?.cast<String>() ?? [];
      completedToday = (j['completedToday'] as List?)?.cast<String>().toSet() ?? {};
      favoriteQuotes = (j['favoriteQuotes'] as List?)?.cast<String>() ?? [];
      lastTrainingDate = j['lastTrainingDate'] != null
          ? DateTime.parse(j['lastTrainingDate'] as String)
          : null;
      skillProgress = (j['skillProgress'] as Map?)?.map(
            (k, v) => MapEntry(k as String, (v as num).toDouble()),
          ) ??
          {};

      // Clear daily duplicates if the date has changed.
      final today = _dateOnly(DateTime.now());
      if (lastTrainingDate != null && _dateOnly(lastTrainingDate!) != today) {
        completedToday.clear();
        save();
      }

      if (j['schedule'] != null) {
        final rawDays = j['schedule'] as List;
        schedule = rawDays.map((dayJson) {
          final day = ScheduledDay.fromJson(dayJson as Map<String, dynamic>);
          if (day.workoutId != null) {
            return day.copyWith(workout: ContentLibrary.workoutById(day.workoutId!));
          }
          return day;
        }).toList();
      }
    } catch (e) {
      debugPrint('AppState load error: $e');
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final j = {
      'profile': profile.toJson(),
      'onboarded': onboarded,
      'themeMode': themeMode.name,
      'musicEnabled': musicEnabled,
      'voiceEnabled': voiceEnabled,
      'xp': xp,
      'level': level,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'workoutsCompleted': workoutsCompleted,
      'totalTrainingMinutes': totalTrainingMinutes,
      'learnedTechniques': learnedTechniques,
      'combos': combos.map((c) => c.toJson()).toList(),
      'unlockedAchievements': unlockedAchievements,
      'completedToday': completedToday.toList(),
      'lastTrainingDate': lastTrainingDate?.toIso8601String(),
      'skillProgress': skillProgress,
      'schedule': schedule.map((d) => d.toJson()).toList(),
    };
    await prefs.setString(_key, json.encode(j));
  }

  void _notify() {
    _checkAchievements();
    notifyListeners();
    _changes.add(this);
    save();
  }

  void _checkAchievements() {
    final all = ContentLibrary.achievements;
    for (final a in all) {
      if (unlockedAchievements.contains(a.id)) continue;

      bool earned = false;
      switch (a.id) {
        case 'session_1':
          earned = workoutsCompleted >= 1;
          break;
        case 'session_5':
          earned = workoutsCompleted >= 5;
          break;
        case 'session_10':
          earned = workoutsCompleted >= 10;
          break;
        case 'session_25':
          earned = workoutsCompleted >= 25;
          break;
        case 'session_50':
          earned = workoutsCompleted >= 50;
          break;
        case 'session_100':
          earned = workoutsCompleted >= 100;
          break;
        case 'streak_7':
          earned = currentStreak >= 7;
          break;
        case 'streak_14':
          earned = currentStreak >= 14;
          break;
        case 'streak_30':
          earned = currentStreak >= 30;
          break;
        case 'hours_5':
          earned = totalTrainingMinutes >= 300;
          break;
        case 'hours_20':
          earned = totalTrainingMinutes >= 1200;
          break;
        case 'hours_50':
          earned = totalTrainingMinutes >= 3000;
          break;
        case 'boxing_basics':
          final boxingCount = learnedTechniques.where((t) =>
            ContentLibrary.techniques['boxing']?.any((bt) => bt.id == t) ?? false).length;
          earned = boxingCount >= 3;
          break;
        case 'tkd_basics':
          final tkdCount = learnedTechniques.where((t) =>
            ContentLibrary.techniques['taekwondo']?.any((bt) => bt.id == t) ?? false).length;
          earned = tkdCount >= 3;
          break;
        case 'footwork_foundation':
          final footworkCount = skillProgress.entries
            .where((e) => ContentLibrary.workouts.any((w) => w.id == e.key && w.martialArt == 'footwork'))
            .length;
          earned = footworkCount >= 3;
          break;
        case 'combo_creator':
          earned = combos.isNotEmpty;
          break;
        case 'combo_master':
          earned = combos.length >= 10;
          break;
      }

      if (earned) {
        awardAchievement(a.id);
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    _notify();
  }

  void toggleMusic() {
    musicEnabled = !musicEnabled;
    _notify();
  }

  void toggleVoice() {
    voiceEnabled = !voiceEnabled;
    _notify();
  }

  Future<void> completeOnboarding(UserProfile newProfile, List<ScheduledDay> schedule) async {
    profile = newProfile;
    this.schedule = schedule;
    onboarded = true;
    // Award onboarding XP bonus
    xp += 25;
    _recomputeLevel();
    _notify();
  }

  Future<void> regenerateSchedule(List<ScheduledDay> schedule) async {
    this.schedule = schedule;
    _notify();
  }

  Future<void> recordSession({
    required String workoutId,
    required int actualTrainedSeconds,
    required int scheduledSeconds,
  }) async {
    print('[STANCE DEBUG] recordSession ENTER');
    print('workoutId: $workoutId');
    print('actualTrainedSeconds: $actualTrainedSeconds');
    print('scheduledSeconds: $scheduledSeconds');
    final completionRatio = scheduledSeconds == 0
        ? 0.0
        : actualTrainedSeconds / scheduledSeconds;
    print('completionRatio: $completionRatio');
    print('meaningfulCompletionThreshold: $meaningfulCompletionThreshold');
    print('completedToday.contains(workoutId): ${completedToday.contains(workoutId)}');

    // A session must be "meaningful" (>= threshold) to affect streaks,
    // stats, or award rewards.
    if (completionRatio < AppState.meaningfulCompletionThreshold) {
      print('[STANCE DEBUG] recordSession REJECTED');
      print('reason=below_threshold');
      return;
    }

    final today = _dateOnly(DateTime.now());
    final last = lastTrainingDate != null ? _dateOnly(lastTrainingDate!) : null;

    // 1. Update Streak and Last Training Date
    if (last == null) {
      currentStreak = 1;
    } else {
      final diff = today.difference(last).inDays;
      if (diff == 0) {
        // Already trained today; streak remains the same.
      } else if (diff == 1) {
        currentStreak += 1;
      } else {
        currentStreak = 1;
      }
    }
    lastTrainingDate = today;
    if (currentStreak > longestStreak) longestStreak = currentStreak;

    // 2. Daily Duplicate Protection
    // Prevent inflating stats and XP by repeating the same workout on the same day.
    if (!completedToday.contains(workoutId)) {
      workoutsCompleted += 1;
      totalTrainingMinutes += (actualTrainedSeconds ~/ 60);
      xp += 30; // completion XP
      if (actualTrainedSeconds >= 20 * 60) xp += 20; // long training bonus
      completedToday.add(workoutId);

      // Skill progress increases based on the actual completion ratio
      skillProgress[workoutId] = (skillProgress[workoutId] ?? 0) + completionRatio;

      _recomputeLevel();
      print('[STANCE DEBUG] STATS UPDATED');
      print('xp: $xp');
      print('workoutsCompleted: $workoutsCompleted');
      print('totalTrainingMinutes: $totalTrainingMinutes');
      print('currentStreak: $currentStreak');
      print('skillProgress value: ${skillProgress[workoutId]}');
    }

    print('[STANCE DEBUG] NOTIFY');
    _notify();
  }

  Future<void> markTechniqueLearned(String techniqueId) async {
    if (learnedTechniques.contains(techniqueId)) return;
    learnedTechniques.add(techniqueId);
    xp += 10;
    _recomputeLevel();
    _notify();
  }

  Future<void> addCombo(Combo combo) async {
    combos.add(combo);
    _notify();
  }

  Future<void> removeCombo(String id) async {
    combos.removeWhere((c) => c.id == id);
    _notify();
  }

  Future<void> awardAchievement(String id) async {
    if (unlockedAchievements.contains(id)) return;
    unlockedAchievements.add(id);
    xp += 50;
    _recomputeLevel();
    _notify();
  }

  Future<void> resetAll() async {
    profile = const UserProfile();
    onboarded = false;
    xp = 0;
    level = 1;
    currentStreak = 0;
    longestStreak = 0;
    workoutsCompleted = 0;
    totalTrainingMinutes = 0;
    learnedTechniques = [];
    combos = [];
    schedule = [];
    unlockedAchievements = [];
    lastTrainingDate = null;
    skillProgress = {};
    _notify();
  }

  void _recomputeLevel() {
    // 100 XP per level, simple curve.
    level = 1 + (xp ~/ 100);
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void dispose() {
    _changes.close();
    super.dispose();
  }
}
