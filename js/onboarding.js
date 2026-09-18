// ============================================================
// ONBOARDING — 7-step flow
// ============================================================

import { el, icon } from './ui.js';
import { MARTIAL_ARTS } from './data/content.js';
import { generateWeeklyPlan } from './data/plan.js';

const STEPS = [
  'martialArts',
  'level',
  'goals',
  'sessionTime',
  'trainingDays',
  'availableDays',
  'equipment',
];

const LEVELS = [
  { id: 'beginner', title: 'Beginner', subtitle: 'Less than 1 year of training' },
  { id: 'intermediate', title: 'Intermediate', subtitle: '1–3 years of training' },
  { id: 'advanced', title: 'Advanced', subtitle: '3+ years, competition experience' },
];

const GOALS = [
  { id: 'fundamentals', title: 'Learn fundamentals', subtitle: 'Build a solid base' },
  { id: 'technique', title: 'Improve technique', subtitle: 'Refine my strikes / movements' },
  { id: 'footwork', title: 'Improve footwork', subtitle: 'Movement and positioning' },
  { id: 'speed', title: 'Improve speed', subtitle: 'Faster reactions and combinations' },
  { id: 'strength', title: 'Improve strength', subtitle: 'Build power and force' },
  { id: 'conditioning', title: 'Improve conditioning', subtitle: 'Cardio and endurance' },
  { id: 'coordination', title: 'Improve coordination', subtitle: 'Timing and balance' },
  { id: 'mobility', title: 'Improve mobility', subtitle: 'Flexibility and range of motion' },
  { id: 'consistency', title: 'Improve consistency', subtitle: 'Stick to my training plan' },
  { id: 'competition', title: 'Competition preparation', subtitle: 'Get fight ready' },
];

const DURATIONS = [
  { id: 10, title: '10 min', subtitle: 'Quick sessions' },
  { id: 20, title: '20 min', subtitle: 'Short focused training' },
  { id: 30, title: '30 min', subtitle: 'Standard session' },
  { id: 45, title: '45 min', subtitle: 'Deep practice' },
  { id: 60, title: '60+ min', subtitle: 'Extended training' },
];

const DAYS_PER_WEEK = [
  { id: 2, title: '2 days / week' },
  { id: 3, title: '3 days / week' },
  { id: 4, title: '4 days / week' },
  { id: 5, title: '5 days / week' },
  { id: 6, title: '6 days / week' },
];

const WEEKDAYS = [
  { id: 'monday', name: 'Monday', short: 'Mon' },
  { id: 'tuesday', name: 'Tuesday', short: 'Tue' },
  { id: 'wednesday', name: 'Wednesday', short: 'Wed' },
  { id: 'thursday', name: 'Thursday', short: 'Thu' },
  { id: 'friday', name: 'Friday', short: 'Fri' },
  { id: 'saturday', name: 'Saturday', short: 'Sat' },
  { id: 'sunday', name: 'Sunday', short: 'Sun' },
];

const EQUIPMENT = [
  { id: 'none', title: 'No equipment', subtitle: 'Bodyweight only' },
  { id: 'gloves', title: 'Gloves', subtitle: 'Hand protection' },
  { id: 'heavy_bag', title: 'Heavy bag', subtitle: 'For striking practice' },
  { id: 'jump_rope', title: 'Jump rope', subtitle: 'Cardio and footwork' },
  { id: 'pads', title: 'Pads', subtitle: 'Focus mitts / Thai pads' },
  { id: 'bands', title: 'Resistance bands', subtitle: 'Strength and mobility' },
  { id: 'weights', title: 'Weights', subtitle: 'Dumbbells / barbell' },
  { id: 'full_gym', title: 'Full gym', subtitle: 'Complete facility access' },
];

export class Onboarding {
  constructor(onComplete) {
    this.step = 0;
    this.data = {
      martialArts: [],
      level: null,
      goals: [],
      sessionDuration: null,
      daysPerWeek: null,
      availableDays: [],
      equipment: [],
    };
    this.onComplete = onComplete;
  }

  mount(container) {
    this.container = container;
    this.render();
  }

  render() {
    this.container.innerHTML = '';
    const stepKey = STEPS[this.step];
    const stepNum = this.step + 1;
    const totalSteps = STEPS.length;

    const screen = el('div', { class: 'onboarding' });

    // Progress bar
    const progress = el('div', { class: 'onboarding-progress' });
    for (let i = 0; i < totalSteps; i++) {
      const cls = i < this.step ? 'done' : i === this.step ? 'active' : '';
      progress.appendChild(el('div', { class: `onboarding-progress-dot ${cls}` }));
    }
    screen.appendChild(progress);

    // Body
    const body = el('div', { class: 'onboarding-body' });

    body.appendChild(el('div', { class: 'onboarding-step-num' }, `Step ${stepNum} of ${totalSteps}`));
    body.appendChild(el('div', { class: 'onboarding-step-title' }, this.stepTitle(stepKey)));
    body.appendChild(el('div', { class: 'onboarding-step-desc' }, this.stepDesc(stepKey)));

    // Options
    body.appendChild(this.renderOptions(stepKey));

    screen.appendChild(body);

    // Footer
    const footer = el('div', { class: 'onboarding-footer' });
    if (this.step > 0) {
      footer.appendChild(el('button', {
        class: 'btn btn-ghost',
        onclick: () => { this.step--; this.render(); },
      }, 'Back'));
    } else {
      footer.appendChild(el('div', {}));
    }
    footer.appendChild(el('button', {
      class: 'btn btn-primary',
      onclick: () => this.handleNext(),
    }, this.step === totalSteps - 1 ? 'Generate Plan' : 'Continue'));
    screen.appendChild(footer);

    this.container.appendChild(screen);
  }

  stepTitle(step) {
    const titles = {
      martialArts: 'Choose your martial arts',
      level: 'How experienced are you?',
      goals: 'What are your goals?',
      sessionTime: 'How long do you want to train?',
      trainingDays: 'How many days per week?',
      availableDays: 'Which days work best?',
      equipment: 'What equipment do you have?',
    };
    return titles[step];
  }

  stepDesc(step) {
    const descs = {
      martialArts: 'Select all that apply. You can train across multiple arts.',
      level: 'Be honest — we\'ll match the difficulty to your level.',
      goals: 'Pick what you want to focus on. You can change this later.',
      sessionTime: 'We\'ll build workouts that fit this time.',
      trainingDays: 'A consistent schedule beats a packed one.',
      availableDays: 'Pick the days you can realistically train.',
      equipment: 'Workouts adapt to what you have.',
    };
    return descs[step];
  }

  renderOptions(step) {
    const container = el('div', { class: 'onboarding-options' });

    if (step === 'martialArts') {
      MARTIAL_ARTS.forEach(art => {
        const selected = this.data.martialArts.includes(art.id);
        const opt = el('button', {
          class: `option ${selected ? 'selected' : ''}`,
          onclick: () => {
            if (selected) {
              this.data.martialArts = this.data.martialArts.filter(id => id !== art.id);
            } else {
              this.data.martialArts = [...this.data.martialArts, art.id];
            }
            this.render();
          },
        },
          el('div', { class: 'option-content' },
            el('div', { class: 'option-title' }, `${art.icon} ${art.name}`),
          ),
          el('div', { class: 'option-check' }),
        );
        container.appendChild(opt);
      });
    }

    if (step === 'level') {
      LEVELS.forEach(level => {
        const selected = this.data.level === level.id;
        const opt = el('button', {
          class: `option ${selected ? 'selected' : ''}`,
          onclick: () => {
            this.data.level = level.id;
            this.render();
          },
        },
          el('div', { class: 'option-content' },
            el('div', { class: 'option-title' }, level.title),
            el('div', { class: 'option-subtitle' }, level.subtitle),
          ),
          el('div', { class: 'option-check' }),
        );
        container.appendChild(opt);
      });
    }

    if (step === 'goals') {
      GOALS.forEach(goal => {
        const selected = this.data.goals.includes(goal.id);
        const opt = el('button', {
          class: `option ${selected ? 'selected' : ''}`,
          onclick: () => {
            if (selected) {
              this.data.goals = this.data.goals.filter(id => id !== goal.id);
            } else {
              this.data.goals = [...this.data.goals, goal.id];
            }
            this.render();
          },
        },
          el('div', { class: 'option-content' },
            el('div', { class: 'option-title' }, goal.title),
            el('div', { class: 'option-subtitle' }, goal.subtitle),
          ),
          el('div', { class: 'option-check' }),
        );
        container.appendChild(opt);
      });
    }

    if (step === 'sessionTime') {
      DURATIONS.forEach(d => {
        const selected = this.data.sessionDuration === d.id;
        const opt = el('button', {
          class: `option ${selected ? 'selected' : ''}`,
          onclick: () => {
            this.data.sessionDuration = d.id;
            this.render();
          },
        },
          el('div', { class: 'option-content' },
            el('div', { class: 'option-title' }, d.title),
            el('div', { class: 'option-subtitle' }, d.subtitle),
          ),
          el('div', { class: 'option-check' }),
        );
        container.appendChild(opt);
      });
    }

    if (step === 'trainingDays') {
      DAYS_PER_WEEK.forEach(d => {
        const selected = this.data.daysPerWeek === d.id;
        const opt = el('button', {
          class: `option ${selected ? 'selected' : ''}`,
          onclick: () => {
            this.data.daysPerWeek = d.id;
            this.render();
          },
        },
          el('div', { class: 'option-content' },
            el('div', { class: 'option-title' }, d.title),
          ),
          el('div', { class: 'option-check' }),
        );
        container.appendChild(opt);
      });
    }

    if (step === 'availableDays') {
      WEEKDAYS.forEach(d => {
        const selected = this.data.availableDays.includes(d.id);
        const opt = el('button', {
          class: `option ${selected ? 'selected' : ''}`,
          onclick: () => {
            if (selected) {
              this.data.availableDays = this.data.availableDays.filter(id => id !== d.id);
            } else {
              this.data.availableDays = [...this.data.availableDays, d.id];
            }
            this.render();
          },
        },
          el('div', { class: 'option-content' },
            el('div', { class: 'option-title' }, d.name),
          ),
          el('div', { class: 'option-check' }),
        );
        container.appendChild(opt);
      });
      if (this.data.availableDays.length === 0) {
        container.appendChild(el('div', { class: 'empty' },
          el('div', { class: 'empty-desc' }, 'Select at least one day'),
        ));
      }
    }

    if (step === 'equipment') {
      EQUIPMENT.forEach(eq => {
        const selected = this.data.equipment.includes(eq.id);
        const opt = el('button', {
          class: `option ${selected ? 'selected' : ''}`,
          onclick: () => {
            if (eq.id === 'none') {
              this.data.equipment = selected ? [] : ['none'];
              this.render();
              return;
            }
            this.data.equipment = this.data.equipment.filter(id => id !== 'none');
            if (selected) {
              this.data.equipment = this.data.equipment.filter(id => id !== eq.id);
            } else {
              this.data.equipment = [...this.data.equipment, eq.id];
            }
            this.render();
          },
        },
          el('div', { class: 'option-content' },
            el('div', { class: 'option-title' }, eq.title),
            el('div', { class: 'option-subtitle' }, eq.subtitle),
          ),
          el('div', { class: 'option-check' }),
        );
        container.appendChild(opt);
      });
    }

    return container;
  }

  handleNext() {
    // Validation
    const stepKey = STEPS[this.step];
    if (stepKey === 'martialArts' && this.data.martialArts.length === 0) {
      return;
    }
    if (stepKey === 'level' && !this.data.level) return;
    if (stepKey === 'goals' && this.data.goals.length === 0) return;
    if (stepKey === 'sessionTime' && !this.data.sessionDuration) return;
    if (stepKey === 'trainingDays' && !this.data.daysPerWeek) return;
    if (stepKey === 'availableDays' && this.data.availableDays.length === 0) return;
    if (stepKey === 'equipment' && this.data.equipment.length === 0) return;

    if (this.step === STEPS.length - 1) {
      this.finish();
    } else {
      this.step++;
      this.render();
    }
  }

  finish() {
    const profile = {
      ...this.data,
      name: 'Athlete',
    };
    const schedule = generateWeeklyPlan(profile);
    this.onComplete(profile, schedule);
  }
}
