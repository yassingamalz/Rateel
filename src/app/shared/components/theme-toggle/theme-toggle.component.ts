// src/app/shared/components/theme-toggle/theme-toggle.component.ts
import { Component, Input, OnInit, OnDestroy } from '@angular/core';
import { ThemeService, AppTheme } from '../../services/theme.service';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-theme-toggle',
  standalone: false,
  template: `
    <button 
      class="theme-toggle-btn" 
      [class]="buttonClass"
      (click)="toggleTheme()"
      [attr.aria-label]="'Toggle theme'"
    >
      <span class="theme-icon">
        <i class="fas" 
           [class.fa-sun]="currentTheme === 'light'" 
           [class.fa-moon]="currentTheme === 'dark'">
        </i>
      </span>
    </button>
  `,
  styles: [`
    .theme-toggle-btn {
      display: flex;
      align-items: center;
      justify-content: center;
      background: rgba(255, 255, 255, 0.1);
      border: none;
      border-radius: 50%;
      color: white;
      cursor: pointer;
      transition: all 0.3s ease;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);

      &:hover {
        transform: scale(1.1);
        background: rgba(255, 255, 255, 0.2);
      }
    }

    .theme-toggle-btn.default {
      width: 40px;
      height: 40px;
    }

    .theme-toggle-btn.compact {
      width: 32px;
      height: 32px;
      font-size: 0.8rem;
    }

    .theme-toggle-btn.large {
      width: 48px;
      height: 48px;
      font-size: 1.2rem;
    }

    .theme-icon {
      display: flex;
      align-items: center;
      justify-content: center;
      transition: transform 0.3s ease;
    }
  `]
})
export class ThemeToggleComponent implements OnInit, OnDestroy {
  @Input() size: 'compact' | 'default' | 'large' = 'default';
  @Input() additionalClass: string = '';

  currentTheme: AppTheme = 'light';
  private themeSub: Subscription | null = null;

  constructor(private themeService: ThemeService) { }

  ngOnInit(): void {
    this.themeSub = this.themeService.theme$.subscribe(theme => {
      this.currentTheme = theme;
    });
  }

  get buttonClass(): string {
    return [
      'theme-toggle-btn',
      this.size,
      this.additionalClass
    ].filter(Boolean).join(' ');
  }

  toggleTheme(): void {
    this.themeService.toggleTheme();
  }

  ngOnDestroy(): void {
    if (this.themeSub) {
      this.themeSub.unsubscribe();
    }
  }
}