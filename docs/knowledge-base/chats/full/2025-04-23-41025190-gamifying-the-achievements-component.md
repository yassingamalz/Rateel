# Gamifying the Achievements Component

- Link: https://claude.ai/chat/41025190-4351-4133-88ab-c5b1ddc1e544
- Creata: 2025-04-23T02:06:15.303631Z
- Aggiornata: 2025-04-23T02:12:08.243654Z

## Yassin (2025-04-23T02:06)

i want to enhacne the achimnets compnent to be more user frienldy and lovlery wihtout changing the other compoennts so change the tabs in it to feel  more gamifed

Rember that app is aminly used in landscap mode in mobile and scorlling is not prefred but right to left swapping is accepatable 

a commit messgae also

## Claude (2025-04-23T02:09)

Looking at your request, I'll enhance the achievements component tabs to make them more gamified and user-friendly, especially for landscape mode on mobile devices.

**Artifact: Enhanced Achievements Component SCSS** (`application/vnd.ant.code`, create)

```scss
// Enhanced Tab Navigation - Gamified Version
.tabs-container {
  padding: 0 15px;
  position: relative;
  z-index: 1;
  margin-bottom: 20px;

  .tab-buttons {
    display: flex;
    background: rgba(0, 0, 0, 0.3);
    border-radius: 15px;
    padding: 5px;
    overflow-x: auto;
    position: relative;
    
    // Game-like container style with glass effect
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3), 
                inset 0 1px 1px rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(map-get(vars.$colors, 'accent', 'base'), 0.15);
    
    // Hide scrollbar but keep functionality for landscape mode
    scrollbar-width: none;
    -ms-overflow-style: none;
    
    &::-webkit-scrollbar {
      display: none;
    }

    .tab-button {
      flex: 1;
      min-width: 110px;
      padding: 12px 15px;
      background: transparent;
      border: none;
      color: map-get(vars.$colors, 'text', 'muted');
      border-radius: 12px;
      font-size: 0.95rem;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      transition: all 0.3s cubic-bezier(0.22, 1, 0.36, 1);
      position: relative;
      overflow: hidden;
      margin: 0 2px;
      
      // Metallic inactive button feel - gaming style
      background: linear-gradient(to bottom,
        rgba(80, 80, 80, 0.1),
        rgba(20, 20, 20, 0.2));
      box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.3);
      
      i {
        font-size: 1.2rem;
        transition: all 0.3s ease;
        opacity: 0.8;
      }

      // Edge highlight for game-like appearance
      &::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 1px;
        background: rgba(255, 255, 255, 0.1);
      }

      &:hover {
        color: map-get(vars.$colors, 'text', 'light');
        transform: translateY(-1px);
        
        i {
          transform: scale(1.2);
          opacity: 1;
          color: map-get(vars.$colors, 'accent', 'base');
        }
      }

      &.active {
        color: map-get(vars.$colors, 'primary', 'dark');
        background: linear-gradient(135deg,
                map-get(vars.$colors, 'accent', 'base'),
                lighten(map-get(vars.$colors, 'accent', 'bright'), 5%));
        font-weight: 700;
        transform: translateY(-3px);
        
        // Enhanced shadow with golden glow
        box-shadow: 0 8px 15px rgba(0, 0, 0, 0.25), 
                    0 0 10px rgba(map-get(vars.$colors, 'accent', 'base'), 0.5);

        i {
          color: map-get(vars.$colors, 'primary', 'dark');
          transform: scale(1.3);
          opacity: 1;
          filter: drop-shadow(0 1px 1px rgba(0, 0, 0, 0.3));
        }
        
        // Add subtle pulse animation to active tab
        animation: tab-pulse 2s infinite;
        
        // Add shimmering light effect - like a treasure
        &::after {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: linear-gradient(45deg, 
            rgba(255, 255, 255, 0) 0%, 
            rgba(255, 255, 255, 0.1) 50%, 
            rgba(255, 255, 255, 0) 100%);
          background-size: 200% 200%;
          animation: shine 3s infinite linear;
        }
      }
    }
  }
  
  // Swipe hint for landscape mobile
  .swipe-hint {
    position: absolute;
    bottom: -15px;
    left: 50%;
    transform: translateX(-50%);
    font-size: 0.75rem;
    color: rgba(map-get(vars.$colors, 'text', 'muted'), 0.7);
    display: flex;
    align-items: center;
    gap: 5px;
    animation: fade-pulse 2s infinite;
    white-space: nowrap;
    
    i {
      font-size: 0.7rem;
    }
  }
}

// Game-like animations
@keyframes shine {
  0% {
    background-position: -200% -200%;
  }
  100% {
    background-position: 200% 200%;
  }
}

@keyframes tab-pulse {
  0%, 100% {
    box-shadow: 0 8px 15px rgba(0, 0, 0, 0.25), 
                0 0 10px rgba(map-get(vars.$colors, 'accent', 'base'), 0.5);
  }
  50% {
    box-shadow: 0 8px 15px rgba(0, 0, 0, 0.25), 
                0 0 20px rgba(map-get(vars.$colors, 'accent', 'base'), 0.7);
  }
}

@keyframes fade-pulse {
  0%, 100% {
    opacity: 0.5;
  }
  50% {
    opacity: 0.9;
  }
}

```

<details><summary>risultato tool</summary>

```
OK
```
</details>



Now let's update the HTML part to add the swipe hint for mobile users:

**Artifact: Enhanced Achievements Component HTML** (`application/vnd.ant.code`, create)

```html
<!-- Enhanced Tab Navigation with Gamified Style -->
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
  
  <!-- Swipe hint for mobile landscape mode -->
  <div class="swipe-hint" *ngIf="isMobile">
    <i class="fas fa-chevron-right"></i>
    <span>اسحب للتنقل بين التبويبات</span>
    <i class="fas fa-chevron-left"></i>
  </div>
</div>

```

<details><summary>risultato tool</summary>

```
OK
```
</details>



The enhancements I've made to the achievements component focus specifically on the tab navigation system, making it more gamified and user-friendly, especially for mobile landscape mode. Here's what I've improved:

### Visual Enhancements:
1. **Game-like tab buttons** with metallic gradient backgrounds, edge highlighting, and 3D effects that make them look like physical buttons in a game interface
2. **Active tab animations** including:
   - Golden glowing effect with pulsing shadows
   - Elevation transform (pushing the tab up slightly)
   - Shimmering light animation that resembles a treasure or reward
3. **Glass-effect container** with backdrop blur and subtle border glow

### Mobile Landscape Optimizations:
1. **Horizontal scrolling support** for the tabs container (with hidden scrollbar)
2. **Swipe hint indicator** that appears only on mobile devices
3. **Compact but touchable dimensions** for easy interaction on landscape orientation

### Interactive Improvements:
1. **Hover animations** that provide immediate visual feedback
2. **Scale transforms** for icons to create a playful, responsive feeling
3. **Smooth transitions** between states using cubic-bezier easing

These changes enhance the gamification aspect while maintaining the app's existing functionality and RTL support. The design scales well across different screen sizes and works particularly well in landscape mode by supporting horizontal scrolling rather than requiring vertical space.

Let me know if you'd like any adjustments to these enhancements!

## Yassin (2025-04-23T02:09)

i want the full html and scss and ts with the modification and the commit message polease

## Claude (2025-04-23T02:12)

I'll provide the complete files with all the modifications integrated, along with a commit message.

**Artifact: Complete achievements.component.html with Enhancements** (`application/vnd.ant.code`, create)

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

  <!-- Enhanced Tab Navigation -->
  <div class="tabs-container">
    <div class="tab-buttons" #tabsScroller (touchstart)="onTouchStart($event)" (touchmove)="onTouchMove($event)" (touchend)="onTouchEnd()">
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
    
    <!-- Swipe hint for mobile landscape mode -->
    <div class="swipe-hint" *ngIf="isMobile && showSwipeHint">
      <i class="fas fa-chevron-right"></i>
      <span>اسحب للتنقل بين التبويبات</span>
      <i class="fas fa-chevron-left"></i>
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
      (goToPage)="goToAchievementPage($event)"
      @tabTransition>
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
      (goToPage)="goToCategoryPage($event)"
      @tabTransition>
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
      (goToPage)="goToActivityPage($event)"
      @tabTransition>
    </app-points-history>

    <!-- Collection View (Keep this in main component) -->
    <div class="collection-view" *ngIf="activeTab === 'collection'" @tabTransition>
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

<details><summary>risultato tool</summary>

```
OK
```
</details>

**Artifact: Complete achievements.component.scss with Enhancements** (`application/vnd.ant.code`, create)

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
    0%,
    100% {
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

// Enhanced Tab Navigation - Gamified Version
.tabs-container {
  padding: 0 15px;
  position: relative;
  z-index: 1;
  margin-bottom: 20px;

  .tab-buttons {
    display: flex;
    background: rgba(0, 0, 0, 0.3);
    border-radius: 15px;
    padding: 5px;
    overflow-x: auto;
    position: relative;
    
    // Game-like container style with glass effect
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3), 
                inset 0 1px 1px rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(map-get(vars.$colors, 'accent', 'base'), 0.15);
    
    // Hide scrollbar but keep functionality for landscape mode
    scrollbar-width: none;
    -ms-overflow-style: none;
    
    &::-webkit-scrollbar {
      display: none;
    }

    .tab-button {
      flex: 1;
      min-width: 110px;
      padding: 12px 15px;
      background: transparent;
      border: none;
      color: map-get(vars.$colors, 'text', 'muted');
      border-radius: 12px;
      font-size: 0.95rem;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      transition: all 0.3s cubic-bezier(0.22, 1, 0.36, 1);
      position: relative;
      overflow: hidden;
      margin: 0 2px;
      
      // Metallic inactive button feel - gaming style
      background: linear-gradient(to bottom,
        rgba(80, 80, 80, 0.1),
        rgba(20, 20, 20, 0.2));
      box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.3);
      
      i {
        font-size: 1.2rem;
        transition: all 0.3s ease;
        opacity: 0.8;
      }

      // Edge highlight for game-like appearance
      &::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 1px;
        background: rgba(255, 255, 255, 0.1);
      }

      &:hover {
        color: map-get(vars.$colors, 'text', 'light');
        transform: translateY(-1px);
        
        i {
          transform: scale(1.2);
          opacity: 1;
          color: map-get(vars.$colors, 'accent', 'base');
        }
      }

      &.active {
        color: map-get(vars.$colors, 'primary', 'dark');
        background: linear-gradient(135deg,
                map-get(vars.$colors, 'accent', 'base'),
                lighten(map-get(vars.$colors, 'accent', 'bright'), 5%));
        font-weight: 700;
        transform: translateY(-3px);
        
        // Enhanced shadow with golden glow
        box-shadow: 0 8px 15px rgba(0, 0, 0, 0.25), 
                    0 0 10px rgba(map-get(vars.$colors, 'accent', 'base'), 0.5);

        i {
          color: map-get(vars.$colors, 'primary', 'dark');
          transform: scale(1.3);
          opacity: 1;
          filter: drop-shadow(0 1px 1px rgba(0, 0, 0, 0.3));
        }
        
        // Add subtle pulse animation to active tab
        animation: tab-pulse 2s infinite;
        
        // Add shimmering light effect - like a treasure
        &::after {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: linear-gradient(45deg, 
            rgba(255, 255, 255, 0) 0%, 
            rgba(255, 255, 255, 0.1) 50%, 
            rgba(255, 255, 255, 0) 100%);
          background-size: 200% 200%;
          animation: shine 3s infinite linear;
        }
      }
    }
  }
  
  // Swipe hint for landscape mobile
  .swipe-hint {
    position: absolute;
    bottom: -15px;
    left: 50%;
    transform: translateX(-50%);
    font-size: 0.75rem;
    color: rgba(map-get(vars.$colors, 'text', 'muted'), 0.7);
    display: flex;
    align-items: center;
    gap: 5px;
    animation: fade-pulse 2s infinite;
    white-space: nowrap;
    
    i {
      font-size: 0.7rem;
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

// Game-like animations
@keyframes shine {
  0% {
    background-position: -200% -200%;
  }
  100% {
    background-position: 200% 200%;
  }
}

@keyframes tab-pulse {
  0%, 100% {
    box-shadow: 0 8px 15px rgba(0, 0, 0, 0.25), 
                0 0 10px rgba(map-get(vars.$colors, 'accent', 'base'), 0.5);
  }
  50% {
    box-shadow: 0 8px 15px rgba(0, 0, 0, 0.25), 
                0 0 20px rgba(map-get(vars.$colors, 'accent', 'base'), 0.7);
  }
}

@keyframes fade-pulse {
  0%, 100% {
    opacity: 0.5;
  }
  50% {
    opacity: 0.9;
  }
}

```

<details><summary>risultato tool</summary>

```
OK
```
</details>

**Artifact: Complete achievements.component.ts with Enhancements** (`application/vnd.ant.code`, create)

```typescript
import { Component, OnInit, OnDestroy, ChangeDetectionStrategy, ChangeDetectorRef, HostListener, ViewChild, ElementRef } from '@angular/core';
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
    ]),
    trigger('tabTransition', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.95)' }),
        animate('400ms cubic-bezier(0.22, 1, 0.36, 1)', 
          style({ opacity: 1, transform: 'scale(1)' }))
      ])
    ])
  ]
})
export class AchievementsComponent implements OnInit, OnDestroy {
  @ViewChild('tabsScroller') tabsScroller!: ElementRef;

  // Current user data
  totalPoints: number = 0;
  achievements: Achievement[] = [];
  recentActivities: PointsActivity[] = [];
  collection: CollectionBadge[] = [];

  // UI state
  activeTab: 'all' | 'unlocked' | 'locked' | 'badges' | 'points' | 'collection' = 'all';
  isMobile = window.innerWidth <= 768;
  isLoading = true;
  showSwipeHint = true;

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

  // Touch handling for swipe
  private touchStartX: number = 0;
  private touchEndX: number = 0;
  private touchThreshold: number = 50;
  private swiped: boolean = false;

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

    // Hide swipe hint after 5 seconds
    setTimeout(() => {
      this.showSwipeHint = false;
      this.cdr.markForCheck();
    }, 5000);
  }

  @HostListener('window:resize', ['$event'])
  onResize() {
    this.screenWidth = window.innerWidth;
    this.screenHeight = window.innerHeight;
    this.isMobile = window.innerWidth <= 768;
    this.updateItemsPerPage();
    this.calculateTotalPages();
    this.calculateTotalActivityPages();
    this.resetCarouselPositions();
    this.cdr.markForCheck();
  }

  /**
   * Touch event handlers for tab swiping
   */
  onTouchStart(e: TouchEvent): void {
    this.touchStartX = e.touches[0].clientX;
  }

  onTouchMove(e: TouchEvent): void {
    this.touchEndX = e.touches[0].clientX;
    
    // If we have a scroller element and we're scrolling horizontally
    if (this.tabsScroller && this.tabsScroller.nativeElement) {
      // Let native scrolling behavior handle this if the tabs are scrollable
      const element = this.tabsScroller.nativeElement;
      const maxScrollLeft = element.scrollWidth - element.clientWidth;
      
      // Only prevent default if we're at the edges and need to switch tabs
      if ((element.scrollLeft <= 0 && this.touchEndX > this.touchStartX) || 
          (element.scrollLeft >= maxScrollLeft && this.touchEndX < this.touchStartX)) {
        e.preventDefault();
      }
    }
  }

  onTouchEnd(): void {
    if (Math.abs(this.touchStartX - this.touchEndX) > this.touchThreshold) {
      this.swiped = true;
      // Handle tab switching based on swipe direction
      if (this.touchEndX < this.touchStartX) {
        // Swipe right to left - next tab
        this.switchToNextTab();
      } else {
        // Swipe left to right - previous tab
        this.switchToPreviousTab();
      }
    }
    
    // Reset touch variables
    this.touchStartX = 0;
    this.touchEndX = 0;
  }
  
  /**
   * Helper to navigate to next/previous tabs
   */
  switchToNextTab(): void {
    const tabs = ['all', 'badges', 'points', 'collection'];
    const currentIndex = tabs.indexOf(this.activeTab);
    if (currentIndex < tabs.length - 1) {
      this.setActiveTab(tabs[currentIndex + 1] as any);
    }
  }
  
  switchToPreviousTab(): void {
    const tabs = ['all', 'badges', 'points', 'collection'];
    const currentIndex = tabs.indexOf(this.activeTab);
    if (currentIndex > 0) {
      this.setActiveTab(tabs[currentIndex - 1] as any);
    }
  }

  /**
   * Set the active tab
   */
  setActiveTab(tab: 'all' | 'unlocked' | 'locked' | 'badges' | 'points' | 'collection'): void {
    this.activeTab = tab;
    this.resetCarouselPositions();
    
    // Show swipe hint briefly when changing tabs
    if (this.isMobile && !this.swiped) {
      this.showSwipeHint = true;
      setTimeout(() => {
        this.showSwipeHint = false;
        this.cdr.markForCheck();
      }, 3000);
    }
    
    this.swiped = false;
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

<details><summary>risultato tool</summary>

```
OK
```
</details>

**Artifact: Commit Message** (`application/vnd.ant.code`, create)

```text
feat(gamification): enhance achievements tabs with gamified design

Improve user experience for the achievements component with gamified UI elements:

- Add game-style tab buttons with metallic gradients and edge highlights
- Implement interactive animations (shimmering, pulsing glow)
- Add right-to-left swipe navigation for landscape mobile mode
- Optimize for landscape orientation with horizontal tab scrolling
- Add temporary swipe hint for better discoverability
- Improve tab transitions with animated effects
- Support touch gestures with proper threshold detection
- Fix scrolling behavior for tab containers in mobile view

This update focuses on making the achievements component more engaging and user-friendly without changing the underlying functionality. The enhancements are optimized for landscape mode on mobile devices as specified.

```

<details><summary>risultato tool</summary>

```
OK
```
</details>



# Enhanced Achievements Component

I've completely transformed the achievements component with a gamified design that's specially optimized for landscape mobile usage. Here's what's been implemented:

## Key UI Improvements

1. **Game-style Tab Navigation:**
   - Metallic gradient buttons with 3D effects
   - Dynamic animations (shimmering gold effect, pulsing glow)
   - Button state transitions (inactive → hover → active)
   - Glass container effect with backdrop blur

2. **Mobile Landscape Optimizations:**
   - Horizontally scrollable tabs (no scrollbar)
   - RTL swipe navigation between tabs
   - Visual swipe hint that appears temporarily
   - Touch gesture support with proper threshold detection

3. **Transition Effects:**
   - Smooth tab content transitions with scale effects
   - Animated state changes when switching tabs
   - Pulsing active indicators for better visibility

## Technical Enhancements

1. **Touch Handling:**
   - Added touch event handlers for swipe gestures
   - Smart threshold detection to prevent accidental swipes
   - Edge detection for tab scrolling vs. tab switching

2. **Animation System:**
   - Added tab transition animations for content switching
   - Created keyframe animations for interactive elements
   - Implemented attention-guiding animations for active states

3. **Mobile Usability:**
   - Added temporarily appearing swipe hint
   - Optimized button sizes for touch targets
   - Improved visual hierarchy for landscape orientation

These changes greatly enhance the gamification aspect of the achievements component while maintaining its existing functionality and improving the mobile landscape experience.

The commit message details all the improvements and the reasoning behind the changes, focusing on the enhanced user experience for mobile landscape mode as requested.
