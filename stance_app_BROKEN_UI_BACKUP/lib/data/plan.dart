// ============================================================
// Personalization engine — rule-based weekly plan generator
// Ported from js/data/plan.js
// ============================================================

import '../models/models.dart';
import 'dart:math';
import 'content.dart';

class PlanEngine {
  /// Score how well a workout fits the user's goals, level, time,
  /// martial arts, and available equipment.
  static int scoreWorkout(Workout w, UserProfile profile, Set<String> userEquipment, {Random? random}) {
    int score = 0;

    // Martial art match
    if (profile.martialArts.contains(w.martialArt)) {
      score += 40;
    }

    // Duration match (target is sessionDuration)
    final diff = (w.duration - profile.sessionDuration).abs();
    if (diff <= 5) {
      score += 30;
    } else if (diff <= 10) {
      score += 20;
    } else if (diff <= 15) {
      score += 10;
    }

    // Goal match
    final artTechniques = ContentLibrary.techniquesForArt(w.martialArt);
    if (profile.goals.contains('footwork') && w.title.toLowerCase().contains('footwork')) {
      score += 25;
    }
    if (profile.goals.contains('conditioning') &&
        (w.title.toLowerCase().contains('condition') ||
            w.martialArt == 'strength')) {
      score += 25;
    }
    if (profile.goals.contains('fundamentals') && w.difficulty == 'intermediate') {
      score += 15;
    }
    if (profile.goals.contains('technique') && artTechniques.isNotEmpty) {
      score += 15;
    }
    if (profile.goals.contains('strength') && w.martialArt == 'strength') {
      score += 25;
    }
    if (profile.goals.contains('speed')) {
      if (w.title.toLowerCase().contains('combo') ||
          w.title.toLowerCase().contains('footwork')) {
        score += 10;
      }
    }
    if (profile.goals.contains('competition')) {
      if (w.martialArt != 'footwork' && w.martialArt != 'strength') {
        score += 10;
      }
    }

    // Equipment match
    bool hasAll = true;
    for (final eq in w.equipment) {
      if (!userEquipment.contains(eq) && eq != 'none') {
        hasAll = false;
        break;
      }
    }
    if (hasAll) {
      score += 10;
    } else {
      score -= 100; // Strong penalty for missing required equipment
    }

    // Difficulty match
    if (profile.level == 'beginner' && w.difficulty == 'intermediate') {
      score += 5;
    } else if (profile.level == 'advanced') {
      score += 5;
    }

    // Variety bonus
    if (random != null) {
      score += random.nextInt(10);
    } else {
      score += _hash(w.id) % 10;
    }

    return score;
  }

  /// Pick the best workouts to fill the weekly schedule.
  static List<Workout> selectWorkouts(UserProfile profile, Set<String> userEquipment, {Random? random}) {
    final all = ContentLibrary.workouts;
    final scored = all.map((w) => MapEntry(w, scoreWorkout(w, profile, userEquipment, random: random)))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Try to balance across martial arts
    final picked = <Workout>[];
    final usedArts = <String>{};
    for (final entry in scored) {
      if (picked.length >= profile.daysPerWeek) break;
      final art = entry.key.martialArt;
      if (usedArts.length < profile.martialArts.length && usedArts.contains(art)) {
        continue; // skip if we've already filled one slot per art
      }
      picked.add(entry.key);
      usedArts.add(art);
    }
    // Fill remainder if needed
    for (final entry in scored) {
      if (picked.length >= profile.daysPerWeek) break;
      if (!picked.contains(entry.key)) {
        picked.add(entry.key);
      }
    }
    return picked.take(profile.daysPerWeek).toList();
  }

  /// Build the weekly schedule for the user's available days.
  static List<ScheduledDay> buildSchedule(UserProfile profile, Set<String> userEquipment, {Random? random}) {
    final picked = selectWorkouts(profile, userEquipment, random: random);
    final orderedDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

    // Determine "today" for highlighting
    final now = DateTime.now();
    final todayIdx = now.weekday - 1; // 0=Mon..6=Sun

    final availableDays = profile.availableDays.toSet();
    final schedule = <ScheduledDay>[];
    int workoutIdx = 0;
    for (int i = 0; i < orderedDays.length; i++) {
      final day = orderedDays[i];
      if (availableDays.contains(day)) {
        if (workoutIdx < picked.length) {
          final w = picked[workoutIdx++];
          schedule.add(ScheduledDay(
            day: day,
            dayName: _dayName(day),
            type: 'training',
            workoutId: w.id,
            workout: w,
            duration: w.duration,
            isToday: i == todayIdx,
          ));
        } else {
          schedule.add(ScheduledDay(
            day: day,
            dayName: _dayName(day),
            type: 'rest',
            isToday: i == todayIdx,
          ));
        }
      } else {
        schedule.add(ScheduledDay(
          day: day,
          dayName: _dayName(day),
          type: 'rest',
          isToday: i == todayIdx,
        ));
      }
    }
    return schedule;
  }

  /// Reschedule missed sessions: shuffle training days so the upcoming days get a workout.
  static List<ScheduledDay> reschedule(
    List<ScheduledDay> schedule,
    UserProfile profile,
    Set<String> userEquipment, {
    Random? random,
  }) {
    final workouts = <Workout>[];
    for (final s in schedule) {
      if (s.type == 'training' && s.workout != null) workouts.add(s.workout!);
    }
    if (workouts.isEmpty) return schedule;

    final newSchedule = buildSchedule(profile, userEquipment, random: random);
    // Replace completed days
    final merged = <ScheduledDay>[];
    for (int i = 0; i < schedule.length; i++) {
      if (schedule[i].completed) {
        merged.add(schedule[i]);
      } else {
        merged.add(newSchedule[i]);
      }
    }
    return merged;
  }

  static String _dayName(String day) {
    const map = {
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
    };
    return map[day] ?? day;
  }

  static int _hash(String s) {
    int h = 0;
    for (int i = 0; i < s.length; i++) {
      h = (h * 31 + s.codeUnitAt(i)) & 0x7fffffff;
    }
    return h;
  }
}
