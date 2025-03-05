// src/app/shared/services/theme.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

export type AppTheme = 'light' | 'dark';

@Injectable({
  providedIn: 'root'
})
export class ThemeService {
  private themeSubject = new BehaviorSubject<AppTheme>(this.getInitialTheme());
  theme$ = this.themeSubject.asObservable();

  constructor() {
    // Listen for system theme changes
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    mediaQuery.addEventListener('change', this.handleSystemThemeChange.bind(this));
  }

  private getInitialTheme(): AppTheme {
    // Check localStorage first
    const savedTheme = localStorage.getItem('app-theme') as AppTheme;
    if (savedTheme) {
      return savedTheme;
    }

    // Then check system preference
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }

  private handleSystemThemeChange(event: MediaQueryListEvent): void {
    // Only change theme if no user preference is set
    if (!localStorage.getItem('app-theme')) {
      this.setTheme(event.matches ? 'dark' : 'light');
    }
  }

  getCurrentTheme(): AppTheme {
    return this.themeSubject.value;
  }

  setTheme(theme: AppTheme): void {
    this.themeSubject.next(theme);
    localStorage.setItem('app-theme', theme);
    this.applyThemeToDocument(theme);
  }

  toggleTheme(): void {
    const currentTheme = this.themeSubject.value;
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    this.setTheme(newTheme);
  }

  private applyThemeToDocument(theme: AppTheme): void {
    document.documentElement.setAttribute('data-theme', theme);
    document.documentElement.classList.remove('light-theme', 'dark-theme');
    document.documentElement.classList.add(`${theme}-theme`);
  }
}