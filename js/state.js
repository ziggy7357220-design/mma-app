// ============================================================
// STATE MANAGEMENT — localStorage-backed reactive store
// ============================================================
// Single source of truth for app state.
// Persists between sessions.
// ============================================================

const STORAGE_KEY = 'stance.app.v1';

const DEFAULT_STATE = {
  onboarded: false,
  profile: {
    name: 'Athlete',
    level: 'intermediate',
    martialArts: ['boxing'],
    goals: ['technique'],
    sessionDuration: 30,
    daysPerWeek: 4,
    availableDays: ['monday', 'wednesday', 'friday', 'saturday'],
    equipment: ['gloves'],
  },
  schedule: [], // 7 days of schedule
  scheduleWeek: 0,
  completedSessions: [], // [{ date, workoutId, duration, xp }]
  learnedTechniques: [], // ids
  skillProgress: {
    boxing: { jab: 0, cross: 0, hook: 0, slip: 0, roll: 0, footwork: 0 },
    taekwondo: { roundhouse: 0, side_kick: 0, front_kick: 0, spinning_kick: 0 },
  },
  xp: 0,
  level: 1,
  totalTrainingMinutes: 0,
  workoutsCompleted: 0,
  currentStreak: 0,
  longestStreak: 0,
  lastTrainingDate: null,
  achievements: [],
  combos: [],
  unlockedAchievements: [],
};

class Store {
  constructor() {
    this.state = this.load();
    this.listeners = [];
  }

  load() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) {
        const parsed = JSON.parse(raw);
        return { ...DEFAULT_STATE, ...parsed };
      }
    } catch (e) {
      console.warn('Failed to load state', e);
    }
    return { ...DEFAULT_STATE };
  }

  save() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(this.state));
    } catch (e) {
      console.warn('Failed to save state', e);
    }
  }

  subscribe(fn) {
    this.listeners.push(fn);
    return () => {
      this.listeners = this.listeners.filter(l => l !== fn);
    };
  }

  emit() {
    for (const fn of this.listeners) fn(this.state);
  }

  get() {
    return this.state;
  }

  set(updates) {
    this.state = { ...this.state, ...updates };
    this.save();
    this.emit();
  }

  patchProfile(updates) {
    this.state.profile = { ...this.state.profile, ...updates };
    this.save();
    this.emit();
  }

  reset() {
    this.state = { ...DEFAULT_STATE };
    this.save();
    this.emit();
  }

  // ----- Domain actions -----

  completeOnboarding(profile, schedule) {
    this.set({
      onboarded: true,
      profile,
      schedule,
    });
  }

  recordSession({ workoutId, duration, xp, date }) {
    const completed = [
      ...this.state.completedSessions,
      { workoutId, duration, xp, date: date || new Date().toISOString() },
    ];

    // Mark today's schedule slot complete
    const today = new Date();
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    const todayKey = days[today.getDay()];
    const schedule = this.state.schedule.map(d => {
      if (d.day === todayKey && d.type === 'training') {
        return { ...d, completed: true, missed: false };
      }
      return d;
    });

    const newXp = this.state.xp + xp;
    const newLevel = Math.floor(newXp / 100) + 1;
    const totalMinutes = this.state.totalTrainingMinutes + Math.round(duration);
    const workoutsCompleted = this.state.workoutsCompleted + 1;

    // Update streak
    const streak = updateStreak(this.state);

    // Update skill progress for the workout
    const skillProgress = updateSkillProgress(this.state.skillProgress, workoutId);

    // Check achievements
    const achievements = checkAchievements({
      ...this.state,
      xp: newXp,
      workoutsCompleted,
      totalTrainingMinutes: totalMinutes,
      currentStreak: streak.current,
      learnedTechniques: this.state.learnedTechniques,
    }, this.state.unlockedAchievements);

    this.set({
      completedSessions: completed,
      schedule,
      xp: newXp,
      level: newLevel,
      totalTrainingMinutes: totalMinutes,
      workoutsCompleted,
      currentStreak: streak.current,
      longestStreak: streak.longest,
      lastTrainingDate: new Date().toISOString(),
      skillProgress,
      unlockedAchievements: achievements,
    });
  }

  markTechniqueLearned(techniqueId, art) {
    if (this.state.learnedTechniques.includes(techniqueId)) return;
    const learnedTechniques = [...this.state.learnedTechniques, techniqueId];
    const newXp = this.state.xp + 10;

    // Update skill progress
    const skillProgress = { ...this.state.skillProgress };
    if (skillProgress[art]) {
      skillProgress[art] = { ...skillProgress[art], [techniqueId]: Math.min(100, (skillProgress[art][techniqueId] || 0) + 25) };
    }

    const achievements = checkAchievements({
      ...this.state,
      xp: newXp,
      learnedTechniques,
    }, this.state.unlockedAchievements);

    this.set({
      learnedTechniques,
      xp: newXp,
      level: Math.floor(newXp / 100) + 1,
      skillProgress,
      unlockedAchievements: achievements,
    });
  }

  addXP(amount, reason) {
    const newXp = this.state.xp + amount;
    this.set({
      xp: newXp,
      level: Math.floor(newXp / 100) + 1,
    });
  }

  saveCombo(name, strikes) {
    const combo = {
      id: 'combo_' + Date.now(),
      name,
      strikes,
      createdAt: new Date().toISOString(),
    };
    this.set({ combos: [...this.state.combos, combo] });
    return combo;
  }

  removeCombo(id) {
    this.set({ combos: this.state.combos.filter(c => c.id !== id) });
  }

  rescheduleDay(fromDay, toDay) {
    const from = this.state.schedule.find(d => d.day === fromDay);
    const to = this.state.schedule.find(d => d.day === toDay);
    if (!from || !to || to.type !== 'rest' || from.type === 'rest') return;

    const schedule = this.state.schedule.map(d => {
      if (d.day === fromDay) {
        return { ...d, type: 'rest', workoutId: null, workout: null, missed: false };
      }
      if (d.day === toDay) {
        return { ...d, type: 'training', workoutId: from.workoutId, workout: from.workout, duration: from.duration, missed: true };
      }
      return d;
    });
    this.set({ schedule });
  }

  regeneratePlan(profile) {
    import('./data/plan.js').then(({ generateWeeklyPlan }) => {
      const schedule = generateWeeklyPlan(profile);
      this.set({ profile, schedule });
    });
  }

  updateProfile(updates) {
    this.patchProfile(updates);
  }
}

function updateStreak(state) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const lastDate = state.lastTrainingDate ? new Date(state.lastTrainingDate) : null;
  if (lastDate) lastDate.setHours(0, 0, 0, 0);

  const diffDays = lastDate ? Math.round((today - lastDate) / (1000 * 60 * 60 * 24)) : null;

  let current = state.currentStreak || 0;
  let longest = state.longestStreak || 0;

  if (diffDays === null) {
    current = 1;
  } else if (diffDays === 0) {
    // Already trained today
    current = Math.max(1, current);
  } else if (diffDays === 1) {
    current += 1;
  } else if (diffDays > 1) {
    current = 1;
  }

  longest = Math.max(longest, current);
  return { current, longest };
}

function updateSkillProgress(progress, workoutId) {
  // Map workout to skills
  const map = {
    boxing_footwork: { boxing: ['footwork'] },
    boxing_combinations: { boxing: ['jab', 'cross', 'hook'] },
    boxing_defense: { boxing: ['slip', 'roll'] },
    taekwondo_kicking: { taekwondo: ['roundhouse', 'side_kick'] },
    taekwondo_footwork: { taekwondo: ['front_kick'] },
  };
  const updates = map[workoutId];
  if (!updates) return progress;

  const newProgress = { ...progress };
  for (const [art, skills] of Object.entries(updates)) {
    newProgress[art] = { ...(progress[art] || {}) };
    for (const skill of skills) {
      const current = newProgress[art][skill] || 0;
      newProgress[art][skill] = Math.min(100, current + 5);
    }
  }
  return newProgress;
}

function checkAchievements(state, alreadyUnlocked) {
  const { ACHIEVEMENTS } = window.STANCE_DATA || {};
  if (!ACHIEVEMENTS) return alreadyUnlocked;

  const newUnlocked = [...alreadyUnlocked];
  const alreadySet = new Set(alreadyUnlocked);

  for (const ach of ACHIEVEMENTS) {
    if (alreadySet.has(ach.id)) continue;
    if (testAchievement(ach.id, state)) {
      newUnlocked.push(ach.id);
    }
  }
  return newUnlocked;
}

function testAchievement(id, state) {
  switch (id) {
    case 'first_training': return state.workoutsCompleted >= 1;
    case 'streak_7': return state.currentStreak >= 7;
    case 'streak_30': return state.currentStreak >= 30;
    case 'hours_5': return state.totalTrainingMinutes >= 300;
    case 'workouts_100': return state.workoutsCompleted >= 100;
    case 'boxing_basics': return state.learnedTechniques.filter(t => ['jab', 'cross', 'hook'].includes(t)).length >= 3;
    case 'tkd_basics': return state.learnedTechniques.filter(t => ['roundhouse', 'side_kick', 'front_kick'].includes(t)).length >= 3;
    case 'footwork_foundation': return state.workoutsCompleted >= 5;
    case 'monthly_goal': return state.workoutsCompleted >= 12;
    default: return false;
  }
}

export const store = new Store();
