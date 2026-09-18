// ============================================================
// TRAIN SCREEN
// ============================================================

import { el, icon, fmtMinutes } from '../ui.js';
import { WORKOUTS } from '../data/content.js';
import { store } from '../state.js';
import { RoundTimer } from '../player.js';
import { ComboCreator } from '../combo.js';

export class TrainScreen {
  constructor(onStartWorkout) {
    this.onStartWorkout = onStartWorkout;
    this.view = 'main'; // 'main' | 'timer' | 'combo'
  }

  render(container) {
    container.innerHTML = '';

    if (this.view === 'timer') {
      const timer = new RoundTimer();
      timer.mount(container);
      // Add back button
      const back = el('button', {
        class: 'btn btn-ghost',
        style: 'position: fixed; top: 16px; left: 16px; z-index: 10; padding: 8px 12px; background: var(--bg-card); border-radius: 50%;',
        onclick: () => { this.view = 'main'; this.render(container); },
        html: icon('chevronLeft'),
      });
      container.appendChild(back);
      return;
    }

    if (this.view === 'combo') {
      const combo = new ComboCreator();
      combo.mount(container);
      const back = el('button', {
        class: 'btn btn-ghost',
        style: 'position: fixed; top: 16px; left: 16px; z-index: 10; padding: 8px 12px; background: var(--bg-card); border-radius: 50%;',
        onclick: () => { this.view = 'main'; this.render(container); },
        html: icon('chevronLeft'),
      });
      container.appendChild(back);
      return;
    }

    const screen = el('div', { class: 'screen' });
    const header = el('div', { class: 'screen-header' },
      el('div', {},
        el('div', { class: 'screen-title' }, 'Train'),
        el('div', { class: 'screen-subtitle' }, 'Pick your session'),
      ),
    );
    screen.appendChild(header);

    const content = el('div', { class: 'content' });

    // Quick tools
    content.appendChild(el('div', { class: 'section-title' }, 'Quick tools'));
    const tools = el('div', { style: 'display: grid; grid-template-columns: 1fr 1fr; gap: 10px;' });
    tools.appendChild(el('button', {
      class: 'train-tile',
      onclick: () => { this.view = 'timer'; this.render(container); },
    },
      el('div', { class: 'train-tile-icon', html: icon('timer') }),
      el('div', { class: 'train-tile-title' }, 'Round Timer'),
      el('div', { class: 'train-tile-desc' }, 'Configurable rounds with rest'),
    ));
    tools.appendChild(el('button', {
      class: 'train-tile',
      onclick: () => { this.view = 'combo'; this.render(container); },
    },
      el('div', { class: 'train-tile-icon', html: icon('list') }),
      el('div', { class: 'train-tile-title' }, 'Combo Creator'),
      el('div', { class: 'train-tile-desc' }, 'Build and save combinations'),
    ));
    content.appendChild(tools);

    // Today's planned workout
    const state = store.get();
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    const todayKey = days[new Date().getDay()];
    const today = (state.schedule || []).find(d => d.day === todayKey);
    if (today && today.type === 'training' && today.workout) {
      content.appendChild(el('div', { class: 'section-title', style: 'margin-top: 8px;' }, 'Today'));
      content.appendChild(el('button', {
        class: 'train-tile',
        onclick: () => this.onStartWorkout(today.workout),
      },
        el('div', { class: 'train-tile-icon', html: icon('play') }),
        el('div', { class: 'train-tile-title' }, today.workout.title),
        el('div', { class: 'train-tile-desc' },
          `${fmtMinutes(today.workout.duration)} • ${today.workout.exercises.length} exercises • ${today.workout.xp} XP`),
      ));
    }

    // Workout library
    content.appendChild(el('div', { class: 'section-header', style: 'margin-top: 16px;' },
      el('div', { class: 'section-title' }, 'All workouts'),
    ));

    const workouts = Object.values(WORKOUTS);
    workouts.forEach(workout => {
      content.appendChild(el('button', {
        class: 'train-tile',
        onclick: () => this.onStartWorkout(workout),
      },
        el('div', { class: 'train-tile-icon', html: icon('zap') }),
        el('div', { class: 'train-tile-title' }, workout.title),
        el('div', { class: 'train-tile-desc' },
          `${fmtMinutes(workout.duration)} • ${workout.difficulty || 'all levels'} • ${workout.xp} XP`),
      ));
    });

    screen.appendChild(content);
    container.appendChild(screen);
  }
}
