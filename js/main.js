// ============================================================
// MAIN APP — Shell, routing, navigation
// ============================================================

import { el, icon } from './ui.js';
import { store } from './state.js';
import { Onboarding } from './onboarding.js';
import { HomeScreen } from './screens/home.js';
import { PlanScreen } from './screens/plan.js';
import { TrainScreen } from './screens/train.js';
import { LearnScreen } from './screens/learn.js';
import { ProfileScreen } from './screens/profile.js';
import { WorkoutPlayer } from './player.js';
import { WORKOUTS, ACHIEVEMENTS } from './data/content.js';

// Expose for state.js to access
window.STANCE_DATA = { WORKOUTS, ACHIEVEMENTS };

const NAV_ITEMS = [
  { id: 'home', label: 'Home', icon: 'home' },
  { id: 'plan', label: 'Plan', icon: 'plan' },
  { id: 'train', label: 'Train', icon: 'train' },
  { id: 'learn', label: 'Learn', icon: 'learn' },
  { id: 'profile', label: 'Profile', icon: 'profile' },
];

class App {
  constructor(root) {
    this.root = root;
    this.currentTab = 'home';
    this.player = null;

    this.screens = {
      home: new HomeScreen(
        (workout) => this.startWorkout(workout),
        (tab) => this.navigate(tab),
      ),
      plan: new PlanScreen(),
      train: new TrainScreen((workout) => this.startWorkout(workout)),
      learn: new LearnScreen(),
      profile: new ProfileScreen(),
    };

    this.unsub = store.subscribe(() => this.rerender());
  }

  init() {
    this.render();
  }

  render() {
    this.root.innerHTML = '';
    if (!store.get().onboarded) {
      this.renderOnboarding();
      return;
    }
    this.renderShell();
  }

  rerender() {
    // Don't re-render during a workout session
    if (this.player) return;
    if (!store.get().onboarded) return;
    this.renderShell();
  }

  renderOnboarding() {
    const onComplete = (profile, schedule) => {
      store.completeOnboarding(profile, schedule);
    };
    const onboarding = new Onboarding(onComplete);
    onboarding.mount(this.root);
  }

  renderShell() {
    this.root.innerHTML = '';

    // Main content area
    const main = el('main', {
      style: 'flex: 1; overflow-y: auto; -webkit-overflow-scrolling: touch;',
    });
    this.screens[this.currentTab].render(main);
    this.root.appendChild(main);

    // Bottom navigation
    const nav = el('nav', { class: 'bottom-nav' });
    NAV_ITEMS.forEach(item => {
      const navBtn = el('button', {
        class: `nav-item ${item.id === this.currentTab ? 'active' : ''}`,
        onclick: () => this.navigate(item.id),
      },
        el('span', { html: icon(item.icon) }),
        el('span', {}, item.label),
      );
      nav.appendChild(navBtn);
    });
    this.root.appendChild(nav);
  }

  navigate(tab) {
    this.currentTab = tab;
    this.renderShell();
  }

  startWorkout(workout) {
    // Hide nav, mount player
    this.root.innerHTML = '';
    const playerContainer = el('div', { style: 'flex: 1; position: relative;' });
    this.root.appendChild(playerContainer);

    this.player = new WorkoutPlayer(workout, (result) => {
      if (result?.completed) {
        // Player shows completion screen itself
        setTimeout(() => {
          this.player = null;
          this.render();
        }, 3000);
      }
    });
    this.player.mount(playerContainer);
  }
}

// Boot
const root = document.getElementById('app');
const app = new App(root);
app.init();
