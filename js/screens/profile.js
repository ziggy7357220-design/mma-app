// ============================================================
// PROFILE SCREEN
// ============================================================

import { el, icon, fmtMinutes, toast } from '../ui.js';
import { store } from '../state.js';
import { ACHIEVEMENTS } from '../data/content.js';

export class ProfileScreen {
  constructor() {}

  render(container) {
    container.innerHTML = '';
    const screen = el('div', { class: 'screen' });

    const state = store.get();
    const xpForNext = state.xp % 100;
    const xpProgress = xpForNext;

    // Profile header
    const profileHeader = el('div', { class: 'profile-header' },
      el('div', { class: 'profile-avatar' }, this.getInitial(state.profile.name)),
      el('div', { class: 'profile-info' },
        el('div', { class: 'profile-name' }, state.profile.name || 'Athlete'),
        el('div', { class: 'profile-level' }, `Level ${state.level}`),
        el('div', { class: 'xp-bar' },
          el('div', { class: 'xp-bar-fill', style: `width: ${xpProgress}%` }),
        ),
        el('div', { class: 'xp-label' }, `${xpForNext} / 100 XP to Level ${state.level + 1}`),
      ),
    );
    screen.appendChild(profileHeader);

    const content = el('div', { class: 'content' });

    // Stats grid
    const statsGrid = el('div', { class: 'stats-grid' });
    statsGrid.appendChild(el('div', { class: 'stat-tile' },
      el('div', { class: 'stat-tile-label' }, 'Total XP'),
      el('div', { class: 'stat-tile-value' }, `${state.xp}`),
      el('div', { class: 'stat-tile-sub' }, `Level ${state.level}`),
    ));
    statsGrid.appendChild(el('div', { class: 'stat-tile' },
      el('div', { class: 'stat-tile-label' }, 'Streak'),
      el('div', { class: 'stat-tile-value' }, `${state.currentStreak} 🔥`),
      el('div', { class: 'stat-tile-sub' }, `Best: ${state.longestStreak} days`),
    ));
    statsGrid.appendChild(el('div', { class: 'stat-tile' },
      el('div', { class: 'stat-tile-label' }, 'Workouts'),
      el('div', { class: 'stat-tile-value' }, `${state.workoutsCompleted}`),
      el('div', { class: 'stat-tile-sub' }, 'Completed'),
    ));
    statsGrid.appendChild(el('div', { class: 'stat-tile' },
      el('div', { class: 'stat-tile-label' }, 'Time'),
      el('div', { class: 'stat-tile-value' }, fmtMinutes(state.totalTrainingMinutes)),
      el('div', { class: 'stat-tile-sub' }, 'Total training'),
    ));
    content.appendChild(statsGrid);

    // Skill progress
    content.appendChild(el('div', { class: 'section-header', style: 'margin-top: 8px;' },
      el('div', { class: 'section-title' }, 'Skill Progress'),
    ));

    const skillCard = el('div', { class: 'card' });
    const skillProgress = state.skillProgress || {};
    const allSkills = {};
    Object.values(skillProgress).forEach(artSkills => {
      Object.entries(artSkills).forEach(([k, v]) => {
        allSkills[k] = v;
      });
    });
    const skillEntries = Object.entries(allSkills).slice(0, 6);
    if (skillEntries.length === 0) {
      skillCard.appendChild(el('div', { style: 'font-size: 13px; color: var(--text-secondary);' },
        'Complete workouts to see your skills grow.'));
    } else {
      skillEntries.forEach(([name, value]) => {
        const display = name.charAt(0).toUpperCase() + name.slice(1).replace(/_/g, ' ');
        skillCard.appendChild(el('div', { class: 'skill-bar' },
          el('div', { class: 'skill-name' }, display),
          el('div', { class: 'skill-track' },
            el('div', { class: 'skill-fill', style: `width: ${value}%` }),
          ),
          el('div', { class: 'skill-pct' }, `${value}%`),
        ));
      });
    }
    content.appendChild(skillCard);

    // Achievements
    content.appendChild(el('div', { class: 'section-header', style: 'margin-top: 8px;' },
      el('div', { class: 'section-title' }, 'Achievements'),
      el('div', { style: 'font-size: 12px; color: var(--text-secondary);' },
        `${(state.unlockedAchievements || []).length} / ${ACHIEVEMENTS.length}`),
    ));

    const achList = el('div', { style: 'display: flex; flex-direction: column; gap: 8px;' });
    ACHIEVEMENTS.forEach(ach => {
      const unlocked = (state.unlockedAchievements || []).includes(ach.id);
      achList.appendChild(el('div', { class: `achievement ${unlocked ? '' : 'locked'}` },
        el('div', { class: 'achievement-icon' }, unlocked ? ach.icon : '🔒'),
        el('div', { style: 'flex: 1;' },
          el('div', { class: 'achievement-name' }, ach.name),
          el('div', { class: 'achievement-desc' }, ach.desc),
        ),
        unlocked ? el('div', { style: 'font-size: 12px; color: var(--accent); font-weight: 600;' },
          `+${ach.xp} XP`) : null,
      ));
    });
    content.appendChild(achList);

    // Settings
    content.appendChild(el('div', { class: 'section-header', style: 'margin-top: 8px;' },
      el('div', { class: 'section-title' }, 'Settings'),
    ));

    const list = el('div', { class: 'list' });
    list.appendChild(el('button', {
      class: 'list-item',
      onclick: () => this.editProfile(container),
    },
      el('div', { class: 'list-item-icon', html: icon('settings') }),
      el('div', { class: 'list-item-content' },
        el('div', { class: 'list-item-title' }, 'Edit profile'),
        el('div', { class: 'list-item-sub' }, 'Goals, equipment, training days'),
      ),
      el('span', { class: 'list-item-arrow', html: icon('chevronRight') }),
    ));
    list.appendChild(el('button', {
      class: 'list-item',
      onclick: () => this.regeneratePlan(container),
    },
      el('div', { class: 'list-item-icon', html: icon('trend') }),
      el('div', { class: 'list-item-content' },
        el('div', { class: 'list-item-title' }, 'Regenerate plan'),
        el('div', { class: 'list-item-sub' }, 'Rebuild your weekly schedule'),
      ),
      el('span', { class: 'list-item-arrow', html: icon('chevronRight') }),
    ));
    list.appendChild(el('button', {
      class: 'list-item',
      onclick: () => this.resetData(container),
    },
      el('div', { class: 'list-item-icon', html: icon('trash') }),
      el('div', { class: 'list-item-content' },
        el('div', { class: 'list-item-title' }, 'Reset all data'),
        el('div', { class: 'list-item-sub' }, 'Erase progress and start over'),
      ),
      el('span', { class: 'list-item-arrow', html: icon('chevronRight') }),
    ));
    content.appendChild(list);

    screen.appendChild(content);
    container.appendChild(screen);
  }

  getInitial(name) {
    return (name || 'A').charAt(0).toUpperCase();
  }

  editProfile(container) {
    const state = store.get();
    const newName = prompt('Your name:', state.profile.name || 'Athlete');
    if (newName && newName.trim()) {
      store.patchProfile({ name: newName.trim() });
      toast('Profile updated');
      this.render(container);
    }
  }

  regeneratePlan(container) {
    if (!confirm('Regenerate your weekly training plan?')) return;
    store.regeneratePlan(store.get().profile);
    toast('Plan regenerated');
    setTimeout(() => this.render(container), 100);
  }

  resetData(container) {
    if (!confirm('This will erase ALL your progress. Continue?')) return;
    if (!confirm('Are you absolutely sure?')) return;
    store.reset();
    window.location.reload();
  }
}
