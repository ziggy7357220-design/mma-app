// ============================================================
// COMBO CREATOR — Build and save custom strike sequences
// ============================================================

import { el, icon, toast } from './ui.js';
import { STRIKES } from './data/content.js';
import { store } from './state.js';

export class ComboCreator {
  mount(container) {
    this.container = container;
    this.strikes = [];
    this.render();
  }

  render() {
    this.container.innerHTML = '';
    const screen = el('div', { class: 'screen' });

    // Header
    const header = el('div', { class: 'screen-header' },
      el('div', {},
        el('div', { class: 'screen-title' }, 'Combo Creator'),
        el('div', { class: 'screen-subtitle' }, 'Build your custom sequences'),
      ),
    );
    screen.appendChild(header);

    const content = el('div', { class: 'content' });

    // Current combo strip
    const strip = el('div', {
      class: `combo-strip ${this.strikes.length === 0 ? 'empty' : ''}`,
    });
    if (this.strikes.length === 0) {
      strip.appendChild(el('div', { class: 'empty-desc' }, 'Tap strikes below to build a combo'));
    } else {
      this.strikes.forEach((strike, i) => {
        strip.appendChild(el('div', { class: 'combo-chip' },
          el('span', { class: 'combo-chip-num' }, `${i + 1}.`),
          strike,
        ));
      });
    }
    content.appendChild(strip);

    // Clear button
    if (this.strikes.length > 0) {
      const btnRow = el('div', { style: 'display: flex; gap: 8px;' });
      btnRow.appendChild(el('button', {
        class: 'btn btn-ghost',
        onclick: () => { this.strikes = []; this.render(); },
      }, 'Clear'));
      btnRow.appendChild(el('button', {
        class: 'btn btn-primary',
        onclick: () => this.save(),
      },
        el('span', { html: icon('save') }),
        'Save Combo',
      ));
      content.appendChild(btnRow);
    }

    // Strike palette
    content.appendChild(el('div', { class: 'section-title', style: 'margin-top: 8px;' }, 'Add strikes'));
    const palette = el('div', { class: 'combo-palette' });
    STRIKES.forEach(strike => {
      palette.appendChild(el('button', {
        class: 'combo-strike',
        onclick: () => {
          this.strikes.push(strike);
          this.render();
        },
      }, `+ ${strike}`));
    });
    content.appendChild(palette);

    // Saved combos
    const combos = store.get().combos || [];
    if (combos.length > 0) {
      content.appendChild(el('div', { class: 'section-title', style: 'margin-top: 16px;' }, 'Saved combos'));
      const list = el('div', { style: 'display: flex; flex-direction: column; gap: 8px;' });
      combos.forEach(combo => {
        const item = el('div', { class: 'card' },
          el('div', { style: 'display: flex; justify-content: space-between; align-items: center;' },
            el('div', {},
              el('div', { style: 'font-weight: 600;' }, combo.name),
              el('div', { style: 'font-size: 12px; color: var(--text-secondary); margin-top: 4px;' },
                combo.strikes.join(' — '),
              ),
            ),
            el('button', {
              class: 'btn btn-ghost',
              style: 'width: auto; padding: 8px 12px;',
              onclick: () => {
                if (confirm(`Delete "${combo.name}"?`)) {
                  store.removeCombo(combo.id);
                  this.render();
                }
              },
              html: icon('trash'),
            }),
          ),
        );
        list.appendChild(item);
      });
      content.appendChild(list);
    }

    screen.appendChild(content);
    this.container.appendChild(screen);
  }

  save() {
    if (this.strikes.length === 0) {
      toast('Add at least one strike first');
      return;
    }
    const name = prompt('Name this combo:', `Combo ${(store.get().combos || []).length + 1}`);
    if (!name) return;
    store.saveCombo(name, this.strikes);
    toast('Combo saved');
    this.strikes = [];
    this.render();
  }
}
