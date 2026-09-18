// ============================================================
// UI HELPERS — Icons, toasts, modals
// ============================================================

export function icon(name, size = 24) {
  const icons = {
    home: '<svg class="nav-icon" viewBox="0 0 24 24" stroke="currentColor"><path d="M3 12l9-9 9 9M5 10v10h5v-6h4v6h5V10"/></svg>',
    plan: '<svg class="nav-icon" viewBox="0 0 24 24" stroke="currentColor"><rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4M8 2v4M3 10h18"/></svg>',
    train: '<svg class="nav-icon" viewBox="0 0 24 24" stroke="currentColor"><path d="M14.7 6.3a1 1 0 000 1.4l1.6 1.6a1 1 0 001.4 0l3.77-3.77a6 6 0 01-7.94 7.94l-6.91 6.91a2.12 2.12 0 01-3-3l6.91-6.91a6 6 0 017.94-7.94l-3.76 3.76z"/></svg>',
    learn: '<svg class="nav-icon" viewBox="0 0 24 24" stroke="currentColor"><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2zM22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg>',
    profile: '<svg class="nav-icon" viewBox="0 0 24 24" stroke="currentColor"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2M12 11a4 4 0 100-8 4 4 0 000 8z"/></svg>',
    search: '<svg width="18" height="18" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/></svg>',
    play: '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><polygon points="5 3 19 12 5 21 5 3"/></svg>',
    pause: '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/></svg>',
    chevronRight: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><path d="M9 18l6-6-6-6"/></svg>',
    chevronLeft: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><path d="M15 18l-6-6 6-6"/></svg>',
    chevronDown: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><path d="M6 9l6 6 6-6"/></svg>',
    close: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>',
    check: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><path d="M20 6L9 17l-5-5"/></svg>',
    flame: '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2C8 6 8 10 8 13a4 4 0 008 0c0-1.5-.5-3-2-4 0 2-1 3-2 3 0-3 1-7 0-10z" stroke="currentColor" fill="none" stroke-width="1.5"/></svg>',
    clock: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>',
    trophy: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><path d="M6 9V3h12v6a6 6 0 11-12 0zM8 21h8M12 17v4M4 9H2a3 3 0 003 3M22 9h-2a3 3 0 01-3 3"/></svg>',
    timer: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><circle cx="12" cy="13" r="8"/><path d="M12 9v4l2 2M9 2h6"/></svg>',
    list: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01"/></svg>',
    layers: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><polygon points="12 2 2 7 12 12 22 7 12 2"/><polyline points="2 17 12 22 22 17"/><polyline points="2 12 12 17 22 12"/></svg>',
    zap: '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>',
    settings: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83 0 2 2 0 010-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 010-2.83 2 2 0 012.83 0l.06.06a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 0 2 2 0 010 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg>',
    plus: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg>',
    trash: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><path d="M3 6h18M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6M8 6V4a2 2 0 012-2h4a2 2 0 012 2v2M10 11v6M14 11v6"/></svg>',
    save: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v11a2 2 0 01-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>',
    trend: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>',
    grid: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>',
    video: '<svg width="20" height="20" viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2"><polygon points="23 7 16 12 23 17 23 7"/><rect x="1" y="5" width="15" height="14" rx="2"/></svg>',
  };
  return icons[name] || '';
}

export function toast(message, duration = 2000) {
  const existing = document.querySelector('.toast');
  if (existing) existing.remove();
  const el = document.createElement('div');
  el.className = 'toast';
  el.textContent = message;
  document.body.appendChild(el);
  setTimeout(() => el.remove(), duration);
}

export function el(tag, attrs = {}, ...children) {
  const node = document.createElement(tag);
  for (const [key, value] of Object.entries(attrs || {})) {
    if (key === 'class') node.className = value;
    else if (key === 'style') node.style.cssText = value;
    else if (key.startsWith('on') && typeof value === 'function') {
      node.addEventListener(key.substring(2).toLowerCase(), value);
    } else if (key === 'html') {
      node.innerHTML = value;
    } else if (value !== false && value !== null && value !== undefined) {
      node.setAttribute(key, value);
    }
  }
  for (const child of children.flat()) {
    if (child === null || child === undefined || child === false) continue;
    if (typeof child === 'string' || typeof child === 'number') {
      node.appendChild(document.createTextNode(String(child)));
    } else {
      node.appendChild(child);
    }
  }
  return node;
}

export function clearNode(node) {
  while (node.firstChild) node.removeChild(node.firstChild);
}

export function fmtMinutes(min) {
  if (min < 60) return `${Math.round(min)}m`;
  const h = Math.floor(min / 60);
  const m = Math.round(min % 60);
  return m ? `${h}h ${m}m` : `${h}h`;
}

export function fmtDate(date) {
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' });
}

export function fmtTime(date) {
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' });
}
