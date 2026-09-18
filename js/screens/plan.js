// ============================================================
// PLAN SCREEN
// ============================================================

import { el, icon, fmtMinutes, toast } from '../ui.js';
import { store } from '../state.js';

export class PlanScreen {
  constructor() {}

  render(container) {
    container.innerHTML = '';
    const screen = el('div', { class: 'screen' });

    const state = store.get();
    const schedule = state.schedule || [];
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    const todayKey = days[new Date().getDay()];
    const monthName = new Date().toLocaleString(undefined, { month: 'long', year: 'numeric' });

    // Header
    const header = el('div', { class: 'screen-header' },
      el('div', {},
        el('div', { class: 'screen-title' }, 'Plan'),
        el('div', { class: 'screen-subtitle' }, monthName),
      ),
    );
    screen.appendChild(header);

    const content = el('div', { class: 'content' });

    // Week nav
    const weekDone = schedule.filter(d => d.type === 'training' && d.completed).length;
    const weekTotal = schedule.filter(d => d.type === 'training').length;
    const weekNav = el('div', { class: 'week-nav' },
      el('div', {},
        el('div', { class: 'week-nav-title' }, 'This Week'),
        el('div', { style: 'font-size: 12px; color: var(--text-secondary); margin-top: 2px;' },
          `${weekDone} of ${weekTotal} completed`),
      ),
      el('div', { style: 'font-size: 22px; font-weight: 700; color: var(--accent);' },
        `${weekTotal ? Math.round((weekDone / weekTotal) * 100) : 0}%`),
    );
    content.appendChild(weekNav);

    // Day list
    content.appendChild(el('div', { class: 'section-header' },
      el('div', { class: 'section-title' }, 'Schedule'),
    ));

    const dayList = el('div', { class: 'day-list' });
    schedule.forEach(day => {
      const isToday = day.day === todayKey;
      const row = el('div', {
        class: `day-row ${isToday ? 'today' : ''} ${day.type === 'rest' ? 'rest' : ''}`,
      });

      const date = this.getNextDate(day.day);
      row.appendChild(el('div', { class: 'day-name' },
        day.dayName,
        el('span', { class: 'day-date' }, date),
      ));

      if (day.type === 'training') {
        row.appendChild(el('div', { class: 'day-content' },
          el('div', { class: 'day-title' }, day.workout?.title || 'Training'),
          el('div', { class: 'day-meta' },
            `${day.workout?.exercises?.length || 0} exercises • ${fmtMinutes(day.duration || day.workout?.duration || 0)}`),
        ));
        const badgeClass = day.completed ? 'complete' : day.missed ? 'missed' : '';
        const badgeText = day.completed ? 'Done' : day.missed ? 'Missed' : isToday ? 'Today' : 'Scheduled';
        row.appendChild(el('div', { class: `day-badge ${badgeClass}` }, badgeText));
      } else {
        row.appendChild(el('div', { class: 'day-content' },
          el('div', { class: 'day-title', style: 'color: var(--text-secondary);' }, 'Rest day'),
          el('div', { class: 'day-meta' }, 'Recovery'),
        ));
        row.appendChild(el('div', { class: 'day-badge rest' }, 'Rest'));
      }

      dayList.appendChild(row);
    });
    content.appendChild(dayList);

    // Reschedule action
    const missed = schedule.find(d => d.missed);
    if (missed) {
      content.appendChild(el('button', {
        class: 'btn btn-secondary',
        onclick: () => this.showReschedule(missed, schedule),
      },
        el('span', { html: icon('chevronRight') }),
        `Reschedule ${missed.dayName}'s session`,
      ));
    }

    // Stats card
    const statsCard = el('div', { class: 'card' });
    statsCard.appendChild(el('div', { style: 'font-weight: 600; margin-bottom: 14px;' }, 'Month Overview'));
    const monthStats = el('div', { style: 'display: grid; grid-template-columns: 1fr 1fr; gap: 16px;' });
    monthStats.appendChild(el('div', {},
      el('div', { style: 'font-size: 22px; font-weight: 700;' }, `${state.workoutsCompleted}`),
      el('div', { style: 'font-size: 12px; color: var(--text-secondary); margin-top: 2px;' }, 'Workouts completed'),
    ));
    monthStats.appendChild(el('div', {},
      el('div', { style: 'font-size: 22px; font-weight: 700;' }, fmtMinutes(state.totalTrainingMinutes)),
      el('div', { style: 'font-size: 12px; color: var(--text-secondary); margin-top: 2px;' }, 'Total training time'),
    ));
    statsCard.appendChild(monthStats);
    content.appendChild(statsCard);

    screen.appendChild(content);
    container.appendChild(screen);
  }

  getNextDate(dayKey) {
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    const today = new Date();
    const todayIdx = today.getDay();
    const targetIdx = days.indexOf(dayKey);
    let diff = targetIdx - todayIdx;
    if (diff < 0) diff += 7;
    const next = new Date(today);
    next.setDate(today.getDate() + diff);
    return next.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
  }

  showReschedule(missedDay, schedule) {
    const restDays = schedule.filter(d => d.type === 'rest' && d.day !== missedDay.day);
    if (restDays.length === 0) {
      toast('No rest days to reschedule to');
      return;
    }

    const modal = el('div', { class: 'modal' });
    const content = el('div', { class: 'modal-content' },
      el('div', { class: 'modal-handle' }),
      el('div', { style: 'font-size: 18px; font-weight: 700;' }, 'Reschedule Session'),
      el('div', { style: 'font-size: 14px; color: var(--text-secondary); margin-top: 4px;' },
        `Move "${missedDay.workout.title}" to which day?`),
      el('div', { style: 'display: flex; flex-direction: column; gap: 8px; margin-top: 16px;' }),
    );

    const optionsContainer = content.lastChild;
    restDays.forEach(day => {
      optionsContainer.appendChild(el('button', {
        class: 'option',
        onclick: () => {
          store.rescheduleDay(missedDay.day, day.day);
          modal.remove();
          this.render(container.parentNode);
          toast('Session rescheduled');
        },
      },
        el('div', { class: 'option-content' },
          el('div', { class: 'option-title' }, day.dayName),
          el('div', { class: 'option-subtitle' }, this.getNextDate(day.day)),
        ),
        el('span', { html: icon('chevronRight'), style: 'color: var(--text-tertiary);' }),
      ));
    });

    optionsContainer.appendChild(el('button', {
      class: 'btn btn-ghost',
      onclick: () => modal.remove(),
    }, 'Cancel'));

    modal.appendChild(content);
    modal.addEventListener('click', (e) => {
      if (e.target === modal) modal.remove();
    });
    document.body.appendChild(modal);
  }
}
