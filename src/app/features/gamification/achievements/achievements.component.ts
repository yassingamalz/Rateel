// src/app/features/gamification/achievements/achievements.component.ts
import { Component, OnInit, OnDestroy, ChangeDetectionStrategy, ChangeDetectorRef, HostListener } from '@angular/core';
import { Subscription } from 'rxjs';
import { trigger, transition, style, animate, stagger, query } from '@angular/animations';
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

  private updateItemsPerPage() {
    // Calculate how many items can fit based on screen width
    // For landscape mobile devices
    if (this.screenWidth <= 1024) {
      this.itemsPerPage = 2;
    } else {
      this.itemsPerPage = 3;
    }
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
    // Create a collection of badges for the Collection tab
    // This would normally come from a different data source
    // but we'll generate it from achievements
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
   * Get badge image path based on achievement type and status
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
   * Get icon for activity type
   */
  getActivityIcon(activity: PointsActivity): string {
    switch (activity.type) {
      case 'earned': return 'fa-plus-circle';
      case 'spent': return 'fa-minus-circle';
      case 'bonus': return 'fa-gift';
      default: return 'fa-circle';
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

  /**
   * Get requirement text for an achievement
   */
  getRequirementText(achievement: Achievement): string {
    switch (achievement.requirement.type) {
      case 'lessons_completed':
        return `إكمال ${achievement.requirement.value} دروس`;
      case 'score_reached':
        return `الوصول إلى ${achievement.requirement.value} نقطة`;
      case 'streak':
        return `استمرار ${achievement.requirement.value} أيام`;
      case 'perfect_score':
        return `الحصول على ${achievement.requirement.value} درجات كاملة`;
      default:
        return `إكمال المهمة المطلوبة`;
    }
  }

  /**
   * Show achievement details in modal
   */
  showAchievementDetails(achievement: Achievement): void {
    this.selectedAchievement = achievement;
    this.showModal = true;
    this.cdr.markForCheck();
  }

  /**
   * Show badge details in modal
   */
  showBadgeDetails(badge: CollectionBadge): void {
    // Find the matching achievement for this badge
    const achievement = this.achievements.find(a => a.id === badge.id);
    if (achievement) {
      this.showAchievementDetails(achievement);
    }
  }

  /**
   * Close the modal
   */
  closeModal(): void {
    this.showModal = false;
    this.selectedAchievement = null;
    this.cdr.markForCheck();
  }

  /**
   * Share achievement (placeholder)
   */
  shareAchievement(achievement: Achievement): void {
    // This would connect to a sharing API
    console.log('Sharing achievement:', achievement.title);
    // Show a temporary message or trigger a toast notification
    alert(`تم نسخ الإنجاز "${achievement.title}" للمشاركة!`);
  }

  /**
   * Carousel navigation methods
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
    // Calculate offset based on item width and gap
    const itemWidth = 330; // width + padding + margin
    this.achievementSlideOffset = -(this.currentAchievementPage * itemWidth * this.itemsPerPage);
    this.cdr.markForCheck();
  }

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