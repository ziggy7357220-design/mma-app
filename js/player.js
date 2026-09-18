// ============================================================
// WORKOUT PLAYER — Sequential exercise player with timer
// ============================================================

import { el, icon, toast, fmtMinutes } from './ui.js';
import { store } from './state.js';

export class WorkoutPlayer {
  constructor(workout, onComplete) {
    this.workout = workout;
    this.onComplete = onComplete;
    this.exerciseIdx = 0;
    this.timeLeft = workout.exercises[0].duration; // seconds
    this.totalElapsed = 0;
    this.paused = true;
    this.interval = null;
  }

  mount(container) {
    this.container = container;
    this.render();
  }

  render() {
    this.container.innerHTML = '';
    const exercise = this.workout.exercises[this.exerciseIdx];
    const next = this.workout.exercises[this.exerciseIdx + 1];

    const screen = el('div', { class: 'player' });

    // Header
    const header = el('div', { class: 'player-header' },
      el('button', {
        class: 'player-close',
        onclick: () => this.handleClose(),
        html: icon('close'),
      }),
      el('div', { class: 'player-title' }, this.workout.title),
      this.renderProgress(),
    );
    screen.appendChild(header);

    // Body
    const body = el('div', { class: 'player-body' });

    body.appendChild(el('div', { class: 'player-exercise-num' }, `Exercise ${this.exerciseIdx + 1} of ${this.workout.exercises.length}`));
    body.appendChild(el('div', { class: 'player-exercise-name' }, exercise.name));
    if (exercise.desc) {
      body.appendChild(el('div', { class: 'player-exercise-desc' }, exercise.desc));
    }
    body.appendChild(el('div', { class: 'player-timer' }, this.formatTime(Math.max(0, Math.ceil(this.timeLeft)))));

    if (next) {
      const nextBlock = el('div', { class: 'player-next' },
        el('div', { class: 'player-next-label' }, 'Next up'),
        el('div', { class: 'player-next-name' }, next.name),
      );
      body.appendChild(nextBlock);
    } else {
      body.appendChild(el('div', { class: 'player-next' },
        el('div', { class: 'player-next-label' }, 'Final exercise'),
        el('div', { class: 'player-next-name' }, 'One more round!'),
      ));
    }

    screen.appendChild(body);

    // Footer
    const footer = el('div', { class: 'player-footer' });
    if (this.exerciseIdx > 0) {
      footer.appendChild(el('button', {
        class: 'btn btn-secondary',
        onclick: () => this.handlePrev(),
      }, 'Previous'));
    }
    footer.appendChild(el('button', {
      class: 'btn btn-primary',
      onclick: () => this.handleToggle(),
    },
      el('span', { html: icon(this.paused ? 'play' : 'pause') }),
      this.paused ? 'Start' : 'Pause',
    ));
    footer.appendChild(el('button', {
      class: 'btn btn-secondary',
      onclick: () => this.handleSkip(),
    }, 'Skip'));
    screen.appendChild(footer);

    this.container.appendChild(screen);

    if (!this.paused) this.startTimer();
  }

  renderProgress() {
    const progress = el('div', { class: 'player-progress' });
    this.workout.exercises.forEach((_, i) => {
      let cls = '';
      if (i < this.exerciseIdx) cls = 'done';
      else if (i === this.exerciseIdx) cls = 'active';
      progress.appendChild(el('div', { class: `player-progress-dot ${cls}` }));
    });
    return progress;
  }

  startTimer() {
    if (this.interval) clearInterval(this.interval);
    this.interval = setInterval(() => {
      this.timeLeft -= 1;
      this.totalElapsed += 1;
      if (this.timeLeft <= 0) {
        this.handleNextExercise();
      } else {
        // Update timer without full re-render
        const timerNode = this.container.querySelector('.player-timer');
        if (timerNode) timerNode.textContent = this.formatTime(Math.ceil(this.timeLeft));
      }
    }, 1000);
  }

  stopTimer() {
    if (this.interval) clearInterval(this.interval);
    this.interval = null;
  }

  handleToggle() {
    this.paused = !this.paused;
    this.render();
  }

  handleNextExercise() {
    this.stopTimer();
    if (this.exerciseIdx >= this.workout.exercises.length - 1) {
      this.complete();
      return;
    }
    this.exerciseIdx++;
    this.timeLeft = this.workout.exercises[this.exerciseIdx].duration;
    this.render();
  }

  handlePrev() {
    this.stopTimer();
    if (this.exerciseIdx > 0) {
      this.exerciseIdx--;
      this.timeLeft = this.workout.exercises[this.exerciseIdx].duration;
      this.render();
    }
  }

  handleSkip() {
    this.stopTimer();
    this.timeLeft = 0;
    this.handleNextExercise();
  }

  handleClose() {
    if (this.totalElapsed > 30) {
      if (!confirm('Exit workout? Progress will be lost.')) return;
    }
    this.stopTimer();
    this.container.innerHTML = '';
  }

  complete() {
    this.stopTimer();
    const xp = this.workout.xp || 30;
    const duration = Math.round(this.workout.duration);
    store.recordSession({
      workoutId: this.workout.id,
      duration,
      xp,
    });

    // Show completion screen
    this.container.innerHTML = '';
    const complete = el('div', { class: 'complete-screen' });
    complete.appendChild(el('div', { class: 'complete-icon' }, '✓'));
    complete.appendChild(el('div', { class: 'complete-title' }, 'Workout Complete'));
    complete.appendChild(el('div', { style: 'color: var(--text-secondary); margin-top: 8px;' },
      this.workout.title));

    const stats = el('div', { class: 'complete-stats' });
    stats.appendChild(el('div', {},
      el('div', { class: 'complete-stat-value' }, fmtMinutes(duration)),
      el('div', { class: 'complete-stat-label' }, 'Duration'),
    ));
    stats.appendChild(el('div', {},
      el('div', { class: 'complete-stat-value' }, `+${xp}`),
      el('div', { class: 'complete-stat-label' }, 'XP'),
    ));
    stats.appendChild(el('div', {},
      el('div', { class: 'complete-stat-value' }, store.get().currentStreak),
      el('div', { class: 'complete-stat-label' }, 'Day Streak'),
    ));
    complete.appendChild(stats);

    // Action buttons
    const actions = el('div', { style: 'display: flex; gap: 12px; margin-top: 48px; width: 100%; max-width: 320px;' });
    actions.appendChild(el('button', {
      class: 'btn btn-primary',
      onclick: () => this.onComplete(),
    }, 'Done'));
    complete.appendChild(actions);

    this.container.appendChild(complete);

    if (this.onComplete) this.onComplete({ completed: true });
  }

  formatTime(seconds) {
    const m = Math.floor(seconds / 60);
    const s = Math.floor(seconds % 60);
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  }
}

// ============================================================
// ROUND TIMER — Standalone round timer
// ============================================================

export class RoundTimer {
  constructor() {
    this.rounds = 3;
    this.roundDuration = 180; // 3 min
    this.restDuration = 60;
    this.currentRound = 1;
    this.timeLeft = this.roundDuration;
    this.isRest = false;
    this.paused = true;
    this.interval = null;
  }

  mount(container) {
    this.container = container;
    this.render();
  }

  render() {
    this.container.innerHTML = '';
    const screen = el('div', { class: 'screen' });

    // Header
    const header = el('div', { class: 'screen-header' },
      el('div', {},
        el('div', { class: 'screen-title' }, 'Round Timer'),
        el('div', { class: 'screen-subtitle' }, 'Train in rounds with rest periods'),
      ),
    );
    screen.appendChild(header);

    const content = el('div', { class: 'content' });

    if (!this.paused) {
      // Active timer view
      const timerScreen = el('div', { class: 'timer-screen' });
      timerScreen.appendChild(el('div', { class: 'timer-round' },
        `Round ${this.currentRound} / ${this.rounds} — ${this.isRest ? 'REST' : 'WORK'}`));
      timerScreen.appendChild(el('div', { class: 'timer-clock' }, this.formatTime(this.timeLeft)));
      timerScreen.appendChild(el('div', { class: 'timer-state' },
        this.paused ? 'Paused' : (this.isRest ? 'Recover' : 'Push')));

      content.appendChild(timerScreen);

      const footer = el('div', { style: 'display: flex; gap: 12px;' });
      footer.appendChild(el('button', {
        class: 'btn btn-primary',
        onclick: () => { this.paused = !this.paused; this.render(); if (!this.paused) this.startTimer(); },
      },
        el('span', { html: icon(this.paused ? 'play' : 'pause') }),
        this.paused ? 'Resume' : 'Pause',
      ));
      footer.appendChild(el('button', {
        class: 'btn btn-secondary',
        onclick: () => this.reset(),
      }, 'Reset'));
      content.appendChild(footer);
    } else {
      // Config view
      const config = el('div', { class: 'card' });
      config.appendChild(el('div', { style: 'font-weight: 600; margin-bottom: 16px;' }, 'Configure'));

      // Rounds
      config.appendChild(el('div', { class: 'skill-name', style: 'margin-top: 12px;' }, 'Rounds'));
      const roundsRow = el('div', { style: 'display: flex; gap: 8px; flex-wrap: wrap; margin-top: 8px;' });
      [3, 5, 8, 10, 12].forEach(n => {
        roundsRow.appendChild(el('button', {
          class: 'combo-strike',
          style: this.rounds === n ? 'border-color: var(--accent); background: var(--accent-dim);' : '',
          onclick: () => { this.rounds = n; this.render(); },
        }, String(n)));
      });
      config.appendChild(roundsRow);

      // Round duration
      config.appendChild(el('div', { class: 'skill-name', style: 'margin-top: 20px;' }, 'Round (min)'));
      const roundRow = el('div', { style: 'display: flex; gap: 8px; flex-wrap: wrap; margin-top: 8px;' });
      [2, 3, 5].forEach(m => {
        roundRow.appendChild(el('button', {
          class: 'combo-strike',
          style: this.roundDuration === m * 60 ? 'border-color: var(--accent); background: var(--accent-dim);' : '',
          onclick: () => { this.roundDuration = m * 60; this.render(); },
        }, `${m} min`));
      });
      config.appendChild(roundRow);

      // Rest duration
      config.appendChild(el('div', { class: 'skill-name', style: 'margin-top: 20px;' }, 'Rest (sec)'));
      const restRow = el('div', { style: 'display: flex; gap: 8px; flex-wrap: wrap; margin-top: 8px;' });
      [30, 60, 90].forEach(s => {
        restRow.appendChild(el('button', {
          class: 'combo-strike',
          style: this.restDuration === s ? 'border-color: var(--accent); background: var(--accent-dim);' : '',
          onclick: () => { this.restDuration = s; this.render(); },
        }, `${s}s`));
      });
      config.appendChild(restRow);

      content.appendChild(config);

      content.appendChild(el('button', {
        class: 'btn btn-primary btn-large',
        onclick: () => { this.paused = false; this.render(); this.startTimer(); },
      },
        el('span', { html: icon('play') }),
        'Start Timer',
      ));
    }

    screen.appendChild(content);
    this.container.appendChild(screen);
  }

  startTimer() {
    if (this.interval) clearInterval(this.interval);
    this.interval = setInterval(() => {
      this.timeLeft--;
      if (this.timeLeft <= 0) {
        if (this.isRest) {
          this.currentRound++;
          if (this.currentRound > this.rounds) {
            this.finish();
            return;
          }
          this.isRest = false;
          this.timeLeft = this.roundDuration;
        } else {
          this.isRest = true;
          this.timeLeft = this.restDuration;
        }
        this.render();
      } else {
        const node = this.container.querySelector('.timer-clock');
        if (node) node.textContent = this.formatTime(this.timeLeft);
      }
    }, 1000);
  }

  reset() {
    if (this.interval) clearInterval(this.interval);
    this.interval = null;
    this.paused = true;
    this.currentRound = 1;
    this.isRest = false;
    this.timeLeft = this.roundDuration;
    this.render();
  }

  finish() {
    if (this.interval) clearInterval(this.interval);
    this.interval = null;
    toast('Round timer complete!');
    this.reset();
  }

  formatTime(seconds) {
    const m = Math.floor(seconds / 60);
    const s = Math.floor(seconds % 60);
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  }
}
