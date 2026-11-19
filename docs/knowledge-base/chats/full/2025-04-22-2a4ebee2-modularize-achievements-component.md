# Modularize Achievements Component

- Link: https://claude.ai/chat/2a4ebee2-0fd6-4c40-941c-f286ef7c7a69
- Creata: 2025-04-22T23:13:12.867043Z
- Aggiornata: 2025-04-22T23:25:48.881685Z

## Yassin (2025-04-22T23:13)

i want to work on the achievements comp9entn to nehance it ui ux but i want to divide it into small compnentns to be able to work on it in seprate way so
give me ng g command to do that and commit message
be aware with standard compknent dividnig

## Claude (2025-04-22T23:13)

Looking at your achievements component, it's indeed quite complex and would benefit from being broken down into smaller, more manageable components. Based on the structure of your code, here are the Angular CLI commands to generate the necessary components:

```bash
# Create a components directory within achievements
ng g c features/gamification/achievements/components/achievement-header --standalone=false
ng g c features/gamification/achievements/components/achievement-tabs --standalone=false
ng g c features/gamification/achievements/components/achievement-carousel --standalone=false
ng g c features/gamification/achievements/components/achievement-card --standalone=false
ng g c features/gamification/achievements/components/badge-category --standalone=false
ng g c features/gamification/achievements/components/points-summary --standalone=false
ng g c features/gamification/achievements/components/activity-card --standalone=false
ng g c features/gamification/achievements/components/collection-grid --standalone=false
ng g c features/gamification/achievements/components/achievement-details-modal --standalone=false
```

These commands will create non-standalone components within a new components folder, keeping them organized and well-structured. The `--standalone=false` flag ensures they're compatible with your current module-based architecture.

For a commit message, you could use:

```
refactor(gamification): decompose achievements component into smaller components

- Extract logical UI sections into independent components
- Improve maintainability and readability of achievements feature
- Break down complex UI into header, tabs, cards, carousels, and modal components
- Maintain module-based architecture with non-standalone components
- Prepare for future enhancements to achievements UI/UX
```

This approach will make your code more maintainable and let you work on separate pieces without needing to modify the entire achievements component. After creating these components, you can gradually move the relevant HTML, CSS, and TypeScript code from the main component into these smaller components.

## Yassin (2025-04-22T23:14)

dont over divide them

## Claude (2025-04-22T23:14)

You're absolutely right - we should avoid over-dividing the components. Let's focus on a more balanced approach with just the main logical sections:

```bash
# Create component for main sections
ng g c features/gamification/achievements/components/achievement-header --standalone=false
ng g c features/gamification/achievements/components/achievement-list --standalone=false
ng g c features/gamification/achievements/components/badges-collection --standalone=false
ng g c features/gamification/achievements/components/points-history --standalone=false
ng g c features/gamification/achievements/components/achievement-details-modal --standalone=false
```

This creates 5 key components that align with the main sections of your UI, making maintenance easier without creating too many tiny components.

For a commit message:

```
refactor(gamification): restructure achievements into key component sections

- Extract main logical sections into separate components
- Improve maintainability while avoiding excessive component fragmentation
- Create dedicated components for header, achievement list, badges, points history, and details modal
- Prepare for UI/UX enhancements with more manageable code structure
```

This approach will give you a good balance between code organization and component granularity, making it easier to work on different sections of the achievements feature.

## Yassin (2025-04-22T23:15)

now the full extraction of all them and what should i delte

## Claude (2025-04-22T23:15)

# Full Extraction Plan for Achievement Components

Here's a comprehensive plan for extracting each component, what to move where, and what to delete from the main component:

## 1. achievement-header Component

**Move from main component:**
```typescript
// TS properties to move
totalPoints: number;
unlockedCount: number;
totalCount: number;
progressPercentage: number;

// Methods to move
private calculateAchievementStats() {...}
```

**HTML to extract:**
```html
<div class="achievements-header">
    <!-- Header content with title and stats -->
    <div class="header-content">
        <div class="title-section">
            <h1 class="page-title">الإنجازات</h1>
            <div class="header-progress-bar">...</div>
        </div>
        <div class="stats-section">
            <div class="total-score pulse-animation">...</div>
        </div>
    </div>
</div>
```

**SCSS to extract:**
All `.achievements-header` related styles

## 2. achievement-list Component

**Move from main component:**
```typescript
// TS properties to move
achievements: Achievement[] = [];
achievementSlideOffset: number = 0;
currentAchievementPage: number = 0;
totalAchievementPages: number[] = [0];

// Methods to move
getFilteredAchievements() {...}
getBadgeImage(achievement: Achievement) {...}
getAchievementCategoryClass(requirement: string) {...}
previousAchievementPage() {...}
nextAchievementPage() {...}
goToAchievementPage(page: number) {...}
private updateAchievementOffset() {...}
```

**HTML to extract:**
```html
<div class="achievements-view" *ngIf="activeTab === 'all'" @fadeIn>
    <div class="achievements-carousel">
        <!-- All carousel content -->
    </div>
    <div class="carousel-indicators">
        <!-- Indicators -->
    </div>
</div>
```

**SCSS to extract:**
All `.achievements-view` and `.achievements-carousel` related styles

## 3. badges-collection Component

**Move from main component:**
```typescript
// TS properties to move
categorySlideOffset: number = 0;
currentCategoryPage: number = 0;
totalCategoryPages: number[] = [0, 1, 2];

// Methods to move
getLessonsCompletedAchievements() {...}
getScoreAchievements() {...}
getStreakAchievements() {...}
previousCategoryPage() {...}
nextCategoryPage() {...}
goToCategoryPage(page: number) {...}
private updateCategoryOffset() {...}
```

**HTML to extract:**
```html
<div class="badges-view" *ngIf="activeTab === 'badges'" @fadeIn>
    <div class="badges-carousel">
        <!-- All badges carousel content -->
    </div>
    <div class="carousel-indicators">
        <!-- Indicators -->
    </div>
</div>
```

**SCSS to extract:**
All `.badges-view` and `.badges-carousel` related styles

## 4. points-history Component

**Move from main component:**
```typescript
// TS properties to move
recentActivities: PointsActivity[] = [];
activitySlideOffset: number = 0;
currentActivityPage: number = 0;
totalActivityPages: number[] = [0];

// Methods to move
getEarnedPoints() {...}
getBonusPoints() {...} 
getSpentPoints() {...}
getActivityIcon(activity: PointsActivity) {...}
previousActivityPage() {...}
nextActivityPage() {...}
goToActivityPage(page: number) {...}
private updateActivityOffset() {...}
private calculateTotalActivityPages() {...}
```

**HTML to extract:**
```html
<div class="points-view" *ngIf="activeTab === 'points'" @fadeIn>
    <div class="points-summary">
        <!-- Points summary content -->
    </div>
    <div class="points-history">
        <!-- Activity carousel content -->
    </div>
</div>
```

**SCSS to extract:**
All `.points-view`, `.points-summary`, and `.points-history` related styles

## 5. achievement-details-modal Component

**Move from main component:**
```typescript
// TS properties to move
showModal: boolean = false;
selectedAchievement: Achievement | null = null;

// Methods to move
showAchievementDetails(achievement: Achievement) {...}
closeModal() {...}
shareAchievement(achievement: Achievement) {...}
getRequirementText(achievement: Achievement) {...}
```

**HTML to extract:**
```html
<app-modal [isOpen]="showModal" (closed)="closeModal()" size="md" [showCloseButton]="true" position="center">
    <div class="achievement-modal" *ngIf="selectedAchievement">
        <!-- Modal content -->
    </div>
</app-modal>
```

**SCSS to extract:**
All `.achievement-modal` related styles

## What to Keep in the Main Component

**Keep in achievements.component.ts:**
```typescript
// Core properties
activeTab: 'all' | 'unlocked' | 'locked' | 'badges' | 'points' | 'collection' = 'all';
achievements: Achievement[] = [];
collection: CollectionBadge[] = [];
isLoading = true;
isMobile = window.innerWidth <= 768;
Math = Math;
screenWidth: number;
screenHeight: number;

// Core methods
ngOnInit() {...} // Keep subscription logic
setActiveTab() {...}
private updateItemsPerPage() {...}
private resetCarouselPositions() {...}
private calculateTotalPages() {...}
private generateCollectionBadges() {...}
@HostListener('window:resize', ['$event']) onResize() {...}
```

**Keep in HTML:**
```html
<div class="achievements-container" dir="rtl">
    <!-- Particles Background -->
    <div class="particles-container">...</div>
    
    <!-- Component references -->
    <app-achievement-header [totalPoints]="totalPoints" [progress]="progressPercentage" 
                          [unlocked]="unlockedCount" [total]="totalCount"></app-achievement-header>
    
    <!-- Tab Navigation -->
    <div class="tabs-container">...</div>
    
    <!-- Content Area with conditional displays -->
    <div class="content-area">
        <app-achievement-list *ngIf="activeTab === 'all'" [achievements]="getFilteredAchievements()" 
                             (selectAchievement)="showAchievementDetails($event)"></app-achievement-list>
        
        <app-badges-collection *ngIf="activeTab === 'badges'" [achievements]="achievements" 
                              (selectAchievement)="showAchievementDetails($event)"></app-badges-collection>
        
        <app-points-history *ngIf="activeTab === 'points'" [activities]="recentActivities"></app-points-history>
        
        <!-- Collection View - Keep this in main component until extracted -->
        <div class="collection-view" *ngIf="activeTab === 'collection'" @fadeIn>...</div>
    </div>
    
    <app-achievement-details-modal [achievement]="selectedAchievement" [isOpen]="showModal" 
                                 (close)="closeModal()"></app-achievement-details-modal>
</div>
```

**Commit message:**

```
refactor(gamification): extract achievement components for improved maintainability

- Extract header, achievement list, badges collection, points history, and details modal into separate components
- Keep main component as orchestrator for child components
- Distribute template, styles, and logic to appropriate components
- Improve code organization and preparation for future UI/UX enhancements
- Reduce main component complexity while maintaining functionality
```

This extraction approach creates a balanced component structure that makes maintenance easier without creating too many tiny components. Each extracted component has a clear, single responsibility within the achievements feature.

## Yassin (2025-04-22T23:16)

now give me the full extraction code  of all them and what should i delte

## Claude (2025-04-22T23:19)

# Extracted Components for Achievements Feature

Here's the full extraction code for each component, showing what you should create and what to delete from the original component.

## 1. AchievementHeaderComponent

**achievement-header.component.ts**:
```typescript
import { Component, Input, ChangeDetectionStrategy } from '@angular/core';

@Component({
  selector: 'app-achievement-header',
  templateUrl: './achievement-header.component.html',
  styleUrls: ['./achievement-header.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AchievementHeaderComponent {
  @Input() totalPoints: number = 0;
  @Input() progressPercentage: number = 0;
  @Input() unlockedCount: number = 0;
  @Input() totalCount: number = 0;
}
```

**achievement-header.component.html**:
```html
<div class="achievements-header">
  <div class="header-content">
    <div class="title-section">
      <h1 class="page-title">الإنجازات</h1>
      <div class="header-progress-bar">
        <div class="progress-fill" [style.width.%]="progressPercentage"></div>
        <span class="progress-label">{{unlockedCount}}/{{totalCount}}</span>
        <div class="progress-stars">
          <i class="fas fa-star" *ngFor="let i of [1,2,3,4,5]"
            [class.filled]="progressPercentage >= i * 20"></i>
        </div>
      </div>
    </div>

    <div class="stats-section">
      <div class="total-score pulse-animation">
        <div class="score-circle">
          <span class="score-value">{{totalPoints}}</span>
          <i class="fas fa-star score-icon"></i>
        </div>
        <span class="score-label">مجموع النقاط</span>
      </div>
    </div>
  </div>
</div>
```

**achievement-header.component.scss**: 
```scss
// Copy the relevant styles from the achievements.component.scss
@use "sass:map";
@use 'variables' as vars;

.achievements-header {
  padding: 15px;
  position: relative;
  z-index: 1;

  .header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;

    @media (max-width: 768px) {
      align-items: center;
    }
  }

  .title-section {
    .page-title {
      font-size: 2rem;
      font-weight: 700;
      color: map-get(vars.$colors, 'text', 'light');
      margin: 0 0 10px;
      text-shadow: 0 2px 10px rgba(0, 0, 0, 0.5);
      position: relative;
      display: inline-block;

      &::after {
        content: '';
        position: absolute;
        bottom: -5px;
        right: 0;
        width: 60%;
        height: 3px;
        background: map-get(vars.$colors, 'accent', 'base');
        border-radius: 2px;
        box-shadow: 0 0 10px rgba(map-get(vars.$colors, 'accent', 'base'), 0.7);
      }
    }

    .header-progress-bar {
      position: relative;
      width: 220px;
      height: 8px;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 4px;
      overflow: hidden;
      margin-top: 12px;

      .progress-fill {
        height: 100%;
        background: linear-gradient(to right, map-get(vars.$colors, 'accent', 'base'), map-get(vars.$colors, 'accent', 'bright'));
        border-radius: 4px;
        position: relative;
        transition: width 0.5s cubic-bezier(0.22, 1, 0.36, 1);

        &::after {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: linear-gradient(90deg,
              rgba(255, 255, 255, 0) 0%,
              rgba(255, 255, 255, 0.3) 50%,
              rgba(255, 255, 255, 0) 100%);
          animation: shimmer 2s infinite;
        }
      }

      .progress-label {
        position: absolute;
        top: -18px;
        left: 0;
        color: map-get(vars.$colors, 'text', 'muted');
        font-size: 12px;
      }

      .progress-stars {
        position: absolute;
        top: -18px;
        right: 0;
        display: flex;
        direction: ltr;

        i {
          font-size: 14px;
          color: rgba(255, 255, 255, 0.2);
          margin-left: 3px;

          &.filled {
            color: map-get(vars.$colors, 'accent', 'base');
            filter: drop-shadow(0 0 3px rgba(map-get(vars.$colors, 'accent', 'base'), 0.5));
          }
        }
      }
    }
  }

  .stats-section {
    .total-score {
      display: flex;
      flex-direction: column;
      align-items: center;

      .score-circle {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        background: radial-gradient(circle,
            rgba(map-get(vars.$colors, 'accent', 'base'), 0.3) 0%,
            rgba(map-get(vars.$colors, 'accent', 'base'), 0.1) 70%);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        box-shadow: 0 0 20px rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
        position: relative;

        .score-value {
          font-size: 1.8rem;
          font-weight: 700;
          color: map-get(vars.$colors, 'text', 'light');
          text-shadow: 0 0 10px rgba(255, 255, 255, 0.5);
        }

        .score-icon {
          color: map-get(vars.$colors, 'accent', 'base');
          font-size: 1rem;
          margin-top: -5px;
          filter: drop-shadow(0 0 3px rgba(map-get(vars.$colors, 'accent', 'base'), 0.8));
        }

        &::before,
        &::after {
          content: '';
          position: absolute;
          top: -5px;
          left: -5px;
          right: -5px;
          bottom: -5px;
          border-radius: 50%;
          border: 2px solid rgba(map-get(vars.$colors, 'accent', 'base'), 0.2);
        }

        &::after {
          top: -10px;
          left: -10px;
          right: -10px;
          bottom: -10px;
          border: 1px solid rgba(map-get(vars.$colors, 'accent', 'base'), 0.1);
        }
      }

      .score-label {
        margin-top: 5px;
        font-size: 0.9rem;
        color: map-get(vars.$colors, 'text', 'muted');
      }
    }
  }
}

.pulse-animation {
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
  100% {
    transform: scale(1);
  }
}

@keyframes shimmer {
  0% {
    transform: translateX(-100%);
  }
  100% {
    transform: translateX(100%);
  }
}
```

## 2. AchievementListComponent

**achievement-list.component.ts**:
```typescript
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { Achievement } from '../../../services/gamification.service';
import { trigger, transition, style, animate } from '@angular/animations';

@Component({
  selector: 'app-achievement-list',
  templateUrl: './achievement-list.component.html',
  styleUrls: ['./achievement-list.component.scss'],
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
export class AchievementListComponent {
  @Input() achievements: Achievement[] = [];
  @Input() achievementSlideOffset: number = 0;
  @Input() currentAchievementPage: number = 0;
  @Input() totalAchievementPages: number[] = [0];
  @Output() showDetails = new EventEmitter<Achievement>();
  @Output() previous = new EventEmitter<void>();
  @Output() next = new EventEmitter<void>();
  @Output() goToPage = new EventEmitter<number>();
  
  getAchievementCategoryClass(requirement: string): string {
    switch (requirement) {
      case 'lessons_completed': return 'category-lessons';
      case 'score_reached': return 'category-score';
      case 'streak': return 'category-streak';
      case 'perfect_score': return 'category-perfect';
      default: return 'category-custom';
    }
  }
  
  getBadgeImage(achievement: Achievement): string {
    const badgeType = achievement.type || 'bronze';
    const status = achievement.isUnlocked ? 'unlocked' : 'locked';
    return `assets/images/badges/${badgeType}_${status}.png`;
  }
  
  previousPage(): void {
    this.previous.emit();
  }
  
  nextPage(): void {
    this.next.emit();
  }
  
  navigateToPage(page: number): void {
    this.goToPage.emit(page);
  }
  
  onShowDetails(achievement: Achievement): void {
    this.showDetails.emit(achievement);
  }
}
```

**achievement-list.component.html**:
```html
<div class="achievements-view" @fadeIn>
  <div class="achievements-carousel">
    <div class="carousel-nav left" (click)="previousPage()">
      <i class="fas fa-chevron-right"></i>
    </div>

    <div class="carousel-container">
      <div class="carousel-track" [style.transform]="'translateX(' + achievementSlideOffset + 'px)'">
        <div *ngFor="let achievement of achievements; let i = index"
          class="achievement-card-container" (click)="onShowDetails(achievement)">
          <div class="achievement-card" [class.unlocked]="achievement.isUnlocked"
            [ngClass]="getAchievementCategoryClass(achievement.requirement.type)">

            <div class="card-glow" [class.active]="achievement.isUnlocked"></div>

            <div class="badge-image">
              <img [src]="getBadgeImage(achievement)" [alt]="achievement.title">
              <div class="lock-overlay" *ngIf="!achievement.isUnlocked">
                <i class="fas fa-lock"></i>
              </div>
            </div>

            <div class="achievement-info">
              <h3 class="achievement-title">{{achievement.title}}</h3>

              <div class="achievement-progress" *ngIf="!achievement.isUnlocked">
                <div class="progress-bar">
                  <div class="progress-fill" [style.width.%]="achievement.progress"></div>
                </div>
                <span class="progress-text">{{achievement.progress}}%</span>
              </div>

              <div class="achievement-completed" *ngIf="achievement.isUnlocked">
                <i class="fas fa-check-circle"></i>
                <span>مكتمل</span>
              </div>
            </div>

            <div class="achievement-points">
              <i class="fas fa-star"></i>
              <span>{{achievement.points}}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="carousel-nav right" (click)="nextPage()">
      <i class="fas fa-chevron-left"></i>
    </div>
  </div>

  <div class="carousel-indicators">
    <div *ngFor="let page of totalAchievementPages; let i = index" class="indicator"
      [class.active]="currentAchievementPage === i" (click)="navigateToPage(i)"></div>
  </div>
</div>
```

**achievement-list.component.scss**: 
Copy relevant styles from achievements.component.scss for the achievements carousel and cards.

## 3. BadgesCollectionComponent

**badges-collection.component.ts**:
```typescript
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { Achievement } from '../../../services/gamification.service';
import { trigger, transition, style, animate } from '@angular/animations';

@Component({
  selector: 'app-badges-collection',
  templateUrl: './badges-collection.component.html',
  styleUrls: ['./badges-collection.component.scss'],
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
export class BadgesCollectionComponent {
  @Input() lessonAchievements: Achievement[] = [];
  @Input() scoreAchievements: Achievement[] = [];
  @Input() streakAchievements: Achievement[] = [];
  @Input() categorySlideOffset: number = 0;
  @Input() currentCategoryPage: number = 0;
  @Input() totalCategoryPages: number[] = [0, 1, 2];
  
  @Output() showDetails = new EventEmitter<Achievement>();
  @Output() previous = new EventEmitter<void>();
  @Output() next = new EventEmitter<void>();
  @Output() goToPage = new EventEmitter<number>();
  
  getBadgeImage(achievement: Achievement): string {
    const badgeType = achievement.type || 'bronze';
    const status = achievement.isUnlocked ? 'unlocked' : 'locked';
    return `assets/images/badges/${badgeType}_${status}.png`;
  }
  
  previousPage(): void {
    this.previous.emit();
  }
  
  nextPage(): void {
    this.next.emit();
  }
  
  navigateToPage(page: number): void {
    this.goToPage.emit(page);
  }
  
  onShowDetails(achievement: Achievement): void {
    this.showDetails.emit(achievement);
  }
}
```

**badges-collection.component.html**:
```html
<div class="badges-view" @fadeIn>
  <div class="badges-carousel">
    <div class="carousel-nav left" (click)="previousPage()">
      <i class="fas fa-chevron-right"></i>
    </div>

    <div class="carousel-container">
      <div class="carousel-track" [style.transform]="'translateX(' + categorySlideOffset + 'px)'">
        <!-- Lessons Achievements Category -->
        <div class="badge-category">
          <div class="category-header">
            <i class="fas fa-graduation-cap"></i>
            <h2>إنجازات الدروس</h2>
          </div>

          <div class="badges-grid">
            <div *ngFor="let achievement of lessonAchievements" class="badge-item"
              [class.unlocked]="achievement.isUnlocked"
              (click)="onShowDetails(achievement)">
              <div class="badge-display">
                <img [src]="getBadgeImage(achievement)" [alt]="achievement.title">
                <div class="lock-overlay" *ngIf="!achievement.isUnlocked">
                  <i class="fas fa-lock"></i>
                </div>
                <div class="badge-glow" *ngIf="achievement.isUnlocked"></div>
              </div>
              <p class="badge-name">{{achievement.title}}</p>
            </div>
          </div>
        </div>

        <!-- Progress Achievements Category -->
        <div class="badge-category">
          <div class="category-header">
            <i class="fas fa-chart-line"></i>
            <h2>إنجازات التقدم</h2>
          </div>

          <div class="badges-grid">
            <div *ngFor="let achievement of scoreAchievements" class="badge-item"
              [class.unlocked]="achievement.isUnlocked"
              (click)="onShowDetails(achievement)">
              <div class="badge-display">
                <img [src]="getBadgeImage(achievement)" [alt]="achievement.title">
                <div class="lock-overlay" *ngIf="!achievement.isUnlocked">
                  <i class="fas fa-lock"></i>
                </div>
                <div class="badge-glow" *ngIf="achievement.isUnlocked"></div>
              </div>
              <p class="badge-name">{{achievement.title}}</p>
            </div>
          </div>
        </div>

        <!-- Streak Achievements Category -->
        <div class="badge-category">
          <div class="category-header">
            <i class="fas fa-fire"></i>
            <h2>إنجازات الاستمرارية</h2>
          </div>

          <div class="badges-grid">
            <div *ngFor="let achievement of streakAchievements" class="badge-item"
              [class.unlocked]="achievement.isUnlocked"
              (click)="onShowDetails(achievement)">
              <div class="badge-display">
                <img [src]="getBadgeImage(achievement)" [alt]="achievement.title">
                <div class="lock-overlay" *ngIf="!achievement.isUnlocked">
                  <i class="fas fa-lock"></i>
                </div>
                <div class="badge-glow" *ngIf="achievement.isUnlocked"></div>
              </div>
              <p class="badge-name">{{achievement.title}}</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="carousel-nav right" (click)="nextPage()">
      <i class="fas fa-chevron-left"></i>
    </div>
  </div>

  <div class="carousel-indicators">
    <div *ngFor="let page of totalCategoryPages; let i = index" class="indicator"
      [class.active]="currentCategoryPage === i" (click)="navigateToPage(i)"></div>
  </div>
</div>
```

**badges-collection.component.scss**: 
Copy relevant styles from achievements.component.scss for the badges collection view.

## 4. PointsHistoryComponent

**points-history.component.ts**:
```typescript
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { PointsActivity } from '../../../services/gamification.service';
import { trigger, transition, style, animate } from '@angular/animations';

@Component({
  selector: 'app-points-history',
  templateUrl: './points-history.component.html',
  styleUrls: ['./points-history.component.scss'],
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
export class PointsHistoryComponent {
  @Input() earnedPoints: number = 0;
  @Input() bonusPoints: number = 0;
  @Input() spentPoints: number = 0;
  @Input() activities: PointsActivity[] = [];
  @Input() activitySlideOffset: number = 0;
  @Input() currentActivityPage: number = 0;
  @Input() totalActivityPages: number[] = [0];
  
  @Output() previous = new EventEmitter<void>();
  @Output() next = new EventEmitter<void>();
  @Output() goToPage = new EventEmitter<number>();
  
  getActivityIcon(activity: PointsActivity): string {
    switch (activity.type) {
      case 'earned': return 'fa-plus-circle';
      case 'spent': return 'fa-minus-circle';
      case 'bonus': return 'fa-gift';
      default: return 'fa-circle';
    }
  }
  
  previousPage(): void {
    this.previous.emit();
  }
  
  nextPage(): void {
    this.next.emit();
  }
  
  navigateToPage(page: number): void {
    this.goToPage.emit(page);
  }
}
```

**points-history.component.html**:
```html
<div class="points-view" @fadeIn>
  <div class="points-summary">
    <div class="point-type earned">
      <div class="point-icon">
        <i class="fas fa-plus-circle"></i>
      </div>
      <div class="point-info">
        <span class="point-value">{{ earnedPoints }}</span>
        <span class="point-label">المكتسبة</span>
      </div>
    </div>

    <div class="point-type bonus">
      <div class="point-icon">
        <i class="fas fa-gift"></i>
      </div>
      <div class="point-info">
        <span class="point-value">{{ bonusPoints }}</span>
        <span class="point-label">المكافآت</span>
      </div>
    </div>

    <div class="point-type spent">
      <div class="point-icon">
        <i class="fas fa-minus-circle"></i>
      </div>
      <div class="point-info">
        <span class="point-value">{{ spentPoints }}</span>
        <span class="point-label">المستخدمة</span>
      </div>
    </div>
  </div>

  <div class="points-history">
    <h3 class="history-title">آخر النشاطات</h3>

    <div class="activity-carousel">
      <div class="carousel-nav left" (click)="previousPage()">
        <i class="fas fa-chevron-right"></i>
      </div>

      <div class="carousel-container">
        <div class="carousel-track" [style.transform]="'translateX(' + activitySlideOffset + 'px)'">
          <div *ngFor="let activity of activities" class="activity-card"
            [ngClass]="activity.type">
            <div class="activity-header">
              <div class="activity-icon">
                <i class="fas" [ngClass]="getActivityIcon(activity)"></i>
              </div>
              <div class="activity-points">
                <span *ngIf="activity.type !== 'spent'">+</span>
                <span>{{activity.points}}</span>
                <i class="fas fa-star"></i>
              </div>
            </div>

            <div class="activity-title">{{activity.title}}</div>

            <div class="activity-footer">
              <span class="activity-date">{{activity.date | date:'shortDate'}}</span>
              <span class="activity-time">{{activity.date | date:'shortTime'}}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="carousel-nav right" (click)="nextPage()">
        <i class="fas fa-chevron-left"></i>
      </div>
    </div>

    <div class="carousel-indicators">
      <div *ngFor="let page of totalActivityPages; let i = index" class="indicator"
        [class.active]="currentActivityPage === i" (click)="navigateToPage(i)"></div>
    </div>
  </div>
</div>
```

**points-history.component.scss**: 
Copy relevant styles from achievements.component.scss for the points history view.

## 5. AchievementDetailsModalComponent

**achievement-details-modal.component.ts**:
```typescript
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { Achievement } from '../../../services/gamification.service';

@Component({
  selector: 'app-achievement-details-modal',
  templateUrl: './achievement-details-modal.component.html',
  styleUrls: ['./achievement-details-modal.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AchievementDetailsModalComponent {
  @Input() isOpen: boolean = false;
  @Input() achievement: Achievement | null = null;
  
  @Output() close = new EventEmitter<void>();
  @Output() share = new EventEmitter<Achievement>();
  
  getBadgeImage(achievement: Achievement): string {
    const badgeType = achievement.type || 'bronze';
    const status = achievement.isUnlocked ? 'unlocked' : 'locked';
    return `assets/images/badges/${badgeType}_${status}.png`;
  }
  
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
  
  onClose(): void {
    this.close.emit();
  }
  
  onShare(achievement: Achievement): void {
    this.share.emit(achievement);
  }
}
```

**achievement-details-modal.component.html**:
```html
<app-modal [isOpen]="isOpen" (closed)="onClose()" size="md" [showCloseButton]="true" position="center">
  <div class="achievement-modal" *ngIf="achievement">
    <div class="modal-badge" [class.unlocked]="achievement.isUnlocked">
      <img [src]="getBadgeImage(achievement)" [alt]="achievement.title">
      <div class="lock-overlay" *ngIf="!achievement.isUnlocked">
        <i class="fas fa-lock"></i>
      </div>
      <div class="badge-shine" *ngIf="achievement.isUnlocked"></div>
    </div>

    <h2 class="modal-title">{{achievement.title}}</h2>
    <p class="modal-description">{{achievement.description}}</p>

    <div class="modal-details">
      <div class="detail-item">
        <i class="fas fa-star"></i>
        <span>{{achievement.points}} نقطة</span>
      </div>

      <div class="detail-item" *ngIf="achievement.isUnlocked && achievement.dateUnlocked">
        <i class="fas fa-calendar-check"></i>
        <span>تم الحصول: {{achievement.dateUnlocked | date:'shortDate'}}</span>
      </div>

      <div class="detail-item" *ngIf="!achievement.isUnlocked">
        <i class="fas fa-tasks"></i>
        <span>المطلوب: {{getRequirementText(achievement)}}</span>
      </div>
    </div>

    <div class="achievement-progress" *ngIf="!achievement.isUnlocked">
      <div class="progress-bar">
        <div class="progress-fill" [style.width.%]="achievement.progress"></div>
      </div>
      <span class="progress-percentage">{{achievement.progress}}%</span>
    </div>

    <div class="modal-actions">
      <button class="modal-button close" (click)="onClose()">إغلاق</button>
      <button *ngIf="achievement.isUnlocked" class="modal-button share"
        (click)="onShare(achievement)">
        <i class="fas fa-share-alt"></i> مشاركة
      </button>
    </div>
  </div>
</app-modal>
```

**achievement-details-modal.component.scss**: 
Copy relevant styles from achievements.component.scss for the achievement modal.

## Updated Main AchievementsComponent

Now, here's how you should update the main achievements component to use these new components:

**achievements.component.html**:
```html
<div class="achievements-container" dir="rtl">
  <!-- Particles Background for Game Feel -->
  <div class="particles-container">
    <div class="particle" *ngFor="let i of [1,2,3,4,5,6,7,8,9,10]"></div>
  </div>

  <!-- Header Section with Stats -->
  <app-achievement-header 
    [totalPoints]="totalPoints"
    [progressPercentage]="progressPercentage"
    [unlockedCount]="unlockedCount"
    [totalCount]="totalCount">
  </app-achievement-header>

  <!-- Tab Navigation -->
  <div class="tabs-container">
    <div class="tab-buttons">
      <button class="tab-button" [class.active]="activeTab === 'all'" (click)="setActiveTab('all')">
        <i class="fas fa-trophy"></i>
        <span>الإنجازات</span>
      </button>

      <button class="tab-button" [class.active]="activeTab === 'badges'" (click)="setActiveTab('badges')">
        <i class="fas fa-medal"></i>
        <span>الأوسمة</span>
      </button>

      <button class="tab-button" [class.active]="activeTab === 'points'" (click)="setActiveTab('points')">
        <i class="fas fa-coins"></i>
        <span>النقاط</span>
      </button>

      <button class="tab-button" [class.active]="activeTab === 'collection'" (click)="setActiveTab('collection')">
        <i class="fas fa-book"></i>
        <span>المجموعة</span>
      </button>
    </div>
  </div>

  <!-- Main Content Area -->
  <div class="content-area">
    <!-- Achievements View -->
    <app-achievement-list 
      *ngIf="activeTab === 'all'"
      [achievements]="getFilteredAchievements()" 
      [achievementSlideOffset]="achievementSlideOffset"
      [currentAchievementPage]="currentAchievementPage"
      [totalAchievementPages]="totalAchievementPages"
      (showDetails)="showAchievementDetails($event)"
      (previous)="previousAchievementPage()"
      (next)="nextAchievementPage()"
      (goToPage)="goToAchievementPage($event)">
    </app-achievement-list>

    <!-- Badges Collection View -->
    <app-badges-collection 
      *ngIf="activeTab === 'badges'"
      [lessonAchievements]="getLessonsCompletedAchievements()"
      [scoreAchievements]="getScoreAchievements()"
      [streakAchievements]="getStreakAchievements()"
      [categorySlideOffset]="categorySlideOffset"
      [currentCategoryPage]="currentCategoryPage"
      [totalCategoryPages]="totalCategoryPages"
      (showDetails)="showAchievementDetails($event)"
      (previous)="previousCategoryPage()"
      (next)="nextCategoryPage()"
      (goToPage)="goToCategoryPage($event)">
    </app-badges-collection>

    <!-- Points History View -->
    <app-points-history 
      *ngIf="activeTab === 'points'"
      [earnedPoints]="getEarnedPoints()"
      [bonusPoints]="getBonusPoints()"
      [spentPoints]="getSpentPoints()"
      [activities]="recentActivities"
      [activitySlideOffset]="activitySlideOffset"
      [currentActivityPage]="currentActivityPage"
      [totalActivityPages]="totalActivityPages"
      (previous)="previousActivityPage()"
      (next)="nextActivityPage()"
      (goToPage)="goToActivityPage($event)">
    </app-points-history>

    <!-- Collection View (Keep this in main component) -->
    <div class="collection-view" *ngIf="activeTab === 'collection'" @fadeIn>
      <div class="collection-grid">
        <div *ngFor="let badge of collection" class="collection-item" [class.unlocked]="badge.isUnlocked"
          (click)="showBadgeDetails(badge)">
          <div class="badge-display">
            <img [src]="badge.image" [alt]="badge.title">
            <div class="lock-overlay" *ngIf="!badge.isUnlocked">
              <i class="fas fa-lock"></i>
            </div>
            <div class="rarity-indicator" [ngClass]="badge.rarity"></div>
          </div>
          <h3 class="badge-title">{{badge.title}}</h3>
          <div class="badge-rarity">{{getBadgeRarityLabel(badge.rarity)}}</div>
        </div>
      </div>
    </div>
  </div>

  <!-- Achievement Details Modal -->
  <app-achievement-details-modal
    [isOpen]="showModal"
    [achievement]="selectedAchievement"
    (close)="closeModal()"
    (share)="shareAchievement($event)">
  </app-achievement-details-modal>
</div>
```

## What to Delete

You should delete the corresponding HTML sections from the original achievements.component.html file and keep only:

1. The outer container
2. The particles background
3. The tabs container
4. The collection view section (unless you plan to extract that too later)

In the achievements.component.ts and achievements.component.scss files, you should keep the main logic and styles but move the component-specific methods to their respective new components.

After these changes, you'll have a much more maintainable code structure that makes it easier to work on specific parts of the UI independently.

## Yassin (2025-04-22T23:21)

give me the update scss for the components and if i need to refactor the ts of achimgivents itslef

## Claude (2025-04-22T23:23)

# Updated SCSS Files for Components and Main Component Refactoring

## 1. Main achievements.component.scss (Updated)

After extracting styles to individual components, the main SCSS file should maintain global container styles and the particles animation:

```scss
// src/app/features/gamification/achievements/achievements.component.scss
@use "sass:map";
@use 'variables' as vars;
@use 'mixins' as mix;

// Main Container
.achievements-container {
  width: 100%;
  height: 100vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  background: linear-gradient(to bottom right,
          map-get(vars.$colors, 'primary', 'dark'),
          darken(map-get(vars.$colors, 'primary', 'dark'), 10%));
  position: relative;
  padding: 0;

  // Add subtle Islamic pattern as background
  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-image: url('/assets/images/islamic-pattern-1-dark.svg');
    background-repeat: repeat;
    background-size: 700px 700px;
    opacity: 0.04;
    z-index: 0;
    pointer-events: none;
  }
}

// Particle Animation Background for Game Feel
.particles-container {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  overflow: hidden;
  z-index: 0;

  .particle {
    position: absolute;
    width: 6px;
    height: 6px;
    background: radial-gradient(circle, rgba(map-get(vars.$colors, 'accent', 'base'), 0.8) 0%, rgba(map-get(vars.$colors, 'accent', 'base'), 0) 70%);
    border-radius: 50%;
    opacity: 0;
    animation: float 8s infinite ease-in-out;

    @for $i from 1 through 10 {
      &:nth-child(#{$i}) {
        $size: random(8) + 2 + px;
        width: $size;
        height: $size;
        left: random(100) + 0%;
        top: random(100) + 0%;
        animation-delay: random(5000) + 0ms;
        animation-duration: (random(8) + 5) + s;
      }
    }
  }
}

@keyframes float {
  0%, 100% {
    transform: translateY(0) translateX(0);
    opacity: 0;
  }
  20% {
    opacity: 0.4;
  }
  50% {
    transform: translateY(-20px) translateX(10px);
    opacity: 0.7;
  }
  80% {
    opacity: 0.4;
  }
}

// Tab Navigation
.tabs-container {
  padding: 0 15px;
  position: relative;
  z-index: 1;
  margin-bottom: 15px;

  .tab-buttons {
    display: flex;
    background: rgba(0, 0, 0, 0.3);
    border-radius: 15px;
    padding: 5px;
    overflow-x: auto;
    scrollbar-width: none;

    &::-webkit-scrollbar {
      display: none;
    }

    .tab-button {
      flex: 1;
      background: transparent;
      border: none;
      color: map-get(vars.$colors, 'text', 'muted');
      padding: 12px 15px;
      border-radius: 10px;
      font-size: 0.9rem;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      transition: all 0.3s cubic-bezier(0.22, 1, 0.36, 1);
      min-width: 100px;

      i {
        font-size: 1.1rem;
      }

      &:hover {
        color: map-get(vars.$colors, 'text', 'light');
        background: rgba(255, 255, 255, 0.05);
      }

      &.active {
        color: map-get(vars.$colors, 'primary', 'dark');
        background: linear-gradient(135deg,
                map-get(vars.$colors, 'accent', 'base'),
                map-get(vars.$colors, 'accent', 'bright'));
        font-weight: 600;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        transform: translateY(-2px);

        i {
          color: map-get(vars.$colors, 'primary', 'dark');
        }
      }
    }
  }
}

// Content Area
.content-area {
  flex: 1;
  padding: 0 15px 15px;
  position: relative;
  z-index: 1;
  overflow: hidden;
}

// Collection View (Kept in main component)
.collection-view {
  height: 100%;
  overflow: hidden;

  .collection-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
    justify-content: center;
    max-height: 100%;
    overflow-y: auto;
    padding: 10px 0;
    -ms-overflow-style: none;
    scrollbar-width: none;

    &::-webkit-scrollbar {
      display: none;
    }

    .collection-item {
      width: 150px;
      background: rgba(255, 255, 255, 0.05);
      border-radius: 15px;
      padding: 15px;
      display: flex;
      flex-direction: column;
      align-items: center;
      cursor: pointer;
      transition: all 0.3s ease;
      position: relative;

      &:hover {
        transform: translateY(-5px);
        background: rgba(255, 255, 255, 0.1);
      }

      .badge-display {
        width: 100px;
        height: 100px;
        position: relative;
        margin-bottom: 10px;

        img {
          width: 100%;
          height: 100%;
          object-fit: contain;
          filter: grayscale(80%) brightness(50%);
          transition: all 0.3s ease;
        }

        .lock-overlay {
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          display: flex;
          align-items: center;
          justify-content: center;
          background: rgba(0, 0, 0, 0.5);
          border-radius: 50%;

          i {
            font-size: 28px;
            color: rgba(255, 255, 255, 0.7);
          }
        }

        .rarity-indicator {
          position: absolute;
          top: -5px;
          right: -5px;
          width: 25px;
          height: 25px;
          border-radius: 50%;
          border: 2px solid rgba(255, 255, 255, 0.3);

          &.common {
            background: #95a5a6;
          }

          &.uncommon {
            background: #2ecc71;
          }

          &.rare {
            background: #3498db;
          }

          &.epic {
            background: #9b59b6;
          }

          &.legendary {
            background: map-get(vars.$colors, 'accent', 'base');
            box-shadow: 0 0 10px rgba(map-get(vars.$colors, 'accent', 'base'), 0.7);
          }
        }
      }

      .badge-title {
        font-size: 1rem;
        font-weight: 600;
        color: map-get(vars.$colors, 'text', 'muted');
        text-align: center;
        margin: 0 0 5px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .badge-rarity {
        font-size: 0.8rem;
        color: map-get(vars.$colors, 'text', 'muted');
      }

      &.unlocked {
        background: rgba(map-get(vars.$colors, 'primary', 'base'), 0.2);
        box-shadow: 0 5px 20px rgba(0, 0, 0, 0.3);

        .badge-display img {
          filter: grayscale(0%) brightness(100%);
          transform: scale(1.05);
        }

        .badge-title {
          color: map-get(vars.$colors, 'text', 'light');
        }

        .badge-rarity {
          color: map-get(vars.$colors, 'accent', 'base');
        }
      }
    }
  }
}

// Shared carousel styles
.carousel-indicators {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin-top: 15px;

  .indicator {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.2);
    cursor: pointer;
    transition: all 0.3s ease;

    &.active {
      background: map-get(vars.$colors, 'accent', 'base');
      transform: scale(1.2);
      box-shadow: 0 0 8px rgba(map-get(vars.$colors, 'accent', 'base'), 0.7);
    }

    &:hover {
      background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.5);
    }
  }
}
```

## 2. achievement-list.component.scss

```scss
@use "sass:map";
@use 'variables' as vars;

.achievements-view {
  height: 100%;

  .achievements-carousel {
    display: flex;
    align-items: center;
    height: calc(100% - 40px);
    width: 100%;

    .achievement-card-container {
      padding: 15px;
      flex: 0 0 300px;
      height: 100%;
      display: flex;
      cursor: pointer;
    }

    .achievement-card {
      flex: 1;
      background: rgba(255, 255, 255, 0.05);
      border-radius: 20px;
      padding: 20px;
      position: relative;
      overflow: hidden;
      transition: all 0.3s cubic-bezier(0.22, 1, 0.36, 1);
      display: flex;
      flex-direction: column;
      align-items: center;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);

      &:hover {
        transform: translateY(-10px);
      }

      &::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 5px;
        height: 100%;
      }

      // Card glow effect
      .card-glow {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: radial-gradient(circle at center,
                rgba(map-get(vars.$colors, 'accent', 'base'), 0.2) 0%,
                rgba(map-get(vars.$colors, 'accent', 'base'), 0) 70%);
        opacity: 0;
        transition: opacity 0.5s ease;

        &.active {
          opacity: 1;
        }
      }

      // Badge image
      .badge-image {
        width: 120px;
        height: 120px;
        position: relative;
        margin-bottom: 15px;

        img {
          width: 100%;
          height: 100%;
          object-fit: contain;
          transition: all 0.3s ease;
          filter: saturate(70%);
        }

        .lock-overlay {
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          display: flex;
          align-items: center;
          justify-content: center;
          background: rgba(0, 0, 0, 0.6);
          border-radius: 50%;

          i {
            font-size: 30px;
            color: rgba(255, 255, 255, 0.7);
          }
        }
      }

      // Achievement info
      .achievement-info {
        width: 100%;
        text-align: center;

        .achievement-title {
          font-size: 1.2rem;
          font-weight: 600;
          color: map-get(vars.$colors, 'text', 'light');
          margin: 0 0 15px;
          height: 3rem;
          display: flex;
          align-items: center;
          justify-content: center;
        }

        .achievement-progress {
          width: 100%;
          margin-bottom: 10px;

          .progress-bar {
            height: 6px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 3px;
            overflow: hidden;
            margin-bottom: 5px;

            .progress-fill {
              height: 100%;
              background: rgba(255, 255, 255, 0.3);
              border-radius: 3px;
              transition: width 0.5s cubic-bezier(0.22, 1, 0.36, 1);
            }
          }

          .progress-text {
            font-size: 0.8rem;
            color: map-get(vars.$colors, 'text', 'muted');
            text-align: center;
          }
        }

        .achievement-completed {
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
          color: #27AE60;
          font-weight: 600;
          margin-bottom: 10px;

          i {
            font-size: 1.2rem;
          }
        }
      }

      // Points indicator
      .achievement-points {
        position: absolute;
        bottom: 15px;
        right: 15px;
        background: rgba(0, 0, 0, 0.3);
        border-radius: 20px;
        padding: 5px 12px;
        display: flex;
        align-items: center;
        gap: 5px;

        i {
          color: map-get(vars.$colors, 'accent', 'base');
          font-size: 0.8rem;
        }

        span {
          color: map-get(vars.$colors, 'text', 'light');
          font-weight: 600;
          font-size: 1rem;
        }
      }

      &.unlocked {
        background: linear-gradient(135deg,
                rgba(map-get(vars.$colors, 'primary', 'base'), 0.4),
                rgba(map-get(vars.$colors, 'primary', 'base'), 0.2));
        box-shadow: 0 10px 30px rgba(map-get(vars.$colors, 'accent', 'base'), 0.15);

        .badge-image img {
          filter: saturate(100%) drop-shadow(0 10px 20px rgba(map-get(vars.$colors, 'accent', 'base'), 0.4));
          transform: scale(1.05);
        }
      }

      // Category colors
      &.category-lessons::before {
        background: #27AE60;
        box-shadow: 0 0 20px rgba(39, 174, 96, 0.5);
      }

      &.category-score::before {
        background: #3498DB;
        box-shadow: 0 0 20px rgba(52, 152, 219, 0.5);
      }

      &.category-streak::before {
        background: #E67E22;
        box-shadow: 0 0 20px rgba(230, 126, 34, 0.5);
      }

      &.category-perfect::before {
        background: #9B59B6;
        box-shadow: 0 0 20px rgba(155, 89, 182, 0.5);
      }
    }
  }
}

// Carousel controls
.carousel-container {
  flex: 1;
  overflow: hidden;
  position: relative;
}

.carousel-track {
  display: flex;
  transition: transform 0.5s cubic-bezier(0.22, 1, 0.36, 1);
}

.carousel-nav {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: map-get(vars.$colors, 'text', 'light');
  font-size: U.2rem;
  transition: all 0.2s ease;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);

  &:hover {
    background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
    transform: scale(1.1);
  }

  &:active {
    transform: scale(0.95);
  }

  &.left {
    margin-left: 10px;
  }

  &.right {
    margin-right: 10px;
  }
}

.carousel-indicators {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin-top: 15px;

  .indicator {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.2);
    cursor: pointer;
    transition: all 0.3s ease;

    &.active {
      background: map-get(vars.$colors, 'accent', 'base');
      transform: scale(1.2);
      box-shadow: 0 0 8px rgba(map-get(vars.$colors, 'accent', 'base'), 0.7);
    }

    &:hover {
      background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.5);
    }
  }
}
```

## 3. badges-collection.component.scss

```scss
@use "sass:map";
@use 'variables' as vars;

.badges-view {
  height: 100%;

  .badges-carousel {
    display: flex;
    align-items: center;
    height: calc(100% - 40px);

    .badge-category {
      flex: 0 0 100%;
      height: 100%;
      padding: 0 20px;

      .category-header {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 20px;

        i {
          font-size: 1.8rem;
          color: map-get(vars.$colors, 'accent', 'base');
        }

        h2 {
          font-size: 1.5rem;
          color: map-get(vars.$colors, 'text', 'light');
          margin: 0;
        }
      }

      .badges-grid {
        display: flex;
        flex-wrap: wrap;
        gap: 20px;
        justify-content: center;

        .badge-item {
          width: 120px;
          display: flex;
          flex-direction: column;
          align-items: center;
          cursor: pointer;
          transition: all 0.3s ease;

          &:hover {
            transform: translateY(-5px);
          }

          .badge-display {
            width: 100px;
            height: 100px;
            position: relative;
            margin-bottom: 10px;

            img {
              width: 100%;
              height: 100%;
              object-fit: contain;
              transition: all 0.3s ease;
              filter: grayscale(50%) brightness(60%);
            }

            .lock-overlay {
              position: absolute;
              top: 0;
              left: 0;
              right: 0;
              bottom: 0;
              display: flex;
              align-items: center;
              justify-content: center;
              background: rgba(0, 0, 0, 0.4);
              border-radius: 50%;

              i {
                font-size: 24px;
                color: rgba(255, 255, 255, 0.7);
              }
            }

            .badge-glow {
              position: absolute;
              top: 0;
              left: 0;
              width: 100%;
              height: 100%;
              border-radius: 50%;
              box-shadow: 0 0 20px rgba(map-get(vars.$colors, 'accent', 'base'), 0.5);
              animation: pulse-glow 2s infinite;
            }
          }

          .badge-name {
            font-size: 0.9rem;
            color: map-get(vars.$colors, 'text', 'muted');
            text-align: center;
            margin: 0;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
          }

          &.unlocked {
            .badge-display img {
              filter: grayscale(0%) brightness(100%);
            }

            .badge-name {
              color: map-get(vars.$colors, 'text', 'light');
              font-weight: 600;
            }
          }
        }
      }
    }
  }
}

// Carousel controls
.carousel-container {
  flex: 1;
  overflow: hidden;
  position: relative;
}

.carousel-track {
  display: flex;
  transition: transform 0.5s cubic-bezier(0.22, 1, 0.36, 1);
}

.carousel-nav {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: map-get(vars.$colors, 'text', 'light');
  font-size: 1.2rem;
  transition: all 0.2s ease;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);

  &:hover {
    background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
    transform: scale(1.1);
  }

  &:active {
    transform: scale(0.95);
  }

  &.left {
    margin-left: 10px;
  }

  &.right {
    margin-right: 10px;
  }
}

.carousel-indicators {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin-top: 15px;

  .indicator {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.2);
    cursor: pointer;
    transition: all 0.3s ease;

    &.active {
      background: map-get(vars.$colors, 'accent', 'base');
      transform: scale(1.2);
      box-shadow: 0 0 8px rgba(map-get(vars.$colors, 'accent', 'base'), 0.7);
    }

    &:hover {
      background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.5);
    }
  }
}

@keyframes pulse-glow {
  0%, 100% {
    box-shadow: 0 0 20px rgba(map-get(vars.$colors, 'accent', 'base'), 0.5);
  }
  50% {
    box-shadow: 0 0 35px rgba(map-get(vars.$colors, 'accent', 'base'), 0.8);
  }
}
```

## 4. points-history.component.scss

```scss
@use "sass:map";
@use 'variables' as vars;

.points-view {
  height: 100%;
  display: flex;
  flex-direction: column;

  .points-summary {
    display: flex;
    justify-content: space-around;
    margin-bottom: 20px;

    .point-type {
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 15px;
      border-radius: 15px;
      width: 28%;
      backdrop-filter: blur(5px);
      transition: all 0.3s ease;

      &:hover {
        transform: translateY(-5px);
      }

      .point-icon {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 10px;

        i {
          font-size: 2rem;
        }
      }

      .point-info {
        text-align: center;

        .point-value {
          font-size: 1.5rem;
          font-weight: 700;
        }

        .point-label {
          font-size: 0.9rem;
          color: map-get(vars.$colors, 'text', 'muted');
        }
      }

      &.earned {
        background: rgba(39, 174, 96, 0.1);
        box-shadow: 0 5px 15px rgba(39, 174, 96, 0.2);

        .point-icon {
          background: rgba(39, 174, 96, 0.2);

          i {
            color: #27AE60;
          }
        }

        .point-value {
          color: #27AE60;
        }
      }

      &.bonus {
        background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.1);
        box-shadow: 0 5px 15px rgba(map-get(vars.$colors, 'accent', 'base'), 0.2);

        .point-icon {
          background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.2);

          i {
            color: map-get(vars.$colors, 'accent', 'base');
          }
        }

        .point-value {
          color: map-get(vars.$colors, 'accent', 'base');
        }
      }

      &.spent {
        background: rgba(192, 57, 43, 0.1);
        box-shadow: 0 5px 15px rgba(192, 57, 43, 0.2);

        .point-icon {
          background: rgba(192, 57, 43, 0.2);

          i {
            color: #C0392B;
          }
        }

        .point-value {
          color: #C0392B;
        }
      }
    }
  }

  .points-history {
    flex: 1;

    .history-title {
      font-size: 1.3rem;
      font-weight: 600;
      color: map-get(vars.$colors, 'text', 'light');
      margin: 0 0 15px;
      text-align: center;
    }

    .activity-carousel {
      display: flex;
      align-items: center;
      height: calc(100% - 80px);

      .activity-card {
        flex: 0 0 250px;
        height: 160px;
        margin: 0 10px;
        background: rgba(255, 255, 255, 0.05);
        border-radius: 15px;
        padding: 15px;
        backdrop-filter: blur(5px);
        transition: all 0.3s ease;
        cursor: pointer;

        &:hover {
          transform: translateY(-5px);
        }

        .activity-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 15px;

          .activity-icon {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;

            i {
              font-size: 1.5rem;
            }
          }

          .activity-points {
            display: flex;
            align-items: center;
            gap: 3px;
            font-size: 1.2rem;
            font-weight: 700;

            i {
              font-size: 0.9rem;
              margin-right: 2px;
            }
          }
        }

        .activity-title {
          font-size: 1.1rem;
          color: map-get(vars.$colors, 'text', 'light');
          margin-bottom: 15px;
          height: 50px;
          overflow: hidden;
          display: -webkit-box;
          -webkit-line-clamp: 2;
          line-clamp: 2;
          -webkit-box-orient: vertical;
        }

        .activity-footer {
          display: flex;
          justify-content: space-between;
          font-size: 0.8rem;
          color: map-get(vars.$colors, 'text', 'muted');
        }

        &.earned {
          border-right: 3px solid #27AE60;

          .activity-icon {
            background: rgba(39, 174, 96, 0.2);

            i {
              color: #27AE60;
            }
          }

          .activity-points {
            color: #27AE60;

            i {
              color: #27AE60;
            }
          }
        }

        &.bonus {
          border-right: 3px solid map-get(vars.$colors, 'accent', 'base');

          .activity-icon {
            background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.2);

            i {
              color: map-get(vars.$colors, 'accent', 'base');
            }
          }

          .activity-points {
            color: map-get(vars.$colors, 'accent', 'base');

            i {
              color: map-get(vars.$colors, 'accent', 'base');
            }
          }
        }

        &.spent {
          border-right: 3px solid #C0392B;

          .activity-icon {
            background: rgba(192, 57, 43, 0.2);

            i {
              color: #C0392B;
            }
          }

          .activity-points {
            color: #C0392B;

            i {
              color: #C0392B;
            }
          }
        }
      }
    }
  }
}

// Carousel controls
.carousel-container {
  flex: 1;
  overflow: hidden;
  position: relative;
}

.carousel-track {
  display: flex;
  transition: transform 0.5s cubic-bezier(0.22, 1, 0.36, 1);
}

.carousel-nav {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: map-get(vars.$colors, 'text', 'light');
  font-size: 1.2rem;
  transition: all 0.2s ease;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);

  &:hover {
    background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
    transform: scale(1.1);
  }

  &:active {
    transform: scale(0.95);
  }

  &.left {
    margin-left: 10px;
  }

  &.right {
    margin-right: 10px;
  }
}
```

## 5. achievement-details-modal.component.scss

```scss
@use "sass:map";
@use 'variables' as vars;

.achievement-modal {
  padding: 20px;
  text-align: center;
  position: relative;

  .modal-badge {
    width: 150px;
    height: 150px;
    margin: 0 auto 20px;
    position: relative;

    img {
      width: 100%;
      height: 100%;
      object-fit: contain;
      filter: drop-shadow(0 10px 20px rgba(0, 0, 0, 0.5));
    }

    .lock-overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      display: flex;
      align-items: center;
      justify-content: center;
      background: rgba(0, 0, 0, 0.5);
      border-radius: 50%;

      i {
        font-size: 40px;
        color: rgba(255, 255, 255, 0.7);
      }
    }

    .badge-shine {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: linear-gradient(45deg,
              rgba(255, 255, 255, 0) 0%,
              rgba(255, 255, 255, 0.5) 50%,
              rgba(255, 255, 255, 0) 100%);
      background-size: 200% 200%;
      animation: shine 3s infinite linear;
      pointer-events: none;
    }
  }

  .modal-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: map-get(vars.$colors, 'text', 'light');
    margin: 0 0 10px;
  }

  .modal-description {
    font-size: 1.1rem;
    color: map-get(vars.$colors, 'text', 'muted');
    margin: 0 0 20px;
  }

  .modal-details {
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin-bottom: 20px;

    .detail-item {
      display: flex;
      align-items: center;
      gap: 10px;

      i {
        width: 30px;
        height: 30px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.1);
        display: flex;
        align-items: center;
        justify-content: center;
        color: map-get(vars.$colors, 'accent', 'base');
      }

      span {
        color: map-get(vars.$colors, 'text', 'light');
      }
    }
  }

  .achievement-progress {
    margin-bottom: 20px;

    .progress-bar {
      height: 8px;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 4px;
      overflow: hidden;
      margin-bottom: 5px;

      .progress-fill {
        height: 100%;
        background: map-get(vars.$colors, 'accent', 'base');
        border-radius: 4px;
        transition: width 0.5s cubic-bezier(0.22, 1, 0.36, 1);
      }
    }

    .progress-percentage {
      font-size: 0.9rem;
      color: map-get(vars.$colors, 'text', 'muted');
      text-align: right;
    }
  }

  .modal-actions {
    display: flex;
    justify-content: center;
    gap: 15px;

    .modal-button {
      padding: 12px 25px;
      border-radius: 30px;
      border: none;
      font-size: 1rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s ease;

      &.close {
        background: rgba(255, 255, 255, 0.1);
        color: map-get(vars.$colors, 'text', 'light');

        &:hover {
          background: rgba(255, 255, 255, 0.2);
        }
      }

      &.share {
        background: map-get(vars.$colors, 'accent', 'base');
        color: map-get(vars.$colors, 'primary', 'dark');
        display: flex;
        align-items: center;
        gap: 8px;

        &:hover {
          background: map-get(vars.$colors, 'accent', 'bright');
          transform: translateY(-2px);
          box-shadow: 0 5px 15px rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
        }
      }
    }
  }
}

@keyframes shine {
  0% {
    background-position: -100% -100%;
  }
  100% {
    background-position: 100% 100%;
  }
}
```

## Updated AchievementsComponent TypeScript

The main AchievementsComponent needs refactoring to delegate responsibilities to child components:

```typescript
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
```

This refactored version of the component maintains all the business logic while delegating rendering responsibilities to the child components. The methods are organized into related groups (filtering, navigation, UI handling) for easier maintenance.

With this approach, you'll be able to work on one component at a time without touching the entire feature. For example, you can focus on enhancing just the AchievementListComponent without affecting the other components.

## Yassin (2025-04-22T23:25)

should i deleted compnents in C:\Users\Yassin Gamal\Documents\dev\projects\tajweed-app-\src\app\features\gamification\components

## Claude (2025-04-22T23:25)

No, you should not delete the components in `C:\Users\Yassin Gamal\Documents\dev\projects\tajweed-app-\src\app\features\gamification\components`. 

Those existing components (achievement-badge, points-card, user-score) are separate shared components that are likely used across different features in the gamification module. In fact, looking at your gamification.module.ts, they are explicitly exported:

```typescript
@NgModule({
  // ...
  exports: [
    UserScoreComponent,
    AchievementBadgeComponent,
    PointsCardComponent
  ]
})
```

This means they're designed to be reused in other parts of your application. 

The new components we're creating should go in a subdirectory specific to the achievements feature:
```
src/app/features/gamification/achievements/components/
```

This keeps the shared, reusable components separate from the components that are specific to the achievements feature, maintaining good organization in your codebase.
