import { writable } from 'svelte/store';
import type { AppTheme } from './types';

export const currentTheme = writable<AppTheme>('dark');

export function applyTheme(theme: AppTheme) {
  if (typeof document === 'undefined') return;

  if (theme === 'system') {
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    document.documentElement.setAttribute('data-theme', prefersDark ? 'dark' : 'light');
  } else {
    document.documentElement.setAttribute('data-theme', theme);
  }
}
