// ============================================================
// Data models — plain Dart classes, JSON-serializable
// ============================================================

class MartialArt {
  final String id;
  final String name;
  final String icon;
  final int colorValue;

  const MartialArt({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
  });
}

class Technique {
  final String id;
  final String name;
  final String category;
  final int duration; // minutes
  final String description;
  final List<String> steps;
  final List<String> mistakes;
  final int xp;

  const Technique({
    required this.id,
    required this.name,
    required this.category,
    required this.duration,
    required this.description,
    required this.steps,
    required this.mistakes,
    required this.xp,
  });
}

class ExerciseStep {
  final String name;
  final int duration; // seconds
  final String? description;
  final String? technicalNotes;
  final bool isRest;

  const ExerciseStep({
    required this.name,
    required this.duration,
    this.description,
    this.technicalNotes,
    this.isRest = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'duration': duration,
        if (description != null) 'description': description,
        if (technicalNotes != null) 'technicalNotes': technicalNotes,
        'isRest': isRest,
      };

  factory ExerciseStep.fromJson(Map<String, dynamic> j) => ExerciseStep(
        name: j['name'] as String,
        duration: j['duration'] as int,
        description: j['description'] as String?,
        technicalNotes: j['technicalNotes'] as String?,
        isRest: j['isRest'] as bool? ?? false,
      );
}

class Workout {
  final String id;
  final String title;
  final String description;
  final String martialArt;
  final String category;
  final int duration; // minutes
  final String difficulty;
  final List<String> equipment;
  final List<ExerciseStep> exercises;
  final int xp;
  final String? safetyNotes;
  final String? assetPath;

  const Workout({
    required this.id,
    required this.title,
    required this.description,
    required this.martialArt,
    required this.category,
    required this.duration,
    required this.difficulty,
    required this.equipment,
    required this.exercises,
    required this.xp,
    this.safetyNotes,
    this.assetPath,
  });
}

class CustomizedWorkout {
  final Workout originalWorkout;
  final double durationMultiplier;
  final int workOffsetSeconds;
  final int restOffsetSeconds;
  final bool includeWarmup;
  final bool includeStretching;
  final List<String> activeEquipment;

  const CustomizedWorkout({
    required this.originalWorkout,
    this.durationMultiplier = 1.0,
    this.workOffsetSeconds = 0,
    this.restOffsetSeconds = 0,
    this.includeWarmup = true,
    this.includeStretching = true,
    required this.activeEquipment,
  });

  List<ExerciseStep> get modifiedExercises {
    return originalWorkout.exercises.map((step) {
      final offset = step.isRest ? restOffsetSeconds : workOffsetSeconds;
      int newDuration = (step.duration * durationMultiplier).toInt() + offset;
      return ExerciseStep(
        name: step.name,
        duration: newDuration > 0 ? newDuration : 1,
        description: step.description,
        isRest: step.isRest,
      );
    }).toList();
  }

  int get totalDurationSeconds =>
      modifiedExercises.fold<int>(0, (acc, e) => acc + e.duration);
}

class Combo {
  final String id;
  final String name;
  final List<String> strikes;
  final DateTime createdAt;
  final String folder; // 'General' by default
  final int presetCount;

  const Combo({
    required this.id,
    required this.name,
    required this.strikes,
    required this.createdAt,
    this.folder = 'General',
    this.presetCount = 4,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'strikes': strikes,
        'createdAt': createdAt.toIso8601String(),
        'folder': folder,
        'presetCount': presetCount,
      };

  factory Combo.fromJson(Map<String, dynamic> j) => Combo(
        id: j['id'] as String,
        name: j['name'] as String,
        strikes: (j['strikes'] as List).cast<String>(),
        createdAt: DateTime.parse(j['createdAt'] as String),
        folder: j['folder'] as String? ?? 'General',
        presetCount: j['presetCount'] as int? ?? 4,
      );
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int xp;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.xp,
  });
}

class ScheduledDay {
  final String day; // monday..sunday
  final String dayName;
  final String type; // 'training' | 'rest'
  final String? workoutId;
  final Workout? workout;
  final int? duration;
  final bool completed;
  final bool missed;
  final bool isToday;

  const ScheduledDay({
    required this.day,
    required this.dayName,
    required this.type,
    this.workoutId,
    this.workout,
    this.duration,
    this.completed = false,
    this.missed = false,
    this.isToday = false,
  });

  Map<String, dynamic> toJson() => {
        'day': day,
        'dayName': dayName,
        'type': type,
        'workoutId': workoutId,
        'duration': duration,
        'completed': completed,
        'missed': missed,
      };

  factory ScheduledDay.fromJson(Map<String, dynamic> j) => ScheduledDay(
        day: j['day'] as String,
        dayName: j['dayName'] as String,
        type: j['type'] as String,
        workoutId: j['workoutId'] as String?,
        duration: j['duration'] as int?,
        completed: j['completed'] as bool? ?? false,
        missed: j['missed'] as bool? ?? false,
        isToday: false, // Always calculated at runtime
      );

  ScheduledDay copyWith({
    String? type,
    String? workoutId,
    Workout? workout,
    int? duration,
    bool? completed,
    bool? missed,
    bool? isToday,
  }) {
    return ScheduledDay(
      day: day,
      dayName: dayName,
      type: type ?? this.type,
      workoutId: workoutId ?? this.workoutId,
      workout: workout ?? this.workout,
      duration: duration ?? this.duration,
      completed: completed ?? this.completed,
      missed: missed ?? this.missed,
      isToday: isToday ?? this.isToday,
    );
  }
}

class UserProfile {
  final String name;
  final int age;
  final int height;
  final int weight;
  final String experience;
  final String level; // beginner | intermediate | advanced
  final List<String> martialArts;
  final List<String> goals;
  final String journeyStart;
  final int sessionDuration;
  final int daysPerWeek;
  final List<String> availableDays;
  final List<String> equipment;

  const UserProfile({
    this.name = 'Athlete',
    this.age = 25,
    this.height = 175,
    this.weight = 75,
    this.experience = '1 year',
    this.level = 'intermediate',
    this.martialArts = const ['boxing'],
    this.goals = const ['technique'],
    this.journeyStart = 'Just starting out',
    this.sessionDuration = 30,
    this.daysPerWeek = 4,
    this.availableDays = const ['monday', 'wednesday', 'friday', 'saturday'],
    this.equipment = const ['gloves'],
  });

  UserProfile copyWith({
    String? name,
    int? age,
    int? height,
    int? weight,
    String? experience,
    String? level,
    List<String>? martialArts,
    List<String>? goals,
    String? journeyStart,
    int? sessionDuration,
    int? daysPerWeek,
    List<String>? availableDays,
    List<String>? equipment,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      experience: experience ?? this.experience,
      level: level ?? this.level,
      martialArts: martialArts ?? this.martialArts,
      goals: goals ?? this.goals,
      journeyStart: journeyStart ?? this.journeyStart,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      availableDays: availableDays ?? this.availableDays,
      equipment: equipment ?? this.equipment,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'height': height,
        'weight': weight,
        'experience': experience,
        'level': level,
        'martialArts': martialArts,
        'goals': goals,
        'journeyStart': journeyStart,
        'sessionDuration': sessionDuration,
        'daysPerWeek': daysPerWeek,
        'availableDays': availableDays,
        'equipment': equipment,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        name: j['name'] as String? ?? 'Athlete',
        age: j['age'] as int? ?? 25,
        height: j['height'] as int? ?? 175,
        weight: j['weight'] as int? ?? 75,
        experience: j['experience'] as String? ?? '1 year',
        level: j['level'] as String? ?? 'intermediate',
        martialArts: (j['martialArts'] as List?)?.cast<String>() ?? const ['boxing'],
        goals: (j['goals'] as List?)?.cast<String>() ?? const ['technique'],
        journeyStart: j['journeyStart'] as String? ?? 'Just starting out',
        sessionDuration: j['sessionDuration'] as int? ?? 30,
        daysPerWeek: j['daysPerWeek'] as int? ?? 4,
        availableDays: (j['availableDays'] as List?)?.cast<String>() ??
            const ['monday', 'wednesday', 'friday', 'saturday'],
        equipment: (j['equipment'] as List?)?.cast<String>() ?? const ['gloves'],
      );
}
