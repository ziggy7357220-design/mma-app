// ============================================================
// LEARN SCREEN
// ============================================================

import { el, icon, toast } from '../ui.js';
import { MARTIAL_ARTS, TECHNIQUES } from '../data/content.js';
import { store } from '../state.js';

export class LearnScreen {
  constructor() {
    this.view = 'arts'; // 'arts' | 'art' | 'technique'
    this.selectedArt = null;
    this.selectedTechnique = null;
    this.searchQuery = '';
  }

  render(container) {
    container.innerHTML = '';

    if (this.view === 'technique' && this.selectedTechnique) {
      this.renderTechnique(container);
      return;
    }
    if (this.view === 'art' && this.selectedArt) {
      this.renderArt(container);
      return;
    }

    this.renderArts(container);
  }

  renderArts(container) {
    const screen = el('div', { class: 'screen' });
    const header = el('div', { class: 'screen-header' },
      el('div', {},
        el('div', { class: 'screen-title' }, 'Learn'),
        el('div', { class: 'screen-subtitle' }, 'Build your martial arts knowledge'),
      ),
    );
    screen.appendChild(header);

    const content = el('div', { class: 'content' });

    // Search bar
    const searchBar = el('div', { class: 'search-bar' },
      el('span', { class: 'search-icon', html: icon('search') }),
      el('input', {
        placeholder: 'Search techniques...',
        value: this.searchQuery,
        oninput: (e) => {
          this.searchQuery = e.target.value;
          this.filterGrid();
        },
      }),
    );
    content.appendChild(searchBar);

    // Martial arts grid
    content.appendChild(el('div', { class: 'section-title' }, 'Martial Arts'));
    const grid = el('div', { class: 'martial-grid' });

    MARTIAL_ARTS.forEach(art => {
      const count = (TECHNIQUES[art.id] || []).length;
      grid.appendChild(el('button', {
        class: 'martial-card',
        onclick: () => {
          this.selectedArt = art.id;
          this.view = 'art';
          this.render(container);
        },
      },
        el('div', { class: 'martial-card-icon' }, art.icon),
        el('div', {},
          el('div', { class: 'martial-card-name' }, art.name),
          el('div', { class: 'martial-card-count' }, `${count} techniques`),
        ),
      ));
    });
    content.appendChild(grid);
    content.id = 'learn-grid';

    screen.appendChild(content);
    container.appendChild(screen);
  }

  filterGrid() {
    // Simple: re-render arts filtered by query (name match)
    const grid = document.getElementById('learn-grid');
    if (!grid) return;
    const filtered = MARTIAL_ARTS.filter(a =>
      a.name.toLowerCase().includes(this.searchQuery.toLowerCase())
    );
    const newGrid = el('div', { class: 'martial-grid' });
    filtered.forEach(art => {
      const count = (TECHNIQUES[art.id] || []).length;
      newGrid.appendChild(el('button', {
        class: 'martial-card',
        onclick: () => {
          this.selectedArt = art.id;
          this.view = 'art';
          this.render(document.querySelector('#app > main') || document.getElementById('app'));
        },
      },
        el('div', { class: 'martial-card-icon' }, art.icon),
        el('div', {},
          el('div', { class: 'martial-card-name' }, art.name),
          el('div', { class: 'martial-card-count' }, `${count} techniques`),
        ),
      ));
    });
    grid.replaceWith(newGrid);
    newGrid.id = 'learn-grid';
  }

  renderArt(container) {
    const art = MARTIAL_ARTS.find(a => a.id === this.selectedArt);
    const techniques = TECHNIQUES[this.selectedArt] || [];

    const screen = el('div', { class: 'screen' });
    const header = el('div', { class: 'screen-header' },
      el('button', {
        style: 'width: 36px; height: 36px; display: flex; align-items: center; justify-content: center;',
        onclick: () => { this.view = 'arts'; this.selectedArt = null; this.render(container); },
        html: icon('chevronLeft'),
      }),
      el('div', {},
        el('div', { class: 'screen-title' }, art.name),
        el('div', { class: 'screen-subtitle' }, `${techniques.length} techniques available`),
      ),
    );
    screen.appendChild(header);

    const content = el('div', { class: 'content' });

    if (techniques.length === 0) {
      content.appendChild(el('div', { class: 'empty' },
        el('div', { class: 'empty-icon' }, art.icon),
        el('div', { class: 'empty-title' }, 'Coming soon'),
        el('div', { class: 'empty-desc' }, 'Technique library for this art is being developed.'),
      ));
    } else {
      // Group by category
      const byCategory = {};
      techniques.forEach(t => {
        if (!byCategory[t.category]) byCategory[t.category] = [];
        byCategory[t.category].push(t);
      });

      const learned = store.get().learnedTechniques || [];
      Object.entries(byCategory).forEach(([category, items]) => {
        content.appendChild(el('div', { class: 'section-title' }, category));
        items.forEach(t => {
          const isLearned = learned.includes(t.id);
          content.appendChild(el('button', {
            class: 'train-tile',
            onclick: () => {
              this.selectedTechnique = t;
              this.view = 'technique';
              this.render(container);
            },
          },
            el('div', { class: 'train-tile-icon', html: icon(isLearned ? 'check' : 'video') }),
            el('div', { style: 'display: flex; justify-content: space-between; align-items: center;' },
              el('div', {},
                el('div', { class: 'train-tile-title' }, t.name),
                el('div', { class: 'train-tile-desc' }, `${t.duration} min • ${t.steps.length} steps`),
              ),
              isLearned ? el('span', {
                style: 'font-size: 11px; color: var(--success); font-weight: 600;',
              }, '✓ LEARNED') : null,
            ),
          ));
        });
      });
    }

    screen.appendChild(content);
    container.appendChild(screen);
  }

  renderTechnique(container) {
    const t = this.selectedTechnique;
    const learned = store.get().learnedTechniques || [];
    const isLearned = learned.includes(t.id);

    const screen = el('div', { class: 'screen' });
    const header = el('div', { class: 'screen-header' },
      el('button', {
        style: 'width: 36px; height: 36px; display: flex; align-items: center; justify-content: center;',
        onclick: () => { this.selectedTechnique = null; this.view = 'art'; this.render(container); },
        html: icon('chevronLeft'),
      }),
      el('div', {},
        el('div', { class: 'screen-title', style: 'font-size: 22px;' }, t.name),
        el('div', { class: 'screen-subtitle' }, t.category),
      ),
    );
    screen.appendChild(header);

    const content = el('div', { class: 'content' });

    // Video placeholder
    const video = el('div', { class: 'video-placeholder' },
      el('div', { class: 'play-icon', html: icon('play', 28) }),
    );
    content.appendChild(video);

    // Description
    content.appendChild(el('div', { style: 'font-size: 15px; line-height: 1.6; color: var(--text-secondary);' },
      t.description));

    // Steps
    content.appendChild(el('div', { class: 'section-title', style: 'margin-top: 8px;' }, 'How to do it'));
    const steps = el('div', { class: 'steps' });
    t.steps.forEach((step, i) => {
      steps.appendChild(el('div', { class: 'step' },
        el('div', { class: 'step-num' }, String(i + 1)),
        el('div', { class: 'step-text' }, step),
      ));
    });
    content.appendChild(steps);

    // Common mistakes
    if (t.mistakes && t.mistakes.length > 0) {
      content.appendChild(el('div', { class: 'section-title', style: 'margin-top: 8px;' }, 'Common mistakes'));
      const mistakes = el('div', { style: 'display: flex; flex-direction: column; gap: 8px;' });
      t.mistakes.forEach(m => {
        mistakes.appendChild(el('div', { style: 'font-size: 13px; color: var(--text-secondary); padding-left: 14px; border-left: 2px solid var(--danger);' },
          m));
      });
      content.appendChild(mistakes);
    }

    // Mark as learned button
    content.appendChild(el('button', {
      class: isLearned ? 'btn btn-secondary' : 'btn btn-primary',
      onclick: () => {
        if (isLearned) {
          toast('Already learned');
          return;
        }
        store.markTechniqueLearned(t.id, this.selectedArt);
        toast(`+10 XP — ${t.name} learned`);
        this.render(container);
      },
    },
      isLearned ? '✓ Learned' : 'Mark as Learned (+10 XP)',
    ));

    screen.appendChild(content);
    container.appendChild(screen);
  }
}
