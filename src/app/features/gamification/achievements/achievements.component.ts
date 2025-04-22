import { Component, OnInit, OnDestroy, ChangeDetectionStrategy, ChangeDetectorRef, HostListener } from '@angular/core';
import { Subscription } from 'rxjs';
import { trigger, transition, style, animate } from '@angular/animations';
import { GamificationService, Achievement, PointsActivity } from '../services/gamification.service';

interface CollectionBadge {
  id: string;
  title: string;
  image: string;
  description: string;
  isUnlocked: boolean;
  rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary';
  dateUnlocked?: Date;
}

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
    ])
  ]
})
export class AchievementsComponent implements OnInit, OnDestroy {
  // Current user data
  totalPoints: number = 0;
  achievements: Achievement[] = [];
  recentActivities: PointsActivity[] = [];
  collection: CollectionBadge[] = [];

  // UI state
  activeTab: 'all' | 'unlocked' | 'locked' | 'badges' | 'points' | 'collection' = 'all';
  isMobile = window.innerWidth <= 768;
  isLoading = true;

  // Achievement stats
  unlockedCount: number = 0;
  totalCount: number = 0;
  progressPercentage: number = 0;

  // Math is needed for template
  Math = Math;

  // Carousel state
  achievementSlideOffset: number = 0;
  categorySlideOffset: number = 0;
  activitySlideOffset: number = 0;
  currentAchievementPage: number = 0;
  currentCategoryPage: number = 0;
  currentActivityPage: number = 0;
  totalAchievementPages: number[] = [0];
  totalCategoryPages: number[] = [0, 1, 2];
  totalActivityPages: number[] = [0];
  itemsPerPage: number = 3;

  // Modal state
  showModal: boolean = false;
  selectedAchievement: Achievement | null = null;

  // Screen dimensions
  screenWidth: number;
  screenHeight: number;

  private subscriptions: Subscription[] = [];

  constructor(
    private gamificationService: GamificationService,
    private cdr: ChangeDetectorRef
  ) {
    this.screenWidth = window.innerWidth;
    this.screenHeight = window.innerHeight;
    this.updateItemsPerPage();
  }

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
        this.calculateTotalPages();
        this.generateCollectionBadges();
        this.isLoading = false;
        this.cdr.markForCheck();
      })
    );

    // Load activities
    this.subscriptions.push(
      this.gamificationService.getUserActivities().subscribe(activities => {
        this.recentActivities = activities.slice(0, 10); // Get 10 most recent
        this.calculateTotalActivityPages();
        this.cdr.markForCheck();
      })
    );
  }

  @HostListener('window:resize', ['$event'])
  onResize() {
    this.screenWidth = window.innerWidth;
    this.screenHeight = window.innerHeight;
    this.updateItemsPerPage();
    this.calculateTotalPages();
    this.calculateTotalActivityPages();
    this.resetCarouselPositions();
    this.cdr.markForCheck();
  }

  /**
   * Set the active tab
   */
  setActiveTab(tab: 'all' | 'unlocked' | 'locked' | 'badges' | 'points' | 'collection'): void {
    this.activeTab = tab;
    this.resetCarouselPositions();
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
   * Generate collection badges from achievements
   */
  private generateCollectionBadges(): void {
    this.collection = this.achievements.map(achievement => {
      // Determine rarity based on achievement type
      let rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary';
      switch (achievement.type) {
        case 'bronze': rarity = 'common'; break;
        case 'silver': rarity = 'uncommon'; break;
        case 'gold': rarity = 'rare'; break;
        case 'platinum': rarity = 'epic'; break;
        case 'diamond': rarity = 'legendary'; break;
        default: rarity = 'common';
      }

      return {
        id: achievement.id,
        title: achievement.title,
        image: this.getBadgeImage(achievement),
        description: achievement.description,
        isUnlocked: achievement.isUnlocked,
        rarity,
        dateUnlocked: achievement.dateUnlocked
      };
    });
  }

  /**
   * Calculate total pages for carousels
   */
  private calculateTotalPages(): void {
    const achievements = this.getFilteredAchievements();
    const totalPages = Math.ceil(achievements.length / this.itemsPerPage);
    this.totalAchievementPages = Array(Math.max(1, totalPages)).fill(0).map((_, i) => i);
  }

  /**
   * Calculate total pages for activities carousel
   */
  private calculateTotalActivityPages(): void {
    const totalPages = Math.ceil(this.recentActivities.length / this.itemsPerPage);
    this.totalActivityPages = Array(Math.max(1, totalPages)).fill(0).map((_, i) => i);
  }

  /**
   * Reset all carousel positions
   */
  private resetCarouselPositions(): void {
    this.achievementSlideOffset = 0;
    this.categorySlideOffset = 0;
    this.activitySlideOffset = 0;
    this.currentAchievementPage = 0;
    this.currentCategoryPage = 0;
    this.currentActivityPage = 0;
  }

  /**
   * Update items per page based on screen width
   */
  private updateItemsPerPage(): void {
    if (this.screenWidth <= 1024) {
      this.itemsPerPage = 2;
    } else {
      this.itemsPerPage = 3;
    }
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
   * Filtered achievements by requirement type
   */
  getLessonsCompletedAchievements(): Achievement[] {
    return this.achievements.filter(a => a.requirement.type === 'lessons_completed');
  }

  getScoreAchievements(): Achievement[] {
    return this.achievements.filter(a =>
      a.requirement.type === 'score_reached' || a.requirement.type === 'perfect_score'
    );
  }

  getStreakAchievements(): Achievement[] {
    return this.achievements.filter(a => a.requirement.type === 'streak');
  }

  /**
   * Get total point statistics
   */
  getEarnedPoints(): number {
    return this.recentActivities
      .filter(a => a.type === 'earned')
      .reduce((sum, a) => sum + a.points, 0);
  }

  getBonusPoints(): number {
    return this.recentActivities
      .filter(a => a.type === 'bonus')
      .reduce((sum, a) => sum + a.points, 0);
  }

  getSpentPoints(): number {
    return Math.abs(this.recentActivities
      .filter(a => a.type === 'spent')
      .reduce((sum, a) => sum + a.points, 0));
  }

  /**
   * Get badge image
   */
  getBadgeImage(achievement: Achievement): string {
    const badgeType = achievement.type || 'bronze';
    const status = achievement.isUnlocked ? 'unlocked' : 'locked';
    return `assets/images/badges/${badgeType}_${status}.png`;
  }

  /**
   * Get badge rarity label
   */
  getBadgeRarityLabel(rarity: string): string {
    switch (rarity) {
      case 'common': return 'عادي';
      case 'uncommon': return 'غير شائع';
      case 'rare': return 'نادر';
      case 'epic': return 'أسطوري';
      case 'legendary': return 'خرافي';
      default: return '';
    }
  }

  /**
   * Show achievement details
   */
  showAchievementDetails(achievement: Achievement): void {
    this.selectedAchievement = achievement;
    this.showModal = true;
    this.cdr.markForCheck();
  }

  /**
   * Show badge details
   */
  showBadgeDetails(badge: CollectionBadge): void {
    // Find the matching achievement for this badge
    const achievement = this.achievements.find(a => a.id === badge.id);
    if (achievement) {
      this.showAchievementDetails(achievement);
    }
  }

  /**
   * Close modal
   */
  closeModal(): void {
    this.showModal = false;
    this.selectedAchievement = null;
    this.cdr.markForCheck();
  }

  /**
   * Share achievement
   */
  shareAchievement(achievement: Achievement): void {
    // This would connect to a sharing API
    console.log('Sharing achievement:', achievement.title);
    // Show a temporary message or trigger a toast notification
    alert(`تم نسخ الإنجاز "${achievement.title}" للمشاركة!`);
  }

  /**
   * Achievement carousel navigation
   */
  nextAchievementPage(): void {
    if (this.currentAchievementPage < this.totalAchievementPages.length - 1) {
      this.currentAchievementPage++;
      this.updateAchievementOffset();
    }
  }

  previousAchievementPage(): void {
    if (this.currentAchievementPage > 0) {
      this.currentAchievementPage--;
      this.updateAchievementOffset();
    }
  }

  goToAchievementPage(page: number): void {
    this.currentAchievementPage = page;
    this.updateAchievementOffset();
  }

  private updateAchievementOffset(): void {
    const itemWidth = 330; // width + padding + margin
    this.achievementSlideOffset = -(this.currentAchievementPage * itemWidth * this.itemsPerPage);
    this.cdr.markForCheck();
  }

  /**
   * Category carousel navigation
   */
  nextCategoryPage(): void {
    if (this.currentCategoryPage < this.totalCategoryPages.length - 1) {
      this.currentCategoryPage++;
      this.updateCategoryOffset();
    }
  }

  previousCategoryPage(): void {
    if (this.currentCategoryPage > 0) {
      this.currentCategoryPage--;
      this.updateCategoryOffset();
    }
  }

  goToCategoryPage(page: number): void {
    this.currentCategoryPage = page;
    this.updateCategoryOffset();
  }

  private updateCategoryOffset(): void {
    const containerWidth = this.screenWidth - 100; // Accounting for navigation buttons
    this.categorySlideOffset = -(this.currentCategoryPage * containerWidth);
    this.cdr.markForCheck();
  }

  /**
   * Activity carousel navigation
   */
  nextActivityPage(): void {
    if (this.currentActivityPage < this.totalActivityPages.length - 1) {
      this.currentActivityPage++;
      this.updateActivityOffset();
    }
  }

  previousActivityPage(): void {
    if (this.currentActivityPage > 0) {
      this.currentActivityPage--;
      this.updateActivityOffset();
    }
  }

  goToActivityPage(page: number): void {
    this.currentActivityPage = page;
    this.updateActivityOffset();
  }

  private updateActivityOffset(): void {
    const itemWidth = 270; // width + margin
    this.activitySlideOffset = -(this.currentActivityPage * itemWidth * this.itemsPerPage);
    this.cdr.markForCheck();
  }

  ngOnDestroy(): void {
    // Clean up subscriptions
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }
}