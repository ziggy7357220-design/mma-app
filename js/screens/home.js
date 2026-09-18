// ============================================================
// HOME SCREEN
// ============================================================

import { el, icon, fmtMinutes } from '../ui.js';
import { store } from '../state.js';

export class HomeScreen {
  constructor(onStartWorkout, onNavigate) {
    this.onStartWorkout = onStartWorkout;
    this.onNavigate = onNavigate;
  }

  render(container) {
    container.innerHTML = '';
    const screen = el('div', { class: 'screen' });

    const state = store.get();
    const schedule = state.schedule || [];
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    const todayKey = days[new Date().getDay()];
    const today = schedule.find(d => d.day === todayKey);

    // Header
    const header = el('div', { style: 'padding: 24px 20px 8px;' },
      el('div', { class: 'greeting' }, this.getGreeting()),
      el('div', { class: 'user-name' }, state.profile.name || 'Athlete'),
    );
    screen.appendChild(header);

    const content = el('div', { class: 'content' });

    // Hero card — today's training
    const heroCard = el('div', { class: 'hero-card' });
    if (today && today.type === 'training' && today.workout) {
      heroCard.appendChild(el('div', { class: 'hero-label' }, "Today's Training"));
      heroCard.appendChild(el('div', { class: 'hero-title' }, today.workout.title));
      heroCard.appendChild(el('div', { class: 'hero-subtitle' }, this.daySubtitle(today)));

      const stats = el('div', { class: 'hero-stats' });
      stats.appendChild(el('div', { class: 'hero-stat' },
        el('div', { class: 'hero-stat-value' }, fmtMinutes(today.workout.duration)),
        el('div', { class: 'hero-stat-label' }, 'Duration'),
      ));
      stats.appendChild(el('div', { class: 'hero-stat' },
        el('div', { class: 'hero-stat-value' }, `${today.workout.exercises.length}`),
        el('div', { class: 'hero-stat-label' }, 'Exercises'),
      ));
      stats.appendChild(el('div', { class: 'hero-stat' },
        el('div', { class: 'hero-stat-value' }, `${today.workout.xp} XP`),
        el('div', { class: 'hero-stat-label' }, 'Reward'),
      ));
      heroCard.appendChild(stats);

      heroCard.appendChild(el('button', {
        class: 'btn-start',
        onclick: () => this.onStartWorkout(today.workout),
      },
        el('span', { html: icon('play') }),
        today.completed ? 'Train Again' : 'Start Training',
      ));
    } else if (today && today.type === 'rest') {
      heroCard.appendChild(el('div', { class: 'hero-label' }, 'Rest Day'));
      heroCard.appendChild(el('div', { class: 'hero-title' }, 'Recovery Time'));
      heroCard.appendChild(el('div', { class: 'hero-subtitle' }, 'Stretch, hydrate, and recover. Tomorrow we train.'));

      const stats = el('div', { class: 'hero-stats' });
      stats.appendChild(el('div', { class: 'hero-stat' },
        el('div', { class: 'hero-stat-value' }, state.currentStreak),
        el('div', { class: 'hero-stat-label' }, 'Day Streak'),
      ));
      stats.appendChild(el('div', { class: 'hero-stat' },
        el('div', { class: 'hero-stat-value' }, fmtMinutes(state.totalTrainingMinutes)),
        el('div', { class: 'hero-stat-label' }, 'Total Time'),
      ));
      heroCard.appendChild(stats);

      heroCard.appendChild(el('button', {
        class: 'btn-start',
        onclick: () => this.onNavigate('train'),
      },
        el('span', { html: icon('train') }),
        'Open Trainer',
      ));
    } else {
      heroCard.appendChild(el('div', { class: 'hero-label' }, 'No training today'));
      heroCard.appendChild(el('div', { class: 'hero-title' }, 'Pick a workout'));
      heroCard.appendChild(el('div', { class: 'hero-subtitle' }, 'Browse the Train section to start a session.'));

      heroCard.appendChild(el('button', {
        class: 'btn-start',
        onclick: () => this.onNavigate('train'),
      },
        el('span', { html: icon('train') }),
        'Open Trainer',
      ));
    }
    content.appendChild(heroCard);

    // Stats grid
    content.appendChild(el('div', { class: 'section-header', style: 'margin-top: 8px;' },
      el('div', { class: 'section-title' }, 'This Week'),
    ));

    const statsGrid = el('div', { class: 'stats-grid' });
    const weekDone = schedule.filter(d => d.type === 'training' && d.completed).length;
    const weekTotal = schedule.filter(d => d.type === 'training').length;
    const weekPct = weekTotal ? Math.round((weekDone / weekTotal) * 100) : 0;

    statsGrid.appendChild(el('div', { class: 'stat-tile' },
      el('div', { class: 'stat-tile-label' }, 'Weekly Goal'),
      el('div', { class: 'stat-tile-value' }, `${weekPct}%`),
      el('div', { class: 'stat-tile-sub' }, `${weekDone} / ${weekTotal} sessions`),
    ));
    statsGrid.appendChild(el('div', { class: 'stat-tile' },
      el('div', { class: 'stat-tile-label' }, 'Streak'),
      el('div', { class: 'stat-tile-value' }, `${state.currentStreak} 🔥`),
      el('div', { class: 'stat-tile-sub' }, 'Consecutive days'),
    ));
    statsGrid.appendChild(el('div', { class: 'stat-tile' },
      el('div', { class: 'stat-tile-label' }, 'Level'),
      el('div', { class: 'stat-tile-value' }, state.level),
      el('div', { class: 'stat-tile-sub' }, `${state.xp} XP`),
    ));
    statsGrid.appendChild(el('div', { class: 'stat-tile' },
      el('div', { class: 'stat-tile-label' }, 'Total Time'),
      el('div', { class: 'stat-tile-value' }, fmtMinutes(state.totalTrainingMinutes)),
      el('div', { class: 'stat-tile-sub' }, 'All training'),
    ));
    content.appendChild(statsGrid);

    // Recommended workouts
    content.appendChild(el('div', { class: 'section-header' },
      el('div', { class: 'section-title' }, 'Recommended'),
      el('button', { class: 'section-link', onclick: () => this.onNavigate('train') }, 'See all'),
    ));

    const recs = this.getRecommendations(state);
    recs.slice(0, 3).forEach(workout => {
      content.appendChild(el('button', {
        class: 'train-tile',
        onclick: () => this.onStartWorkout(workout),
      },
        el('div', { class: 'train-tile-icon', html: icon('zap') }),
        el('div', { class: 'train-tile-title' }, workout.title),
        el('div', { class: 'train-tile-desc' }, `${fmtMinutes(workout.duration)} • ${workout.difficulty || 'intermediate'} • ${workout.xp} XP`),
      ));
    });

    screen.appendChild(content);
    container.appendChild(screen);
  }

  getGreeting() {
    const h = new Date().getHours();
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  daySubtitle(today) {
    if (today.completed) return 'Completed. Train again anytime.';
    if (today.missed) return 'Missed earlier. Let\'s reschedule.';
    return `${today.workout.exercises.length} exercises ready to go.`;
  }

  getRecommendations(state) {
    // Return a few workouts based on user preferences
    const arts = state.profile.martialArts || [];
    const map = {
      boxing: ['boxing_footwork', 'boxing_combinations', 'boxing_defense'],
      taekwondo: ['taekwondo_kicking', 'taekwondo_footwork'],
      muay_thai: ['muay_thai_striking'],
      kickboxing: ['kickboxing_combos'],
      wrestling: ['wrestling_takedowns'],
      bjj: ['bjj_fundamentals'],
    };
    const ids = [];
    for (const art of arts) {
      if (map[art]) ids.push(...map[art]);
    }
    if (ids.length === 0) ids.push('boxing_footwork', 'taekwondo_kicking');
    // Dedupe
    const seen = new Set();
    const uniq = ids.filter(id => {
      if (seen.has(id)) return false;
      seen.add(id);
      return true;
    });

    // Import dynamically
    const out = [];
    for (const id of uniq.slice(0, 3)) {
      // We'll inject from main app context — for now hardcode names
      const titles = {
        boxing_footwork: { title: 'Boxing — Footwork', duration: 32, xp: 30, difficulty: 'intermediate', exercises: Array(8).fill({}), id: 'boxing_footwork' },
        boxing_combinations: { title: 'Boxing — Combinations', duration: 35, xp: 35, difficulty: 'intermediate', exercises: Array(7).fill({}), id: 'boxing_combinations' },
        boxing_defense: { title: 'Boxing — Defense', duration: 30, xp: 30, difficulty: 'intermediate', exercises: Array(7).fill({}), id: 'boxing_defense' },
        taekwondo_kicking: { title: 'Taekwondo — Kicking', duration: 32, xp: 30, difficulty: 'intermediate', exercises: Array(7).fill({}), id: 'taekwondo_kicking' },
        taekwondo_footwork: { title: 'Taekwondo — Footwork', duration: 28, xp: 25, difficulty: 'beginner', exercises: Array(7).fill({}), id: 'taekwondo_footwork' },
        muay_thai_striking: { title: 'Muay Thai — Striking', duration: 35, xp: 35, difficulty: 'intermediate', exercises: Array(6).fill({}), id: 'muay_thai_striking' },
      };
      if (titles[id]) out.push(titles[id]);
    }
    return out;
  }
}
