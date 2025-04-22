// src/app/features/gamification/achievements/achievements.component.ts
import { Component, OnInit, OnDestroy, ChangeDetectionStrategy, ChangeDetectorRef } from '@angular/core';
import { Subscription } from 'rxjs';
import { trigger, transition, style, animate, stagger, query } from '@angular/animations';
import { GamificationService, Achievement, PointsActivity } from '../services/gamification.service';

@Component({
  selector: 'app-achievements',
  standalone: false,
  templateUrl: './achievements.component.html',
  styleUrls: ['./achievements.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('fadeIn', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('300ms ease-out', style({ opacity: 1 }))
      ])
    ]),
    trigger('cardEnter', [
      transition(':enter', [
        query('.achievement-card', [
          style({ opacity: 0, transform: 'scale(0.8)' }),
          stagger(80, [
            animate('400ms cubic-bezier(0.35, 0, 0.25, 1)',
              style({ opacity: 1, transform: 'scale(1)' }))
          ])
        ], { optional: true })
      ])
    ])
  ]
})
export class AchievementsComponent implements OnInit, OnDestroy {
  // Current user data
  totalPoints: number = 0;
  achievements: Achievement[] = [];
  recentActivities: PointsActivity[] = [];

  // UI state
  activeTab: 'all' | 'unlocked' | 'locked' | 'badges' | 'points' = 'all';
  isMobile = window.innerWidth <= 768;
  isLoading = true;

  // Achievement stats
  unlockedCount: number = 0;
  totalCount: number = 0;
  progressPercentage: number = 0;

  // Math is needed for template
  Math = Math;

  private subscriptions: Subscription[] = [];

  constructor(
    private gamificationService: GamificationService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    // Load user score
    this.subscriptions.push(
      this.gamificationService.getUserScore().subscribe(score => {
        this.totalPoints = score;
        this.cdr.markForCheck();
      })
    );

    // Load achievements
    this.subscriptions.push(
      this.gamificationService.getUserAchievements().subscribe(achievements => {
        this.achievements = achievements;
        this.calculateAchievementStats();
        this.isLoading = false;
        this.cdr.markForCheck();
      })
    );

    // Load activities
    this.subscriptions.push(
      this.gamificationService.getUserActivities().subscribe(activities => {
        this.recentActivities = activities.slice(0, 10); // Get 10 most recent
        this.cdr.markForCheck();
      })
    );
  }

  /**
   * Set the active tab
   */
  setActiveTab(tab: 'all' | 'unlocked' | 'locked' | 'badges' | 'points'): void {
    this.activeTab = tab;
    this.cdr.markForCheck();
  }

  /**
   * Calculate achievement statistics
   */
  private calculateAchievementStats(): void {
    this.totalCount = this.achievements.length;
    this.unlockedCount = this.achievements.filter(a => a.isUnlocked).length;
    this.progressPercentage = this.totalCount > 0
      ? Math.round((this.unlockedCount / this.totalCount) * 100)
      : 0;
  }

  /**
   * Filter achievements based on active tab
   */
  getFilteredAchievements(): Achievement[] {
    switch (this.activeTab) {
      case 'unlocked':
        return this.achievements.filter(a => a.isUnlocked);
      case 'locked':
        return this.achievements.filter(a => !a.isUnlocked);
      case 'all':
      default:
        return this.achievements;
    }
  }

  /**
   * Get the appropriate category class for an achievement
   */
  getAchievementCategoryClass(requirement: string): string {
    switch (requirement) {
      case 'lessons_completed':
        return 'category-lessons';
      case 'score_reached':
        return 'category-score';
      case 'streak':
        return 'category-streak';
      case 'perfect_score':
        return 'category-perfect';
      default:
        return 'category-custom';
    }
  }

  /**
   * Get achievements filtered by requirement type
   */
  getLessonsCompletedAchievements(): Achievement[] {
    return this.achievements.filter(a => a.requirement.type === 'lessons_completed');
  }

  /**
   * Get score-related achievements
   */
  getScoreAchievements(): Achievement[] {
    return this.achievements.filter(a =>
      a.requirement.type === 'score_reached' || a.requirement.type === 'perfect_score'
    );
  }

  /**
   * Get streak achievements
   */
  getStreakAchievements(): Achievement[] {
    return this.achievements.filter(a => a.requirement.type === 'streak');
  }

  /**
   * Get total earned points from activities
   */
  getEarnedPoints(): number {
    return this.recentActivities
      .filter(a => a.type === 'earned')
      .reduce((sum, a) => sum + a.points, 0);
  }

  /**
   * Get total bonus points from activities
   */
  getBonusPoints(): number {
    return this.recentActivities
      .filter(a => a.type === 'bonus')
      .reduce((sum, a) => sum + a.points, 0);
  }

  /**
   * Get total spent points from activities (as a positive number)
   */
  getSpentPoints(): number {
    return Math.abs(this.recentActivities
      .filter(a => a.type === 'spent')
      .reduce((sum, a) => sum + a.points, 0));
  }

  ngOnDestroy(): void {
    // Clean up subscriptions
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }
}