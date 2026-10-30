/* ==========================================================================
   Bored Academy — Icon set
   Hand-drawn inline SVG line icons (no external assets, no network fetch).
   Stroke-based, currentColor, matches the paper/teal editorial look.
   ========================================================================== */

const ICONS = {
  'graduation-cap': '<path d="M2 8l10-4 10 4-10 4-10-4z"/><path d="M6 10.2v4.8c0 1.5 3 3 6 3s6-1.5 6-3v-4.8"/><path d="M22 8v5.5"/>',
  'home': '<path d="M3 11l9-8 9 8"/><path d="M5 10v10h14V10"/><path d="M9.5 20v-6h5v6"/>',
  'book-open': '<path d="M12 6.5c-2-1.8-5-1.8-8-.9v13c3-.9 6-.9 8 .9 2-1.8 5-1.8 8-.9v-13c-3-.9-6-.9-8 .9z"/><path d="M12 6.5v13"/>',
  'trending-up': '<polyline points="3 17 9.5 10.5 13.5 14.5 21 6.5"/><polyline points="14.5 6.5 21 6.5 21 13"/>',
  'trophy': '<path d="M8 4h8v4.2a4 4 0 0 1-8 0V4z"/><path d="M8 5H5.5a2 2 0 0 0 2 3"/><path d="M16 5h2.5a2 2 0 0 1-2 3"/><path d="M10 13.2v2.8h4v-2.8"/><path d="M9 20h6"/><path d="M12 16v4"/>',
  'bookmark': '<path d="M6 3h12v18l-6-4.2L6 21V3z"/>',
  'calendar': '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 9.5h18"/><path d="M8 3v4"/><path d="M16 3v4"/>',
  'settings': '<circle cx="12" cy="12" r="3"/><path d="M12 2.5v3M12 18.5v3M3.8 6.3l2.2 2.1M18 15.6l2.2 2.1M2.5 12h3M18.5 12h3M3.8 17.7l2.2-2.1M18 8.4l2.2-2.1"/>',
  'menu': '<line x1="3" y1="6.5" x2="21" y2="6.5"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="17.5" x2="21" y2="17.5"/>',
  'search': '<circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.2" y2="16.2"/>',
  'bell': '<path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M10 21a2 2 0 0 0 4 0"/>',
  'user': '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>',
  'flame': '<path d="M12 2.2c1 3-2 3.8-2 6.8a4 4 0 1 0 8 0c0-.8-.5-1.6-1-2 .6 2.6-1 4.7-3 4.7-2.6 0-3.6-1.8-3.6-4.3 0-1.8.8-3 1.6-5.2z"/>',
  'target': '<circle cx="12" cy="12" r="8"/><circle cx="12" cy="12" r="4.3"/><circle cx="12" cy="12" r="1.1" fill="currentColor" stroke="none"/>',
  'sprout': '<path d="M5 14.5c0-3.8 3-5.8 7-5.8"/><path d="M12 8.7c4 0 7 2 7 5.8"/><path d="M12 8.7V21"/><path d="M12 8.7c-3 0-4-1.9-4-4 2 0 4 .9 4 4z"/>',
  'shield': '<path d="M12 3l7 3v6c0 5-3 8-7 9-4-1-7-4-7-9V6l7-3z"/><path d="M9 12l2 2 4-4"/>',
  'lock': '<rect x="5" y="10" width="14" height="11" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/><path d="M12 14v3"/>',
  'flask': '<path d="M9.3 3h5.4"/><path d="M10.2 3v6.2l-4.6 8.2A2 2 0 0 0 7.3 20.5h9.4a2 2 0 0 0 1.7-3.1l-4.6-8.2V3"/><path d="M8.1 15.2h7.8"/>',
  'droplet': '<path d="M12 3.2s6 7.4 6 11.3a6 6 0 0 1-12 0c0-3.9 6-11.3 6-11.3z"/>',
  'atom': '<circle cx="12" cy="12" r="1.4" fill="currentColor" stroke="none"/><ellipse cx="12" cy="12" rx="9" ry="3.8"/><ellipse cx="12" cy="12" rx="9" ry="3.8" transform="rotate(60 12 12)"/><ellipse cx="12" cy="12" rx="9" ry="3.8" transform="rotate(120 12 12)"/>',
  'pencil': '<path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4 12.5-12.5z"/>',
  'sun': '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"/>',
  'moon': '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>',
  'help-circle': '<circle cx="12" cy="12" r="9"/><path d="M9.1 9.2a3 3 0 1 1 4.9 2.2c-.9.7-1.5 1.2-1.5 2.2"/><line x1="12" y1="16.8" x2="12" y2="16.9"/>',
  'more-horizontal': '<circle cx="5" cy="12" r="1.3" fill="currentColor" stroke="none"/><circle cx="12" cy="12" r="1.3" fill="currentColor" stroke="none"/><circle cx="19" cy="12" r="1.3" fill="currentColor" stroke="none"/>',
  'check': '<polyline points="4 12.5 9 17.5 20 6.5"/>',
  'zap': '<polygon points="13 2 4 14 11 14 10 22 20 9 13 9 13 2"/>',
  'ruler': '<rect x="3" y="8.5" width="18" height="7" rx="1.2" transform="rotate(-8 12 12)"/><path d="M7.3 9.4l.9 2M10.6 8.9l.9 2M13.9 8.4l.9 2M17.2 7.9l.9 2" transform="rotate(-8 12 12)"/>',
  'globe': '<circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3c2.8 2.5 4.2 5.7 4.2 9s-1.4 6.5-4.2 9c-2.8-2.5-4.2-5.7-4.2-9S9.2 5.5 12 3z"/>',
  'monitor': '<rect x="3" y="4.5" width="18" height="12" rx="1.5"/><path d="M8 20h8"/><path d="M12 16.5v3.5"/>',
  'x': '<line x1="5" y1="5" x2="19" y2="19"/><line x1="19" y1="5" x2="5" y2="19"/>',
  'lightbulb': '<path d="M9 18h6"/><path d="M10 21h4"/><path d="M12 3a6 6 0 0 0-3.5 10.9c.7.5 1.1 1.3 1.1 2.1h4.8c0-.8.4-1.6 1.1-2.1A6 6 0 0 0 12 3z"/>',
  'folder': '<path d="M3 7a1 1 0 0 1 1-1h5l2 2.5h9a1 1 0 0 1 1 1V18a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V7z"/>',
  'award': '<circle cx="12" cy="15" r="5.2"/><path d="M9.5 10.5L7 3l-3 1.3L8 12"/><path d="M14.5 10.5L17 3l3 1.3L16 12"/>',
  'mic': '<rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0 0 14 0"/><path d="M12 18v3"/><path d="M9 21h6"/>',
  'clock': '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3.2 2"/>',
  'layers': '<path d="M12 3l9 5-9 5-9-5 9-5z"/><path d="M3 12l9 5 9-5"/><path d="M3 16l9 5 9-5"/>',
  'headphones': '<path d="M4 14v-2a8 8 0 0 1 16 0v2"/><path d="M4 14h3v6H5a1 1 0 0 1-1-1v-5z"/><path d="M20 14h-3v6h2a1 1 0 0 0 1-1v-5z"/>'
};

/** Returns an inline <svg> string for the given icon name. */
function icon(name, cls){
  const body = ICONS[name] || ICONS['bookmark'];
  return `<svg class="icon${cls ? ' ' + cls : ''}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${body}</svg>`;
}

if (typeof window !== 'undefined') { window.icon = icon; window.ICONS = ICONS; }
