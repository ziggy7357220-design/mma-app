// ============================================================
// PERSONALIZATION ENGINE — Rule-based plan generator
// ============================================================
// Inputs: martial arts, level, goals, session time, days, equipment
// Output: weekly schedule (Mon-Sun)
// Simple, predictable, easy to modify.
// ============================================================

import { WORKOUTS } from './content.js';

/**
 * Generate a weekly plan based on user inputs.
 * Returns array of 7 days: each has { day, type, workoutId, completed }
 */
export function generateWeeklyPlan(profile) {
  const {
    martialArts = [],
    level = 'intermediate',
    goals = [],
    sessionDuration = 30,
    daysPerWeek = 4,
    availableDays = ['monday', 'wednesday', 'friday', 'saturday'],
    equipment = [],
  } = profile;

  // Determine which workout categories to use
  const workouts = selectWorkouts(martialArts, goals, equipment, level, sessionDuration);

  // Build the schedule
  const schedule = buildSchedule(workouts, daysPerWeek, availableDays, sessionDuration, martialArts);

  // Mark today's status
  return schedule.map(day => ({
    ...day,
    ...dayStatus(day.day),
  }));
}

/**
 * Select appropriate workouts based on user inputs.
 */
function selectWorkouts(martialArts, goals, equipment, level, duration) {
  const pool = [];

  // Map martial arts to workout categories
  const arts = Array.isArray(martialArts) ? martialArts : [martialArts];

  for (const art of arts) {
    const categoryWorkouts = getWorkoutsForArt(art);
    for (const w of categoryWorkouts) {
      // Filter by duration (within +/- 10 min)
      const durMatch = Math.abs(w.duration - duration) <= 10 || w.duration <= duration;
      // Filter by equipment (no required equipment, or user has it)
      const equipMatch = !w.equipment || w.equipment.every(e => equipment.includes(e));
      if (durMatch && equipMatch) {
        pool.push({ ...w, priority: scoreWorkout(w, art, goals) });
      }
    }
  }

  // Add strength/conditioning as cross-training
  pool.push({ ...WORKOUTS.strength_circuit, priority: 1 });
  pool.push({ ...WORKOUTS.conditioning_session, priority: 1 });

  // Sort by priority, dedupe by id
  const seen = new Set();
  return pool
    .sort((a, b) => b.priority - a.priority)
    .filter(w => {
      if (seen.has(w.id)) return false;
      seen.add(w.id);
      return true;
    });
}

/**
 * Get workouts for a martial art.
 */
function getWorkoutsForArt(art) {
  const map = {
    boxing: ['boxing_footwork', 'boxing_combinations', 'boxing_defense'],
    taekwondo: ['taekwondo_kicking', 'taekwondo_footwork'],
    muay_thai: ['muay_thai_striking'],
    kickboxing: ['kickboxing_combos'],
    wrestling: ['wrestling_takedowns'],
    bjj: ['bjj_fundamentals'],
    karate: ['boxing_combinations'],
    judo: ['wrestling_takedowns'],
    strength: ['strength_circuit', 'conditioning_session'],
    footwork: ['boxing_footwork', 'taekwondo_footwork'],
  };
  const ids = map[art] || [];
  return ids.map(id => WORKOUTS[id]).filter(Boolean);
}

/**
 * Score a workout based on goal alignment.
 */
function scoreWorkout(workout, art, goals) {
  let score = 1;
  const goalArtMap = {
    footwork: ['boxing_footwork', 'taekwondo_footwork', 'boxing_combinations'],
    technique: ['boxing_combinations', 'boxing_defense', 'taekwondo_kicking', 'muay_thai_striking'],
    conditioning: ['conditioning_session', 'strength_circuit'],
    strength: ['strength_circuit'],
    speed: ['boxing_combinations', 'taekwondo_kicking'],
    coordination: ['boxing_combinations', 'taekwondo_kicking'],
    mobility: ['taekwondo_footwork', 'boxing_footwork'],
    fundamentals: ['boxing_footwork', 'taekwondo_footwork', 'bjj_fundamentals', 'boxing_defense'],
  };
  for (const goal of goals) {
    if (goalArtMap[goal]?.includes(workout.id)) {
      score += 2;
    }
  }
  return score;
}

/**
 * Build the actual weekly schedule.
 */
function buildSchedule(workouts, daysPerWeek, availableDays, duration, martialArts) {
  const allDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  // Build schedule array
  const schedule = allDays.map((day, i) => ({
    day,
    dayName: dayNames[i],
    type: 'rest',
    workoutId: null,
    workout: null,
    completed: false,
    missed: false,
  }));

  // Place workouts on user's chosen days
  const targetDays = availableDays.slice(0, daysPerWeek);

  // Distribute workouts: alternate martial arts to avoid fatigue
  let workoutIdx = 0;
  for (const day of targetDays) {
    const dayIdx = allDays.indexOf(day);
    if (dayIdx === -1) continue;

    // Pick the next best workout
    let workout = workouts[workoutIdx % workouts.length];
    workoutIdx++;

    // If this is a strength day and we've already used it, skip
    while (
      (workout.id === 'strength_circuit' || workout.id === 'conditioning_session') &&
      schedule.some(d => d.workoutId === workout.id)
    ) {
      workoutIdx++;
      workout = workouts[workoutIdx % workouts.length] || workout;
    }

    schedule[dayIdx] = {
      ...schedule[dayIdx],
      type: 'training',
      workoutId: workout.id,
      workout,
      duration: workout.duration,
    };
  }

  // Make sure we have at least 1 strength day if training days >= 3
  if (daysPerWeek >= 3 && !schedule.some(d => d.workoutId === 'strength_circuit')) {
    const replaceDay = targetDays[Math.floor(targetDays.length / 2)];
    const idx = allDays.indexOf(replaceDay);
    if (idx !== -1) {
      schedule[idx] = {
        ...schedule[idx],
        type: 'training',
        workoutId: 'strength_circuit',
        workout: WORKOUTS.strength_circuit,
        duration: WORKOUTS.strength_circuit.duration,
      };
    }
  }

  return schedule;
}

/**
 * Return day status: today / past / future
 */
function dayStatus(dayKey) {
  const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
  const today = new Date();
  const todayKey = days[today.getDay()];
  if (todayKey === dayKey) return { isToday: true };
  return {};
}

/**
 * Reschedule a missed session to a rest day.
 */
export function rescheduleSession(schedule, fromDay, toDay) {
  const from = schedule.find(d => d.day === fromDay);
  const to = schedule.find(d => d.day === toDay);
  if (!from || !to || to.type !== 'rest') return schedule;

  return schedule.map(d => {
    if (d.day === fromDay) return { ...d, type: 'rest', workoutId: null, workout: null, missed: false };
    if (d.day === toDay) {
      return { ...d, type: 'training', workoutId: from.workoutId, workout: from.workout, duration: from.duration, missed: true };
    }
    return d;
  });
}

/**
 * Find next training day in schedule.
 */
export function nextTrainingDay(schedule) {
  return schedule.find(d => d.type === 'training');
}

/**
 * Find today's training day.
 */
export function todaysTraining(schedule) {
  return schedule.find(d => d.isToday);
}
