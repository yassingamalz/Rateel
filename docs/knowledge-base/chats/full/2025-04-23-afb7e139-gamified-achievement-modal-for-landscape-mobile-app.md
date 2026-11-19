# Gamified Achievement Modal for Landscape Mobile App

- Link: https://claude.ai/chat/afb7e139-a416-473b-990a-3488882c9030
- Creata: 2025-04-23T20:02:59.125893Z
- Aggiornata: 2025-04-23T20:45:12.300342Z

## Yassin (2025-04-23T20:03)

want to enhance the achviment detilas modal using the centrel modal system centrillzed that we have already in our app compnent to enhance it gmaified feeling and rembering the app is mainly used mainly in landscape mode in mobile and also the badges is very custom and i like how them are and want to make them show in them shape i attached to the chat two of them so i would like to make the user feel a a gamed and modern feeling give me the nehanced code of it

## Claude (2025-04-23T20:05)

# Enhanced Achievement Modal for Gamified Experience

I'll create an enhanced achievement details modal that leverages your centralized modal system while adding game-like elements and ensuring good landscape mode support. This will maintain your existing badge styling while adding more engaging visual effects.

Let's enhance your achievement details modal:

**Artifact: Enhanced Achievement Details Modal HTML** (`application/vnd.ant.code`, create)

```html
<!-- Enhanced achievement-details-modal.component.html with gamified elements -->
<app-modal [isOpen]="isOpen" (closed)="onClose()" size="md" [showCloseButton]="true" position="center" [customClass]="'achievement-modal-container'">
  <div class="achievement-modal" *ngIf="achievement" [class.unlocked]="achievement.isUnlocked">
    <!-- Animated particle container for celebratory effects -->
    <div class="particles-container" *ngIf="achievement.isUnlocked">
      <div class="particle" *ngFor="let i of [1,2,3,4,5,6,7,8,9,10]"></div>
    </div>

    <!-- Badge showcase with 3D-like effect -->
    <div class="badge-showcase">
      <div class="badge-image-container" [class.unlocked]="achievement.isUnlocked">
        <div class="badge-shadow"></div>
        <img [src]="getBadgeImage(achievement)" [alt]="achievement.title" class="badge-image">
        <div class="lock-overlay" *ngIf="!achievement.isUnlocked">
          <i class="fas fa-lock"></i>
        </div>
        <div class="badge-shine" *ngIf="achievement.isUnlocked"></div>
      </div>
      
      <!-- Type indicator ribbon -->
      <div class="type-ribbon" *ngIf="achievement.isUnlocked" 
           [ngClass]="achievement.type">
        {{getTypeName(achievement.type)}}
      </div>
    </div>

    <!-- Achievement info with modern game-like style -->
    <div class="achievement-info">
      <h2 class="achievement-title">{{achievement.title}}</h2>
      <p class="achievement-description">{{achievement.description}}</p>

      <!-- Details panel with glass morphism effect -->
      <div class="details-panel">
        <!-- Points indicator -->
        <div class="detail-row points-row">
          <div class="detail-icon">
            <i class="fas fa-star"></i>
          </div>
          <div class="detail-text">
            <span class="detail-value">{{achievement.points}}</span>
            <span class="detail-label">نقطة</span>
          </div>
        </div>

        <!-- Date unlocked row (if applicable) -->
        <div class="detail-row date-row" *ngIf="achievement.isUnlocked && achievement.dateUnlocked">
          <div class="detail-icon">
            <i class="fas fa-calendar-check"></i>
          </div>
          <div class="detail-text">
            <span class="detail-value">{{achievement.dateUnlocked | date:'shortDate'}}</span>
            <span class="detail-label">تاريخ الإنجاز</span>
          </div>
        </div>

        <!-- Requirement row (if not unlocked) -->
        <div class="detail-row requirement-row" *ngIf="!achievement.isUnlocked">
          <div class="detail-icon">
            <i class="fas fa-tasks"></i>
          </div>
          <div class="detail-text">
            <span class="detail-value">{{getRequirementText(achievement)}}</span>
            <span class="detail-label">المطلوب</span>
          </div>
        </div>
      </div>

      <!-- Progress bar for locked achievements -->
      <div class="achievement-progress" *ngIf="!achievement.isUnlocked">
        <div class="progress-bar">
          <div class="progress-fill" [style.width.%]="achievement.progress"></div>
          <div class="progress-glow"></div>
        </div>
        <div class="progress-info">
          <span class="progress-percentage">{{achievement.progress}}%</span>
          <span class="progress-status">{{getProgressStatus(achievement.progress)}}</span>
        </div>
      </div>

      <!-- Action buttons -->
      <div class="action-buttons">
        <button class="action-button close-button" (click)="onClose()">
          <i class="fas fa-times"></i>
          <span>إغلاق</span>
        </button>
        
        <button *ngIf="achievement.isUnlocked" class="action-button share-button" (click)="onShare(achievement)">
          <i class="fas fa-share-alt"></i>
          <span>مشاركة</span>
        </button>
      </div>
    </div>
  </div>
</app-modal>
```

<details><summary>risultato tool</summary>

```
OK
```
</details>

**Artifact: Enhanced Achievement Details Modal TypeScript** (`application/vnd.ant.code`, create)

```typescript
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy, OnInit } from '@angular/core';
import { Achievement } from '../../../services/gamification.service';
import { trigger, transition, style, animate, query, stagger } from '@angular/animations';
import { PlatformService } from '../../../../../core/services/platform.service';

@Component({
  selector: 'app-achievement-details-modal',
  standalone: false,
  templateUrl: './achievement-details-modal.component.html',
  styleUrls: ['./achievement-details-modal.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('particleAnimation', [
      transition(':enter', [
        query('.particle', [
          style({ opacity: 0, transform: 'scale(0) translateY(0)' }),
          stagger(50, [
            animate('1s cubic-bezier(0.175, 0.885, 0.32, 1.275)', 
              style({ opacity: 0.8, transform: 'scale(1) translateY(var(--random-y))' }))
          ])
        ], { optional: true })
      ])
    ]),
    trigger('badgeAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.7) translateY(30px)' }),
        animate('600ms cubic-bezier(0.175, 0.885, 0.32, 1.275)', 
          style({ opacity: 1, transform: 'scale(1) translateY(0)' }))
      ])
    ]),
    trigger('contentAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateY(30px)' }),
        animate('500ms 200ms cubic-bezier(0.175, 0.885, 0.32, 1.275)', 
          style({ opacity: 1, transform: 'translateY(0)' }))
      ])
    ])
  ]
})
export class AchievementDetailsModalComponent implements OnInit {
  @Input() isOpen: boolean = false;
  @Input() achievement: Achievement | null = null;

  @Output() close = new EventEmitter<void>();
  @Output() share = new EventEmitter<Achievement>();

  // Random array for accessing in template
  randomNumbers = Array(10).fill(0).map((_, i) => i);

  constructor(private platformService: PlatformService) {}

  ngOnInit(): void {
    // Generate CSS variables for random animations
    this.setRandomParticleStyles();
  }

  /**
   * Sets random CSS variables for particle animations
   */
  private setRandomParticleStyles(): void {
    const particlesContainer = document.querySelector('.particles-container');
    if (!particlesContainer) return;

    const particles = particlesContainer.querySelectorAll('.particle');
    particles.forEach(particle => {
      const randomX = (Math.random() * 200 - 100) + 'px';
      const randomY = (Math.random() * 200 - 100) + 'px';
      const randomSize = (Math.random() * 10 + 5) + 'px';
      const randomDelay = (Math.random() * 0.5) + 's';
      const randomDuration = (Math.random() * 2 + 2) + 's';
      
      const element = particle as HTMLElement;
      element.style.setProperty('--random-x', randomX);
      element.style.setProperty('--random-y', randomY);
      element.style.setProperty('--random-size', randomSize);
      element.style.setProperty('--random-delay', randomDelay);
      element.style.setProperty('--random-duration', randomDuration);
    });
  }

  getBadgeImage(achievement: Achievement): string {
    const badgeType = achievement.type || 'bronze';
    const status = achievement.isUnlocked ? 'unlocked' : 'locked';
    return `assets/images/badges/${badgeType}_${status}.png`;
  }

  getTypeName(type: string): string {
    switch(type) {
      case 'bronze': return 'برونزي';
      case 'silver': return 'فضي';
      case 'gold': return 'ذهبي';
      case 'platinum': return 'بلاتيني';
      case 'diamond': return 'ماسي';
      default: return type;
    }
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

  getProgressStatus(progress: number): string {
    if (progress < 25) return 'في البداية';
    if (progress < 50) return 'جاري التقدم';
    if (progress < 75) return 'قريبًا';
    if (progress < 100) return 'على وشك الإكمال';
    return 'مكتمل';
  }

  onClose(): void {
    this.platformService.vibrateSuccess().catch(() => {});
    this.close.emit();
  }

  onShare(achievement: Achievement): void {
    this.platformService.vibrateSuccess().catch(() => {});
    this.share.emit(achievement);
  }
}
```

<details><summary>risultato tool</summary>

```
OK
```
</details>

**Artifact: Enhanced Achievement Details Modal SCSS** (`application/vnd.ant.code`, create)

```scss
// Enhanced achievement-details-modal.component.scss with gamified elements
@use "sass:map";
@use 'variables' as vars;
@use 'mixins' as mix;

// Add custom class to modal container for specific styling
:host ::ng-deep .achievement-modal-container {
  .modal-container {
    // Ensure properly sized for landscape
    max-width: 800px;
    max-height: 90vh;
    
    // Enhanced gradient background
    background: linear-gradient(135deg, 
      rgba(map-get(vars.$colors, 'primary', 'dark'), 0.95), 
      rgba(map-get(vars.$colors, 'primary', 'base'), 0.95)
    );
    
    // Better shadow
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5),
                0 0 0 1px rgba(map-get(vars.$colors, 'accent', 'base'), 0.2),
                0 0 20px rgba(map-get(vars.$colors, 'accent', 'base'), 0.1);
    
    // Enhanced corners
    border-radius: 20px;
  }
  
  // Adjust overlay for more contrast
  .modal-overlay {
    background: rgba(0, 0, 0, 0.75);
    backdrop-filter: blur(6px);
  }
}

// Main modal content
.achievement-modal {
  position: relative;
  overflow: hidden;
  padding: 10px 0;
  display: flex;
  
  // Landscape-optimized layout
  flex-direction: row;
  align-items: center;
  justify-content: center;
  
  // Game-like background for unlocked badges
  &.unlocked {
    // Add subtle pattern
    &::before {
      content: '';
      position: absolute;
      inset: 0;
      background: radial-gradient(
        ellipse at center,
        rgba(map-get(vars.$colors, 'accent', 'base'), 0.1) 0%,
        transparent 70%
      );
      z-index: 0;
      opacity: 0.5;
      animation: pulse 4s infinite alternate;
      pointer-events: none;
    }
  }
}

// Particles for celebration effects
.particles-container {
  position: absolute;
  inset: 0;
  z-index: 0;
  pointer-events: none;
  overflow: hidden;
  
  .particle {
    position: absolute;
    top: 50%;
    left: 50%;
    width: var(--random-size, 10px);
    height: var(--random-size, 10px);
    background: radial-gradient(
      circle at center,
      rgba(map-get(vars.$colors, 'accent', 'glow'), 0.9) 0%,
      rgba(map-get(vars.$colors, 'accent', 'base'), 0) 80%
    );
    border-radius: 50%;
    animation: floatParticle var(--random-duration, 3s) var(--random-delay, 0s) infinite alternate;
    opacity: 0;
    
    // Create different particle colors
    &:nth-child(3n+1) {
      background: radial-gradient(
        circle at center,
        rgba(map-get(vars.$colors, 'accent', 'glow'), 0.8) 0%,
        rgba(map-get(vars.$colors, 'accent', 'base'), 0) 80%
      );
    }
    
    &:nth-child(3n+2) {
      background: radial-gradient(
        circle at center,
        rgba(map-get(vars.$colors, 'special', 'emerald'), 0.8) 0%,
        rgba(map-get(vars.$colors, 'special', 'emerald'), 0) 80%
      );
    }
    
    &:nth-child(3n+3) {
      background: radial-gradient(
        circle at center,
        rgba(255, 255, 255, 0.8) 0%,
        rgba(255, 255, 255, 0) 80%
      );
    }
  }
}

// Enhanced badge showcase section
.badge-showcase {
  position: relative;
  flex: 0 0 40%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
  z-index: 1;
  
  .badge-image-container {
    position: relative;
    width: 150px;
    height: 150px;
    margin-bottom: 15px;
    transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    animation: badgeFloat 5s infinite alternate ease-in-out;
    transform-style: preserve-3d;
    z-index: 2;
    
    // Shadow for 3D effect
    .badge-shadow {
      position: absolute;
      bottom: -20px;
      left: 0;
      width: 100%;
      height: 15px;
      background: rgba(0, 0, 0, 0.3);
      filter: blur(10px);
      border-radius: 50%;
      transform: rotateX(60deg);
      animation: shadowPulse 5s infinite alternate ease-in-out;
    }
    
    // Badge image with enhanced effects
    .badge-image {
      position: relative;
      width: 100%;
      height: 100%;
      object-fit: contain;
      transition: all 0.3s ease;
      filter: drop-shadow(0 10px 20px rgba(0, 0, 0, 0.5));
      z-index: 2;
      transform-style: preserve-3d;
      backface-visibility: hidden;
      animation: badgePulse 5s infinite alternate ease-in-out;
    }
    
    // Lock overlay for locked achievements
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
      z-index: 3;
      
      i {
        font-size: 40px;
        color: rgba(255, 255, 255, 0.7);
        animation: lockPulse 2s infinite alternate;
      }
    }
    
    // Shine effect for unlocked badges
    .badge-shine {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(
        135deg,
        rgba(255, 255, 255, 0) 0%,
        rgba(255, 255, 255, 0.4) 50%,
        rgba(255, 255, 255, 0) 100%
      );
      border-radius: 50%;
      z-index: 3;
      animation: shine 3s infinite linear;
      pointer-events: none;
    }
    
    // Scale up on hover for interactivity
    &:hover {
      transform: scale(1.05) translateY(-5px);
      
      .badge-shadow {
        transform: rotateX(60deg) scale(1.05);
        opacity: 0.5;
      }
    }
    
    // Enhanced unlocked badge
    &.unlocked .badge-image {
      filter: drop-shadow(0 10px 20px rgba(map-get(vars.$colors, 'accent', 'base'), 0.5));
    }
  }
  
  // Type ribbon badge below the main badge
  .type-ribbon {
    padding: 8px 15px;
    border-radius: 15px;
    font-size: 0.9rem;
    font-weight: 600;
    color: map-get(vars.$colors, 'primary', 'dark');
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
    position: relative;
    z-index: 2;
    
    // Different styles for different badge types
    &.bronze {
      background: linear-gradient(135deg, #CD7F32, #e8a15c);
    }
    
    &.silver {
      background: linear-gradient(135deg, #C0C0C0, #e6e6e6);
    }
    
    &.gold {
      background: linear-gradient(135deg, map-get(vars.$colors, 'accent', 'dark'), map-get(vars.$colors, 'accent', 'bright'));
    }
    
    &.platinum {
      background: linear-gradient(135deg, #E5E4E2, #ffffff);
    }
    
    &.diamond {
      background: linear-gradient(135deg, #B9F2FF, #ffffff);
      box-shadow: 0 4px 10px rgba(185, 242, 255, 0.5);
    }
  }
}

// Right side info panel
.achievement-info {
  flex: 1;
  padding: 20px;
  display: flex;
  flex-direction: column;
  text-align: right;
  z-index: 1;
  max-width: 60%;
  
  // Enhanced title with decorative elements
  .achievement-title {
    font-size: 1.6rem;
    font-weight: 700;
    color: white;
    margin: 0 0 10px;
    position: relative;
    display: inline-block;
    padding-bottom: 5px;
    
    // Decorative underline
    &::after {
      content: '';
      position: absolute;
      bottom: 0;
      right: 0;
      width: 80%;
      height: 2px;
      background: linear-gradient(
        to left,
        map-get(vars.$colors, 'accent', 'base'),
        transparent
      );
    }
  }
  
  // Enhanced description
  .achievement-description {
    font-size: 1rem;
    line-height: 1.6;
    color: rgba(255, 255, 255, 0.8);
    margin: 0 0 20px;
  }
  
  // Modern glass-effect details panel
  .details-panel {
    background: rgba(0, 0, 0, 0.2);
    border-radius: 15px;
    padding: 15px;
    margin-bottom: 20px;
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.05);
    
    // Row for each detail item
    .detail-row {
      display: flex;
      align-items: center;
      gap: 15px;
      margin-bottom: 10px;
      
      &:last-child {
        margin-bottom: 0;
      }
      
      // Icon container
      .detail-icon {
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        flex-shrink: 0;
        
        i {
          font-size: 1.2rem;
        }
      }
      
      // Detail text container
      .detail-text {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        flex: 1;
        
        .detail-value {
          font-size: 1.1rem;
          font-weight: 600;
          color: white;
        }
        
        .detail-label {
          font-size: 0.8rem;
          color: rgba(255, 255, 255, 0.6);
        }
      }
      
      // Points row styling
      &.points-row {
        .detail-icon {
          background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.2);
          
          i {
            color: map-get(vars.$colors, 'accent', 'base');
          }
        }
      }
      
      // Date row styling
      &.date-row {
        .detail-icon {
          background: rgba(map-get(vars.$colors, 'special', 'emerald'), 0.2);
          
          i {
            color: map-get(vars.$colors, 'special', 'emerald');
          }
        }
      }
      
      // Requirement row styling
      &.requirement-row {
        .detail-icon {
          background: rgba(map-get(vars.$colors, 'text', 'muted'), 0.2);
          
          i {
            color: map-get(vars.$colors, 'text', 'muted');
          }
        }
      }
    }
  }
  
  // Enhanced progress bar
  .achievement-progress {
    margin-bottom: 20px;
    
    // Progress bar track
    .progress-bar {
      height: 8px;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 4px;
      overflow: hidden;
      position: relative;
      margin-bottom: 8px;
      
      // Progress bar fill
      .progress-fill {
        height: 100%;
        background: linear-gradient(to right,
          darken(map-get(vars.$colors, 'accent', 'base'), 10%),
          map-get(vars.$colors, 'accent', 'base')
        );
        border-radius: 4px;
        position: relative;
        transition: width 1s cubic-bezier(0.22, 1, 0.36, 1);
        
        // Animated shine effect
        &::after {
          content: '';
          position: absolute;
          top: 0;
          left: -100%;
          right: 0;
          bottom: 0;
          background: linear-gradient(90deg,
            rgba(255, 255, 255, 0) 0%,
            rgba(255, 255, 255, 0.3) 50%,
            rgba(255, 255, 255, 0) 100%);
          animation: shimmer 2s infinite linear;
        }
      }
      
      // Glowing edge
      .progress-glow {
        position: absolute;
        top: 0;
        left: 0;
        bottom: 0;
        width: 5px;
        background: map-get(vars.$colors, 'accent', 'glow');
        filter: blur(3px);
        border-radius: 4px;
        opacity: 0.8;
        animation: progressGlow 2s infinite alternate;
      }
    }
    
    // Progress info text
    .progress-info {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 0.9rem;
      
      .progress-percentage {
        font-weight: 600;
        color: map-get(vars.$colors, 'accent', 'base');
      }
      
      .progress-status {
        color: rgba(255, 255, 255, 0.7);
      }
    }
  }
  
  // Enhanced action buttons
  .action-buttons {
    display: flex;
    gap: 15px;
    margin-top: auto;
    justify-content: flex-end;
    
    // Base button style
    .action-button {
      padding: 10px 20px;
      border-radius: 25px;
      border: none;
      font-size: 0.95rem;
      font-weight: 600;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      
      i {
        font-size: 1rem;
      }
      
      &:active {
        transform: scale(0.95);
      }
      
      // Close button
      &.close-button {
        background: rgba(255, 255, 255, 0.1);
        color: white;
        
        &:hover {
          background: rgba(255, 255, 255, 0.2);
          transform: translateY(-2px);
        }
      }
      
      // Share button
      &.share-button {
        background: map-get(vars.$colors, 'accent', 'base');
        color: map-get(vars.$colors, 'primary', 'dark');
        padding-left: 15px;
        
        &:hover {
          background: map-get(vars.$colors, 'accent', 'bright');
          transform: translateY(-2px);
          box-shadow: 0 5px 15px rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
        }
      }
    }
  }
}

// Responsive styles for mobile landscape
@media (max-width: 768px), (max-height: 600px) {
  .achievement-modal {
    padding: 10px;
    
    // Improved layout for smaller screens
    .badge-showcase {
      flex: 0 0 35%;
      
      .badge-image-container {
        width: 120px;
        height: 120px;
      }
      
      .type-ribbon {
        padding: 6px 12px;
        font-size: 0.8rem;
      }
    }
    
    .achievement-info {
      padding: 10px;
      
      .achievement-title {
        font-size: 1.3rem;
      }
      
      .achievement-description {
        font-size: 0.9rem;
        margin-bottom: 15px;
        max-height: 60px;
        overflow-y: auto;
      }
      
      .details-panel {
        padding: 10px;
        margin-bottom: 15px;
        
        .detail-row {
          margin-bottom: 8px;
          
          .detail-icon {
            width: 32px;
            height: 32px;
            
            i {
              font-size: 1rem;
            }
          }
          
          .detail-text {
            .detail-value {
              font-size: 0.95rem;
            }
            
            .detail-label {
              font-size: 0.75rem;
            }
          }
        }
      }
      
      .achievement-progress {
        margin-bottom: 15px;
      }
      
      .action-buttons {
        .action-button {
          padding: 8px 15px;
          font-size: 0.85rem;
          
          i {
            font-size: 0.9rem;
          }
        }
      }
    }
  }
}

// Very small screens - stack vertically
@media (max-width: 480px) and (max-height: 400px) {
  .achievement-modal {
    flex-direction: column;
    padding: 10px 5px;
    
    .badge-showcase {
      padding: 10px 5px;
      flex: 0 0 auto;
      width: 100%;
      flex-direction: row;
      gap: 10px;
      
      .badge-image-container {
        width: 80px;
        height: 80px;
        margin-bottom: 0;
      }
    }
    
    .achievement-info {
      padding: 10px 5px;
      max-width: 100%;
      
      .achievement-title {
        font-size: 1.1rem;
      }
      
      .achievement-description {
        font-size: 0.8rem;
        margin-bottom: 10px;
        max-height: 40px;
      }
      
      .details-panel {
        display: flex;
        flex-wrap: wrap;
        gap: 5px;
        
        .detail-row {
          flex: 1 0 40%;
          margin-bottom: 0;
        }
      }
    }
  }
}

// Animations
@keyframes shine {
  0% {
    background-position: -200% -200%;
  }
  100% {
    background-position: 200% 200%;
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

@keyframes badgeFloat {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

@keyframes shadowPulse {
  0%, 100% {
    opacity: 0.3;
    transform: rotateX(60deg) scale(1);
  }
  50% {
    opacity: 0.2;
    transform: rotateX(60deg) scale(0.9);
  }
}

@keyframes badgePulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.03);
  }
}

@keyframes lockPulse {
  0% {
    opacity: 0.7;
    transform: scale(1);
  }
  100% {
    opacity: 0.9;
    transform: scale(1.1);
  }
}

@keyframes progressGlow {
  0% {
    opacity: 0.6;
    width: 5px;
  }
  100% {
    opacity: 0.9;
    width: 10px;
  }
}

@keyframes pulse {
  0%, 100% {
    opacity: 0.5;
  }
  50% {
    opacity: 0.8;
  }
}

@keyframes floatParticle {
  0% {
    transform: translate(calc(-50% + 0px), calc(-50% + 0px));
    opacity: 0;
  }
  30% {
    opacity: 0.8;
  }
  100% {
    transform: translate(calc(-50% + var(--random-x)), calc(-50% + var(--random-y)));
    opacity: 0;
  }
}
```

<details><summary>risultato tool</summary>

```
OK
```
</details>



Now that I've created the enhanced modal for your achievement system, let me explain what I've done and how it enhances the gamified feel of your application.

## Key Enhancements

### Visual Improvements

1. **3D Badge Display**
   - Badge now "floats" with subtle animations
   - Added drop shadow for depth perception
   - Animated shine effect for unlocked badges
   - Ribbon indicator showing badge type/quality

2. **Particle Effects**
   - Celebratory particles appear for unlocked achievements
   - Custom random patterns and colors based on your app's palette
   - Optimized for performance with CSS animations

3. **Game-like Animations**
   - Smooth entrance animations for all elements
   - Interactive hover effects
   - Pulsing effects for progress bars and locked achievements

4. **Islamic Design Integration**
   - Maintained the Islamic color scheme and design aesthetics
   - Used decorative gradients similar to Islamic art patterns
   - Right-to-left (RTL) optimized layout

### Landscape Mode Optimization

1. **Horizontal Layout**
   - Modal now uses a side-by-side layout optimized for landscape orientation
   - Badge on the left, details on the right (respecting RTL)
   - Responsive sizing that works well on mobile devices

2. **Smart Responsive Design**
   - Gracefully adapts to different screen sizes
   - Maintains usability in extreme aspect ratios
   - Special handling for very small screens with compact layout

3. **Touch-friendly Elements**
   - Larger tap targets for buttons
   - Improved spacing for touch interactions
   - Clear visual feedback on interactions

### Improved Information Display

1. **Glass-effect Details Panel**
   - Modern "glass morphism" style for the details section
   - Color-coded icons for different information types
   - Cleaner text organization

2. **Enhanced Progress Visualization**
   - Animated progress bar with glow effects
   - Progress status text that changes based on completion percentage
   - Visual cues for achievement progress

3. **Haptic Feedback Integration**
   - Added vibration feedback when closing or sharing achievements
   - Uses your existing platform service for consistency

## Implementation Details

- Used your existing modal system without modification
- Added custom class to allow specific styling without affecting other modals 
- Implemented detailed animations using Angular's animation system
- Added comprehensive responsive styles with specific breakpoints
- Ensured all elements respect RTL layout

This enhancement maintains your existing badge designs while adding modern game-like visual effects and animations to make achievement unlocks feel more rewarding. The layout is specifically optimized for landscape mode on mobile devices, which you mentioned is the primary usage mode for your app.

Would you like me to explain any specific aspect in more detail or make any adjustments to the implementation?

## Yassin (2025-04-23T20:09)

its very bad consider im using it mainly in mobile landscape mode 

also i want the same feeling of the feedbak modal i want the same feeling of getting the backgourng blurry but instead and use correclty the spaces

_file allegato (non incluso nell'export): image.png_

## Claude (2025-04-23T20:13)

I see the issue now that you've shared a screenshot. My design doesn't match your app's aesthetic and isn't well-optimized for your mobile landscape mode requirements. Let me create a redesigned version that:

1. Uses a blurry background like your feedback modal
2. Better matches your app's dark green and gold color scheme
3. Is properly optimized for mobile landscape viewing
4. Has a more game-like feel consistent with your UI

**Artifact update: enhanced-achievement-modal**

Sostituito:
```
<!-- Enhanced achievement-details-modal.component.html with gamified elements -->
<app-modal [isOpen]="isOpen" (closed)="onClose()" size="md" [showCloseButton]="true" position="center" [customClass]="'achievement-modal-container'">
  <div class="achievement-modal" *ngIf="achievement" [class.unlocked]="achievement.isUnlocked">
    <!-- Animated particle container for celebratory effects -->
    <div class="particles-container" *ngIf="achievement.isUnlocked">
      <div class="particle" *ngFor="let i of [1,2,3,4,5,6,7,8,9,10]"></div>
    </div>

    <!-- Badge showcase with 3D-like effect -->
    <div class="badge-showcase">
      <div class="badge-image-container" [class.unlocked]="achievement.isUnlocked">
        <div class="badge-shadow"></div>
        <img [src]="getBadgeImage(achievement)" [alt]="achievement.title" class="badge-image">
        <div class="lock-overlay" *ngIf="!achievement.isUnlocked">
          <i class="fas fa-lock"></i>
        </div>
        <div class="badge-shine" *ngIf="achievement.isUnlocked"></div>
      </div>
      
      <!-- Type indicator ribbon -->
      <div class="type-ribbon" *ngIf="achievement.isUnlocked" 
           [ngClass]="achievement.type">
        {{getTypeName(achievement.type)}}
      </div>
    </div>

    <!-- Achievement info with modern game-like style -->
    <div class="achievement-info">
      <h2 class="achievement-title">{{achievement.title}}</h2>
      <p class="achievement-description">{{achievement.description}}</p>

      <!-- Details panel with glass morphism effect -->
      <div class="details-panel">
        <!-- Points indicator -->
        <div class="detail-row points-row">
          <div class="detail-icon">
            <i class="fas fa-star"></i>
          </div>
          <div class="detail-text">
            <span class="detail-value">{{achievement.points}}</span>
            <span class="detail-label">نقطة</span>
          </div>
        </div>

        <!-- Date unlocked row (if applicable) -->
        <div class="detail-row date-row" *ngIf="achievement.isUnlocked && achievement.dateUnlocked">
          <div class="detail-icon">
            <i class="fas fa-calendar-check"></i>
          </div>
          <div class="detail-text">
            <span class="detail-value">{{achievement.dateUnlocked | date:'shortDate'}}</span>
            <span class="detail-label">تاريخ الإنجاز</span>
          </div>
        </div>

        <!-- Requirement row (if not unlocked) -->
        <div class="detail-row requirement-row" *ngIf="!achievement.isUnlocked">
          <div class="detail-icon">
            <i class="fas fa-tasks"></i>
          </div>
          <div class="detail-text">
            <span class="detail-value">{{getRequirementText(achievement)}}</span>
            <span class="detail-label">المطلوب</span>
          </div>
        </div>
      </div>

      <!-- Progress bar for locked achievements -->
      <div class="achievement-progress" *ngIf="!achievement.isUnlocked">
        <div class="progress-bar">
          <div class="progress-fill" [style.width.%]="achievement.progress"></div>
          <div class="progress-glow"></div>
        </div>
        <div class="progress-info">
          <span class="progress-percentage">{{achievement.progress}}%</span>
          <span class="progress-status">{{getProgressStatus(achievement.progress)}}</span>
        </div>
      </div>

      <!-- Action buttons -->
      <div class="action-buttons">
        <button class="action-button close-button" (click)="onClose()">
          <i class="fas fa-times"></i>
          <span>إغلاق</span>
        </button>
        
        <button *ngIf="achievement.isUnlocked" class="action-button share-button" (click)="onShare(achievement)">
          <i class="fas fa-share-alt"></i>
          <span>مشاركة</span>
        </button>
      </div>
    </div>
  </div>
</app-modal>
```

con:
```
<!-- Mobile-optimized achievement-details-modal with game-like UI -->
<div class="achievement-modal-wrapper" dir="rtl" [@modalAnimation] *ngIf="isOpen">
  <!-- Blurred overlay background -->
  <div class="modal-overlay" (click)="onClose()"></div>
  
  <!-- Game-style modal container -->
  <div class="achievement-card" [@contentAnimation] [class.unlocked]="achievement?.isUnlocked">
    <!-- Top section with title and close button -->
    <div class="achievement-header">
      <h2 class="achievement-title">{{ achievement?.title }}</h2>
      <button class="close-btn" (click)="onClose()">
        <i class="fas fa-times"></i>
      </button>
    </div>

    <!-- Main content in landscape layout -->
    <div class="achievement-content">
      <!-- Left side: Badge display -->
      <div class="badge-container">
        <!-- Golden ribbon for badge type -->
        <div class="badge-ribbon" *ngIf="achievement?.isUnlocked" [ngClass]="achievement?.type">
          {{ getTypeName(achievement?.type) }}
        </div>
        
        <!-- Badge image with effects -->
        <div class="badge-display" [class.unlocked]="achievement?.isUnlocked">
          <img [src]="getBadgeImage(achievement)" [alt]="achievement?.title">
          
          <!-- Lock overlay for locked achievements -->
          <div class="lock-overlay" *ngIf="!achievement?.isUnlocked">
            <i class="fas fa-lock"></i>
          </div>
          
          <!-- Shine effect for unlocked achievements -->
          <div class="shine-effect" *ngIf="achievement?.isUnlocked"></div>
          
          <!-- Floating particles -->
          <div class="particles" *ngIf="achievement?.isUnlocked">
            <span class="particle" *ngFor="let i of randomNumbers"></span>
          </div>
        </div>
      </div>

      <!-- Right side: Achievement details -->
      <div class="achievement-details">
        <!-- Description text -->
        <p class="achievement-description">{{ achievement?.description }}</p>
        
        <!-- Points badge -->
        <div class="points-badge">
          <i class="fas fa-star"></i>
          <span>{{ achievement?.points }} نقطة</span>
        </div>
        
        <!-- Date unlocked (for unlocked achievements) -->
        <div class="detail-item" *ngIf="achievement?.isUnlocked && achievement?.dateUnlocked">
          <i class="fas fa-calendar-check"></i>
          <span>تم الإنجاز: {{ achievement?.dateUnlocked | date:'shortDate' }}</span>
        </div>
        
        <!-- Requirements (for locked achievements) -->
        <div class="detail-item requirement" *ngIf="!achievement?.isUnlocked">
          <i class="fas fa-tasks"></i>
          <span>{{ getRequirementText(achievement) }}</span>
        </div>
        
        <!-- Progress bar (for locked achievements) -->
        <div class="progress-container" *ngIf="!achievement?.isUnlocked">
          <div class="progress-bar">
            <div class="progress-fill" [style.width.%]="achievement?.progress"></div>
          </div>
          <div class="progress-text">
            <span>{{ achievement?.progress }}%</span>
          </div>
        </div>
        
        <!-- Share button (for unlocked achievements) -->
        <button *ngIf="achievement?.isUnlocked" class="share-button" (click)="onShare(achievement)">
          <i class="fas fa-share-alt"></i>
          <span>مشاركة</span>
        </button>
      </div>
    </div>
  </div>
</div>
```

<details><summary>risultato tool</summary>

```
OK
```
</details>

**Artifact update: enhanced-achievement-modal-ts**

Sostituito:
```
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy, OnInit } from '@angular/core';
import { Achievement } from '../../../services/gamification.service';
import { trigger, transition, style, animate, query, stagger } from '@angular/animations';
import { PlatformService } from '../../../../../core/services/platform.service';

@Component({
  selector: 'app-achievement-details-modal',
  standalone: false,
  templateUrl: './achievement-details-modal.component.html',
  styleUrls: ['./achievement-details-modal.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('particleAnimation', [
      transition(':enter', [
        query('.particle', [
          style({ opacity: 0, transform: 'scale(0) translateY(0)' }),
          stagger(50, [
            animate('1s cubic-bezier(0.175, 0.885, 0.32, 1.275)', 
              style({ opacity: 0.8, transform: 'scale(1) translateY(var(--random-y))' }))
          ])
        ], { optional: true })
      ])
    ]),
    trigger('badgeAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.7) translateY(30px)' }),
        animate('600ms cubic-bezier(0.175, 0.885, 0.32, 1.275)', 
          style({ opacity: 1, transform: 'scale(1) translateY(0)' }))
      ])
    ]),
    trigger('contentAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateY(30px)' }),
        animate('500ms 200ms cubic-bezier(0.175, 0.885, 0.32, 1.275)', 
          style({ opacity: 1, transform: 'translateY(0)' }))
      ])
    ])
  ]
})
export class AchievementDetailsModalComponent implements OnInit {
  @Input() isOpen: boolean = false;
  @Input() achievement: Achievement | null = null;

  @Output() close = new EventEmitter<void>();
  @Output() share = new EventEmitter<Achievement>();

  // Random array for accessing in template
  randomNumbers = Array(10).fill(0).map((_, i) => i);

  constructor(private platformService: PlatformService) {}

  ngOnInit(): void {
    // Generate CSS variables for random animations
    this.setRandomParticleStyles();
  }

  /**
   * Sets random CSS variables for particle animations
   */
  private setRandomParticleStyles(): void {
    const particlesContainer = document.querySelector('.particles-container');
    if (!particlesContainer) return;

    const particles = particlesContainer.querySelectorAll('.particle');
    particles.forEach(particle => {
      const randomX = (Math.random() * 200 - 100) + 'px';
      const randomY = (Math.random() * 200 - 100) + 'px';
      const randomSize = (Math.random() * 10 + 5) + 'px';
      const randomDelay = (Math.random() * 0.5) + 's';
      const randomDuration = (Math.random() * 2 + 2) + 's';
      
      const element = particle as HTMLElement;
      element.style.setProperty('--random-x', randomX);
      element.style.setProperty('--random-y', randomY);
      element.style.setProperty('--random-size', randomSize);
      element.style.setProperty('--random-delay', randomDelay);
      element.style.setProperty('--random-duration', randomDuration);
    });
  }

  getBadgeImage(achievement: Achievement): string {
    const badgeType = achievement.type || 'bronze';
    const status = achievement.isUnlocked ? 'unlocked' : 'locked';
    return `assets/images/badges/${badgeType}_${status}.png`;
  }

  getTypeName(type: string): string {
    switch(type) {
      case 'bronze': return 'برونزي';
      case 'silver': return 'فضي';
      case 'gold': return 'ذهبي';
      case 'platinum': return 'بلاتيني';
      case 'diamond': return 'ماسي';
      default: return type;
    }
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

  getProgressStatus(progress: number): string {
    if (progress < 25) return 'في البداية';
    if (progress < 50) return 'جاري التقدم';
    if (progress < 75) return 'قريبًا';
    if (progress < 100) return 'على وشك الإكمال';
    return 'مكتمل';
  }

  onClose(): void {
    this.platformService.vibrateSuccess().catch(() => {});
    this.close.emit();
  }

  onShare(achievement: Achievement): void {
    this.platformService.vibrateSuccess().catch(() => {});
    this.share.emit(achievement);
  }
}
```

con:
```
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy, OnInit, ElementRef, AfterViewInit } from '@angular/core';
import { Achievement } from '../../../services/gamification.service';
import { trigger, transition, style, animate } from '@angular/animations';
import { PlatformService } from '../../../../../core/services/platform.service';

@Component({
  selector: 'app-achievement-details-modal',
  standalone: false,
  templateUrl: './achievement-details-modal.component.html',
  styleUrls: ['./achievement-details-modal.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('modalAnimation', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('300ms ease-out', style({ opacity: 1 }))
      ]),
      transition(':leave', [
        animate('200ms ease-in', style({ opacity: 0 }))
      ])
    ]),
    trigger('contentAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.9)' }),
        animate('400ms cubic-bezier(0.175, 0.885, 0.32, 1.275)', 
          style({ opacity: 1, transform: 'scale(1)' }))
      ])
    ])
  ]
})
export class AchievementDetailsModalComponent implements OnInit, AfterViewInit {
  @Input() isOpen: boolean = false;
  @Input() achievement: Achievement | null = null;

  @Output() close = new EventEmitter<void>();
  @Output() share = new EventEmitter<Achievement>();

  // Random array for accessing in template (for particles)
  randomNumbers: number[] = Array(10).fill(0).map((_, i) => i);

  constructor(
    private platformService: PlatformService,
    private elementRef: ElementRef
  ) {}

  ngOnInit(): void {
    if (this.isOpen && this.achievement?.isUnlocked) {
      // Add haptic feedback for unlocked achievements
      this.platformService.vibrateSuccess().catch(() => {});
    }
  }

  ngAfterViewInit(): void {
    // Set up particles after view is initialized
    if (this.achievement?.isUnlocked) {
      setTimeout(() => this.setupParticles(), 100);
    }
  }

  /**
   * Sets up particles with random properties
   */
  private setupParticles(): void {
    const particles = this.elementRef.nativeElement.querySelectorAll('.particle');
    if (!particles || particles.length === 0) return;

    particles.forEach((particle: HTMLElement) => {
      // Calculate random values for various properties
      const size = 3 + Math.random() * 8;
      const duration = 1 + Math.random() * 3;
      const delay = Math.random() * 0.5;
      const x1 = -20 + Math.random() * 40;
      const y1 = -30 + Math.random() * 60;
      const x2 = -40 + Math.random() * 80;
      const y2 = -60 + Math.random() * 120;
      
      // Apply random styles
      particle.style.width = `${size}px`;
      particle.style.height = `${size}px`;
      particle.style.animationDuration = `${duration}s`;
      particle.style.animationDelay = `${delay}s`;
      particle.style.setProperty('--x1', `${x1}px`);
      particle.style.setProperty('--y1', `${y1}px`);
      particle.style.setProperty('--x2', `${x2}px`);
      particle.style.setProperty('--y2', `${y2}px`);
      
      // Add random colors
      // Gold, light gold, and green to match app theme
      const colorClass = Math.random() > 0.7 ? 
                        (Math.random() > 0.5 ? 'gold' : 'light-gold') : 
                        'green';
      particle.classList.add(colorClass);
    });
  }

  getBadgeImage(achievement: Achievement | null): string {
    if (!achievement) return '';
    const badgeType = achievement.type || 'bronze';
    const status = achievement.isUnlocked ? 'unlocked' : 'locked';
    return `assets/images/badges/${badgeType}_${status}.png`;
  }

  getTypeName(type: string | undefined): string {
    if (!type) return '';
    
    switch(type) {
      case 'bronze': return 'برونزي';
      case 'silver': return 'فضي';
      case 'gold': return 'ذهبي';
      case 'platinum': return 'بلاتيني';
      case 'diamond': return 'ماسي';
      default: return type;
    }
  }

  getRequirementText(achievement: Achievement | null): string {
    if (!achievement) return '';
    
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
    // Add subtle haptic feedback when closing
    this.platformService.vibrateSuccess().catch(() => {});
    this.close.emit();
  }

  onShare(achievement: Achievement | null): void {
    if (!achievement) return;
    
    // Add haptic feedback when sharing
    this.platformService.vibrateSuccess().catch(() => {});
    this.share.emit(achievement);
  }
}
```

<details><summary>risultato tool</summary>

```
OK
```
</details>

**Artifact update: enhanced-achievement-modal-scss**

Sostituito:
```
// Enhanced achievement-details-modal.component.scss with gamified elements
@use "sass:map";
@use 'variables' as vars;
@use 'mixins' as mix;

// Add custom class to modal container for specific styling
:host ::ng-deep .achievement-modal-container {
  .modal-container {
    // Ensure properly sized for landscape
    max-width: 800px;
    max-height: 90vh;
    
    // Enhanced gradient background
    background: linear-gradient(135deg, 
      rgba(map-get(vars.$colors, 'primary', 'dark'), 0.95), 
      rgba(map-get(vars.$colors, 'primary', 'base'), 0.95)
    );
    
    // Better shadow
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5),
                0 0 0 1px rgba(map-get(vars.$colors, 'accent', 'base'), 0.2),
                0 0 20px rgba(map-get(vars.$colors, 'accent', 'base'), 0.1);
    
    // Enhanced corners
    border-radius: 20px;
  }
  
  // Adjust overlay for more contrast
  .modal-overlay {
    background: rgba(0, 0, 0, 0.75);
    backdrop-filter: blur(6px);
  }
}

// Main modal content
.achievement-modal {
  position: relative;
  overflow: hidden;
  padding: 10px 0;
  display: flex;
  
  // Landscape-optimized layout
  flex-direction: row;
  align-items: center;
  justify-content: center;
  
  // Game-like background for unlocked badges
  &.unlocked {
    // Add subtle pattern
    &::before {
      content: '';
      position: absolute;
      inset: 0;
      background: radial-gradient(
        ellipse at center,
        rgba(map-get(vars.$colors, 'accent', 'base'), 0.1) 0%,
        transparent 70%
      );
      z-index: 0;
      opacity: 0.5;
      animation: pulse 4s infinite alternate;
      pointer-events: none;
    }
  }
}

// Particles for celebration effects
.particles-container {
  position: absolute;
  inset: 0;
  z-index: 0;
  pointer-events: none;
  overflow: hidden;
  
  .particle {
    position: absolute;
    top: 50%;
    left: 50%;
    width: var(--random-size, 10px);
    height: var(--random-size, 10px);
    background: radial-gradient(
      circle at center,
      rgba(map-get(vars.$colors, 'accent', 'glow'), 0.9) 0%,
      rgba(map-get(vars.$colors, 'accent', 'base'), 0) 80%
    );
    border-radius: 50%;
    animation: floatParticle var(--random-duration, 3s) var(--random-delay, 0s) infinite alternate;
    opacity: 0;
    
    // Create different particle colors
    &:nth-child(3n+1) {
      background: radial-gradient(
        circle at center,
        rgba(map-get(vars.$colors, 'accent', 'glow'), 0.8) 0%,
        rgba(map-get(vars.$colors, 'accent', 'base'), 0) 80%
      );
    }
    
    &:nth-child(3n+2) {
      background: radial-gradient(
        circle at center,
        rgba(map-get(vars.$colors, 'special', 'emerald'), 0.8) 0%,
        rgba(map-get(vars.$colors, 'special', 'emerald'), 0) 80%
      );
    }
    
    &:nth-child(3n+3) {
      background: radial-gradient(
        circle at center,
        rgba(255, 255, 255, 0.8) 0%,
        rgba(255, 255, 255, 0) 80%
      );
    }
  }
}

// Enhanced badge showcase section
.badge-showcase {
  position: relative;
  flex: 0 0 40%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
  z-index: 1;
  
  .badge-image-container {
    position: relative;
    width: 150px;
    height: 150px;
    margin-bottom: 15px;
    transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    animation: badgeFloat 5s infinite alternate ease-in-out;
    transform-style: preserve-3d;
    z-index: 2;
    
    // Shadow for 3D effect
    .badge-shadow {
      position: absolute;
      bottom: -20px;
      left: 0;
      width: 100%;
      height: 15px;
      background: rgba(0, 0, 0, 0.3);
      filter: blur(10px);
      border-radius: 50%;
      transform: rotateX(60deg);
      animation: shadowPulse 5s infinite alternate ease-in-out;
    }
    
    // Badge image with enhanced effects
    .badge-image {
      position: relative;
      width: 100%;
      height: 100%;
      object-fit: contain;
      transition: all 0.3s ease;
      filter: drop-shadow(0 10px 20px rgba(0, 0, 0, 0.5));
      z-index: 2;
      transform-style: preserve-3d;
      backface-visibility: hidden;
      animation: badgePulse 5s infinite alternate ease-in-out;
    }
    
    // Lock overlay for locked achievements
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
      z-index: 3;
      
      i {
        font-size: 40px;
        color: rgba(255, 255, 255, 0.7);
        animation: lockPulse 2s infinite alternate;
      }
    }
    
    // Shine effect for unlocked badges
    .badge-shine {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(
        135deg,
        rgba(255, 255, 255, 0) 0%,
        rgba(255, 255, 255, 0.4) 50%,
        rgba(255, 255, 255, 0) 100%
      );
      border-radius: 50%;
      z-index: 3;
      animation: shine 3s infinite linear;
      pointer-events: none;
    }
    
    // Scale up on hover for interactivity
    &:hover {
      transform: scale(1.05) translateY(-5px);
      
      .badge-shadow {
        transform: rotateX(60deg) scale(1.05);
        opacity: 0.5;
      }
    }
    
    // Enhanced unlocked badge
    &.unlocked .badge-image {
      filter: drop-shadow(0 10px 20px rgba(map-get(vars.$colors, 'accent', 'base'), 0.5));
    }
  }
  
  // Type ribbon badge below the main badge
  .type-ribbon {
    padding: 8px 15px;
    border-radius: 15px;
    font-size: 0.9rem;
    font-weight: 600;
    color: map-get(vars.$colors, 'primary', 'dark');
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
    position: relative;
    z-index: 2;
    
    // Different styles for different badge types
    &.bronze {
      background: linear-gradient(135deg, #CD7F32, #e8a15c);
    }
    
    &.silver {
      background: linear-gradient(135deg, #C0C0C0, #e6e6e6);
    }
    
    &.gold {
      background: linear-gradient(135deg, map-get(vars.$colors, 'accent', 'dark'), map-get(vars.$colors, 'accent', 'bright'));
    }
    
    &.platinum {
      background: linear-gradient(135deg, #E5E4E2, #ffffff);
    }
    
    &.diamond {
      background: linear-gradient(135deg, #B9F2FF, #ffffff);
      box-shadow: 0 4px 10px rgba(185, 242, 255, 0.5);
    }
  }
}

// Right side info panel
.achievement-info {
  flex: 1;
  padding: 20px;
  display: flex;
  flex-direction: column;
  text-align: right;
  z-index: 1;
  max-width: 60%;
  
  // Enhanced title with decorative elements
  .achievement-title {
    font-size: 1.6rem;
    font-weight: 700;
    color: white;
    margin: 0 0 10px;
    position: relative;
    display: inline-block;
    padding-bottom: 5px;
    
    // Decorative underline
    &::after {
      content: '';
      position: absolute;
      bottom: 0;
      right: 0;
      width: 80%;
      height: 2px;
      background: linear-gradient(
        to left,
        map-get(vars.$colors, 'accent', 'base'),
        transparent
      );
    }
  }
  
  // Enhanced description
  .achievement-description {
    font-size: 1rem;
    line-height: 1.6;
    color: rgba(255, 255, 255, 0.8);
    margin: 0 0 20px;
  }
  
  // Modern glass-effect details panel
  .details-panel {
    background: rgba(0, 0, 0, 0.2);
    border-radius: 15px;
    padding: 15px;
    margin-bottom: 20px;
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.05);
    
    // Row for each detail item
    .detail-row {
      display: flex;
      align-items: center;
      gap: 15px;
      margin-bottom: 10px;
      
      &:last-child {
        margin-bottom: 0;
      }
      
      // Icon container
      .detail-icon {
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        flex-shrink: 0;
        
        i {
          font-size: 1.2rem;
        }
      }
      
      // Detail text container
      .detail-text {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        flex: 1;
        
        .detail-value {
          font-size: 1.1rem;
          font-weight: 600;
          color: white;
        }
        
        .detail-label {
          font-size: 0.8rem;
          color: rgba(255, 255, 255, 0.6);
        }
      }
      
      // Points row styling
      &.points-row {
        .detail-icon {
          background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.2);
          
          i {
            color: map-get(vars.$colors, 'accent', 'base');
          }
        }
      }
      
      // Date row styling
      &.date-row {
        .detail-icon {
          background: rgba(map-get(vars.$colors, 'special', 'emerald'), 0.2);
          
          i {
            color: map-get(vars.$colors, 'special', 'emerald');
          }
        }
      }
      
      // Requirement row styling
      &.requirement-row {
        .detail-icon {
          background: rgba(map-get(vars.$colors, 'text', 'muted'), 0.2);
          
          i {
            color: map-get(vars.$colors, 'text', 'muted');
          }
        }
      }
    }
  }
  
  // Enhanced progress bar
  .achievement-progress {
    margin-bottom: 20px;
    
    // Progress bar track
    .progress-bar {
      height: 8px;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 4px;
      overflow: hidden;
      position: relative;
      margin-bottom: 8px;
      
      // Progress bar fill
      .progress-fill {
        height: 100%;
        background: linear-gradient(to right,
          darken(map-get(vars.$colors, 'accent', 'base'), 10%),
          map-get(vars.$colors, 'accent', 'base')
        );
        border-radius: 4px;
        position: relative;
        transition: width 1s cubic-bezier(0.22, 1, 0.36, 1);
        
        // Animated shine effect
        &::after {
          content: '';
          position: absolute;
          top: 0;
          left: -100%;
          right: 0;
          bottom: 0;
          background: linear-gradient(90deg,
            rgba(255, 255, 255, 0) 0%,
            rgba(255, 255, 255, 0.3) 50%,
            rgba(255, 255, 255, 0) 100%);
          animation: shimmer 2s infinite linear;
        }
      }
      
      // Glowing edge
      .progress-glow {
        position: absolute;
        top: 0;
        left: 0;
        bottom: 0;
        width: 5px;
        background: map-get(vars.$colors, 'accent', 'glow');
        filter: blur(3px);
        border-radius: 4px;
        opacity: 0.8;
        animation: progressGlow 2s infinite alternate;
      }
    }
    
    // Progress info text
    .progress-info {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 0.9rem;
      
      .progress-percentage {
        font-weight: 600;
        color: map-get(vars.$colors, 'accent', 'base');
      }
      
      .progress-status {
        color: rgba(255, 255, 255, 0.7);
      }
    }
  }
  
  // Enhanced action buttons
  .action-buttons {
    display: flex;
    gap: 15px;
    margin-top: auto;
    justify-content: flex-end;
    
    // Base button style
    .action-button {
      padding: 10px 20px;
      border-radius: 25px;
      border: none;
      font-size: 0.95rem;
      font-weight: 600;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      
      i {
        font-size: 1rem;
      }
      
      &:active {
        transform: scale(0.95);
      }
      
      // Close button
      &.close-button {
        background: rgba(255, 255, 255, 0.1);
        color: white;
        
        &:hover {
          background: rgba(255, 255, 255, 0.2);
          transform: translateY(-2px);
        }
      }
      
      // Share button
      &.share-button {
        background: map-get(vars.$colors, 'accent', 'base');
        color: map-get(vars.$colors, 'primary', 'dark');
        padding-left: 15px;
        
        &:hover {
          background: map-get(vars.$colors, 'accent', 'bright');
          transform: translateY(-2px);
          box-shadow: 0 5px 15px rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
        }
      }
    }
  }
}

// Responsive styles for mobile landscape
@media (max-width: 768px), (max-height: 600px) {
  .achievement-modal {
    padding: 10px;
    
    // Improved layout for smaller screens
    .badge-showcase {
      flex: 0 0 35%;
      
      .badge-image-container {
        width: 120px;
        height: 120px;
      }
      
      .type-ribbon {
        padding: 6px 12px;
        font-size: 0.8rem;
      }
    }
    
    .achievement-info {
      padding: 10px;
      
      .achievement-title {
        font-size: 1.3rem;
      }
      
      .achievement-description {
        font-size: 0.9rem;
        margin-bottom: 15px;
        max-height: 60px;
        overflow-y: auto;
      }
      
      .details-panel {
        padding: 10px;
        margin-bottom: 15px;
        
        .detail-row {
          margin-bottom: 8px;
          
          .detail-icon {
            width: 32px;
            height: 32px;
            
            i {
              font-size: 1rem;
            }
          }
          
          .detail-text {
            .detail-value {
              font-size: 0.95rem;
            }
            
            .detail-label {
              font-size: 0.75rem;
            }
          }
        }
      }
      
      .achievement-progress {
        margin-bottom: 15px;
      }
      
      .action-buttons {
        .action-button {
          padding: 8px 15px;
          font-size: 0.85rem;
          
          i {
            font-size: 0.9rem;
          }
        }
      }
    }
  }
}

// Very small screens - stack vertically
@media (max-width: 480px) and (max-height: 400px) {
  .achievement-modal {
    flex-direction: column;
    padding: 10px 5px;
    
    .badge-showcase {
      padding: 10px 5px;
      flex: 0 0 auto;
      width: 100%;
      flex-direction: row;
      gap: 10px;
      
      .badge-image-container {
        width: 80px;
        height: 80px;
        margin-bottom: 0;
      }
    }
    
    .achievement-info {
      padding: 10px 5px;
      max-width: 100%;
      
      .achievement-title {
        font-size: 1.1rem;
      }
      
      .achievement-description {
        font-size: 0.8rem;
        margin-bottom: 10px;
        max-height: 40px;
      }
      
      .details-panel {
        display: flex;
        flex-wrap: wrap;
        gap: 5px;
        
        .detail-row {
          flex: 1 0 40%;
          margin-bottom: 0;
        }
      }
    }
  }
}

// Animations
@keyframes shine {
  0% {
    background-position: -200% -200%;
  }
  100% {
    background-position: 200% 200%;
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

@keyframes badgeFloat {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

@keyframes shadowPulse {
  0%, 100% {
    opacity: 0.3;
    transform: rotateX(60deg) scale(1);
  }
  50% {
    opacity: 0.2;
    transform: rotateX(60deg) scale(0.9);
  }
}

@keyframes badgePulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.03);
  }
}

@keyframes lockPulse {
  0% {
    opacity: 0.7;
    transform: scale(1);
  }
  100% {
    opacity: 0.9;
    transform: scale(1.1);
  }
}

@keyframes progressGlow {
  0% {
    opacity: 0.6;
    width: 5px;
  }
  100% {
    opacity: 0.9;
    width: 10px;
  }
}

@keyframes pulse {
  0%, 100% {
    opacity: 0.5;
  }
  50% {
    opacity: 0.8;
  }
}

@keyframes floatParticle {
  0% {
    transform: translate(calc(-50% + 0px), calc(-50% + 0px));
    opacity: 0;
  }
  30% {
    opacity: 0.8;
  }
  100% {
    transform: translate(calc(-50% + var(--random-x)), calc(-50% + var(--random-y)));
    opacity: 0;
  }
}
```

con:
```
// Mobile-optimized achievement-details-modal with game-like styling
@use "sass:map";
@use 'variables' as vars;
@use 'mixins' as mix;

// Modal wrapper - similar to feedback modal
.achievement-modal-wrapper {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  width: 100vw;
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 999999;
  pointer-events: auto;
  
  // Fixed positioning to ensure it stays on screen
  position: fixed !important;
  top: 0 !important;
  left: 0 !important;
  right: 0 !important;
  bottom: 0 !important;
}

// Blurred overlay
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  z-index: 1000000;
  animation: fadeIn 0.3s ease-out forwards;
}

// Main achievement card
.achievement-card {
  position: relative;
  z-index: 1000001;
  width: 95%;
  max-width: 600px;
  background: linear-gradient(to bottom,
    darken(map-get(vars.$colors, 'primary', 'base'), 10%),
    map-get(vars.$colors, 'primary', 'dark')
  );
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
  padding-bottom: 15px;
  
  // Add subtle pattern background
  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-image: url('/assets/images/islamic-pattern-1-dark.svg');
    background-repeat: repeat;
    background-size: 500px 500px;
    opacity: 0.04;
    z-index: 0;
    pointer-events: none;
  }
  
  // Gold border for unlocked achievements
  &.unlocked {
    border: 1px solid rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
    
    // Add subtle glow
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5),
                0 0 20px rgba(map-get(vars.$colors, 'accent', 'base'), 0.2);
  }
}

// Header with title and close button
.achievement-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: linear-gradient(to left,
    rgba(map-get(vars.$colors, 'accent', 'dark'), 0.2),
    rgba(map-get(vars.$colors, 'accent', 'base'), 0.1)
  );
  padding: 15px 20px;
  border-bottom: 1px solid rgba(map-get(vars.$colors, 'accent', 'base'), 0.15);
  position: relative;
  z-index: 1;
  
  // Title
  .achievement-title {
    font-size: 1.4rem;
    font-weight: 700;
    color: white;
    margin: 0;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
    flex: 1;
    text-align: right;
  }
  
  // Close button
  .close-btn {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.1);
    border: none;
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.2s ease;
    padding: 0;
    
    i {
      font-size: 0.9rem;
    }
    
    &:hover, &:active {
      background: rgba(255, 255, 255, 0.2);
      transform: scale(1.1);
    }
  }
}

// Content container optimized for landscape mode
.achievement-content {
  display: flex;
  padding: 15px;
  position: relative;
  z-index: 1;
  gap: 15px;
}

// Badge section (left side)
.badge-container {
  flex: 0 0 40%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
  
  // Badge display with 3D-like effects
  .badge-display {
    width: 140px;
    height: 140px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    margin-bottom: 10px;
    animation: floatBadge 4s infinite ease-in-out;
    
    // Badge image
    img {
      width: 100%;
      height: 100%;
      object-fit: contain;
      filter: drop-shadow(0 10px 15px rgba(0, 0, 0, 0.4));
      position: relative;
      z-index: 2;
      transition: all 0.3s ease;
    }
    
    // Lock overlay
    .lock-overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.5);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 3;
      
      i {
        font-size: 2.5rem;
        color: rgba(255, 255, 255, 0.7);
        animation: lockPulse 2s infinite alternate;
      }
    }
    
    // Shine effect for unlocked achievements
    .shine-effect {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(
        135deg,
        rgba(255, 255, 255, 0) 0%,
        rgba(255, 255, 255, 0.5) 50%,
        rgba(255, 255, 255, 0) 100%
      );
      z-index: 3;
      border-radius: 50%;
      animation: shine 3s infinite linear;
      opacity: 0.7;
      pointer-events: none;
    }
    
    // Particles for unlocked achievements
    .particles {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      z-index: 1;
      overflow: visible;
      pointer-events: none;
      
      .particle {
        position: absolute;
        top: 50%;
        left: 50%;
        width: 6px;
        height: 6px;
        border-radius: 50%;
        transform: translate(-50%, -50%);
        animation: particleFloatAway 3s infinite;
        
        // Colors for particles
        &.gold {
          background: radial-gradient(
            circle at center,
            rgba(map-get(vars.$colors, 'accent', 'base'), 0.9),
            rgba(map-get(vars.$colors, 'accent', 'base'), 0)
          );
        }
        
        &.light-gold {
          background: radial-gradient(
            circle at center,
            rgba(map-get(vars.$colors, 'accent', 'light'), 0.9),
            rgba(map-get(vars.$colors, 'accent', 'light'), 0)
          );
        }
        
        &.green {
          background: radial-gradient(
            circle at center,
            rgba(map-get(vars.$colors, 'special', 'emerald'), 0.9),
            rgba(map-get(vars.$colors, 'special', 'emerald'), 0)
          );
        }
      }
    }
    
    // Enhanced unlocked styles
    &.unlocked {
      img {
        filter: drop-shadow(0 10px 15px rgba(map-get(vars.$colors, 'accent', 'base'), 0.4));
      }
    }
  }
  
  // Badge type ribbon
  .badge-ribbon {
    padding: 6px 15px;
    border-radius: 15px;
    background: linear-gradient(
      to right,
      rgba(map-get(vars.$colors, 'accent', 'dark'), 0.9),
      rgba(map-get(vars.$colors, 'accent', 'base'), 0.9)
    );
    color: map-get(vars.$colors, 'primary', 'dark');
    font-size: 0.9rem;
    font-weight: 700;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.4);
    position: relative;
    z-index: 3;
    
    // Type-specific colors
    &.bronze {
      background: linear-gradient(
        to right,
        rgba(205, 127, 50, 0.9),
        rgba(232, 161, 92, 0.9)
      );
    }
    
    &.silver {
      background: linear-gradient(
        to right,
        rgba(192, 192, 192, 0.9),
        rgba(230, 230, 230, 0.9)
      );
    }
    
    &.gold {
      background: linear-gradient(
        to right,
        rgba(map-get(vars.$colors, 'accent', 'dark'), 0.9),
        rgba(map-get(vars.$colors, 'accent', 'light'), 0.9)
      );
    }
    
    &.platinum {
      background: linear-gradient(
        to right,
        rgba(229, 228, 226, 0.9),
        rgba(255, 255, 255, 0.9)
      );
      color: rgba(50, 50, 50, 0.9);
    }
    
    &.diamond {
      background: linear-gradient(
        to right,
        rgba(185, 242, 255, 0.9),
        rgba(240, 255, 255, 0.9)
      );
      color: rgba(50, 50, 50, 0.9);
    }
  }
}

// Details section (right side)
.achievement-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  text-align: right;
  position: relative;
  z-index: 1;
  
  // Description text
  .achievement-description {
    font-size: 0.95rem;
    line-height: 1.5;
    color: rgba(255, 255, 255, 0.9);
    margin: 0 0 15px;
  }
  
  // Points badge
  .points-badge {
    display: inline-flex;
    align-items: center;
    align-self: flex-end;
    gap: 8px;
    padding: 8px 15px;
    background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.15);
    border: 1px solid rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
    border-radius: 15px;
    margin-bottom: 12px;
    
    i {
      color: map-get(vars.$colors, 'accent', 'base');
      font-size: 1rem;
    }
    
    span {
      color: white;
      font-weight: 600;
    }
  }
  
  // Detail items
  .detail-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 8px 10px;
    background: rgba(0, 0, 0, 0.2);
    border-radius: 10px;
    margin-bottom: 10px;
    
    i {
      color: rgba(255, 255, 255, 0.7);
      font-size: 1rem;
    }
    
    span {
      color: rgba(255, 255, 255, 0.9);
      font-size: 0.9rem;
    }
    
    &.requirement {
      border-right: 3px solid rgba(map-get(vars.$colors, 'accent', 'base'), 0.5);
    }
  }
  
  // Progress container
  .progress-container {
    margin-bottom: 15px;
    
    .progress-bar {
      height: 8px;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 4px;
      overflow: hidden;
      position: relative;
      margin-bottom: 5px;
      
      .progress-fill {
        height: 100%;
        background: linear-gradient(
          to right,
          map-get(vars.$colors, 'accent', 'dark'),
          map-get(vars.$colors, 'accent', 'base')
        );
        border-radius: 4px;
        transition: width 1s cubic-bezier(0.22, 1, 0.36, 1);
        position: relative;
        
        // Animated shine
        &::after {
          content: '';
          position: absolute;
          top: 0;
          left: -100%;
          right: 0;
          bottom: 0;
          background: linear-gradient(
            to right,
            rgba(255, 255, 255, 0),
            rgba(255, 255, 255, 0.4),
            rgba(255, 255, 255, 0)
          );
          animation: progressShine 2s infinite linear;
        }
      }
    }
    
    .progress-text {
      display: flex;
      justify-content: flex-end;
      
      span {
        color: map-get(vars.$colors, 'accent', 'base');
        font-size: 0.8rem;
        font-weight: 600;
      }
    }
  }
  
  // Share button
  .share-button {
    align-self: flex-end;
    padding: 8px 15px;
    background: map-get(vars.$colors, 'accent', 'base');
    color: map-get(vars.$colors, 'primary', 'dark');
    border-radius: 20px;
    border: none;
    font-size: 0.9rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
    transition: all 0.2s ease;
    margin-top: auto;
    
    i {
      font-size: 0.9rem;
    }
    
    &:hover, &:active {
      background: map-get(vars.$colors, 'accent', 'light');
      transform: translateY(-2px);
    }
  }
}

// Small screens adaptations (extreme landscape)
@media (max-height: 450px) {
  .achievement-card {
    max-height: 85vh;
    overflow-y: auto;
  }
  
  .achievement-header {
    padding: 10px 15px;
    
    .achievement-title {
      font-size: 1.2rem;
    }
  }
  
  .achievement-content {
    padding: 10px;
  }
  
  .badge-container {
    flex: 0 0 35%;
    
    .badge-display {
      width: 120px;
      height: 120px;
      
      .lock-overlay i {
        font-size: 2rem;
      }
    }
    
    .badge-ribbon {
      padding: 4px 12px;
      font-size: 0.8rem;
    }
  }
  
  .achievement-details {
    .achievement-description {
      font-size: 0.85rem;
      margin-bottom: 10px;
      max-height: 80px;
      overflow-y: auto;
    }
    
    .points-badge {
      padding: 6px 12px;
      margin-bottom: 8px;
    }
    
    .detail-item {
      padding: 6px 8px;
      margin-bottom: 8px;
      
      span {
        font-size: 0.8rem;
      }
    }
    
    .progress-container {
      margin-bottom: 10px;
    }
    
    .share-button {
      padding: 6px 12px;
      font-size: 0.8rem;
    }
  }
}

// Very narrow screens
@media (max-width: 350px) {
  .achievement-content {
    flex-direction: column;
    
    .badge-container {
      margin-bottom: 15px;
    }
  }
}

// Animations
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes floatBadge {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-5px); }
}

@keyframes shine {
  0% { background-position: -200% -200%; }
  100% { background-position: 200% 200%; }
}

@keyframes lockPulse {
  0% { opacity: 0.7; transform: scale(1); }
  100% { opacity: 0.9; transform: scale(1.1); }
}

@keyframes progressShine {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

@keyframes particleFloatAway {
  0% {
    transform: translate(-50%, -50%) scale(0);
    opacity: 0;
  }
  20% {
    opacity: 0.8;
  }
  100% {
    transform: translate(calc(-50% + var(--x2)), calc(-50% + var(--y2))) scale(1);
    opacity: 0;
  }
}
```

<details><summary>risultato tool</summary>

```
OK
```
</details>



I've completely redesigned the achievement modal to match your app's aesthetic much better. This version is:

1. **Mobile-optimized for landscape mode** - Uses a horizontal layout that fits well on mobile screens
2. **Matches your app's design language** - Uses the dark green background with gold accents seen in your screenshot
3. **Uses a blurry background effect** - Similar to your feedback modal for consistency
4. **More compact and game-like** - Simplified with better space utilization

## Key Features of the New Design

### Overall Look & Feel
- Blurred background overlay for focus
- Dark green background with subtle Islamic pattern
- Gold accents for important elements
- Game-like animations and transitions

### Badge Display
- Centered, floating badge with subtle animation
- Type ribbon (bronze/silver/gold/etc.) below the badge
- Shine effect for unlocked badges
- Lock icon for locked achievements
- Particle effects for unlocked achievements

### Content Organization
- Clean header with achievement title
- Two-column layout for landscape orientation
- Important info prioritized for mobile viewing
- Progress bar for locked achievements
- Share button for unlocked achievements

### Mobile Optimizations
- Proper spacing for touch targets
- Scrollable content for very small screens
- Extra optimizations for narrow screens
- Landscape-first design approach

This design is much better aligned with your existing UI as shown in the screenshot. The achievement modal now feels like it belongs in your app with the same gamified styling and color scheme.

Would you like me to make any additional adjustments to the design?

## Yassin (2025-04-23T20:37)

want to enhance the achviment detilas modal using the centrel modal system centrillzed that we have already in our app compnent to enhance it gmaified feeling and rembering the app is mainly used mainly in landscape mode in mobile and also the badges is very custom and i like how them are and want to make them show in them shape i attached to the chat two of them so i would like to make the user feel a a gamed and modern feeling give me the nehanced code of it

also i want the same feeling of the feedbak modal i want the same feeling of getting the backgourng blurry but instead and use correclty the spaces

## Claude (2025-04-23T20:40)

# Enhancement of Achievement Details Modal

I'll create a more gamified achievement details modal that works well in landscape mode, preserves your custom badge styling, and creates a more immersive feeling with proper spacing and blurred backgrounds.

Let's enhance this to match the style of your feedback modal while making it more engaging:

**Artifact: Enhanced Achievement Details Modal (HTML)** (`application/vnd.ant.code`, create)

```html
<!-- Enhanced achievement-details-modal.component.html -->
<app-modal [isOpen]="isOpen" (closed)="onClose()" size="lg" [showCloseButton]="true" position="center" customClass="achievement-modal-container">
  <div class="achievement-modal" *ngIf="achievement" [@modalContentAnimation]>
    <!-- Particle Effects for Unlocked Achievements -->
    <div class="particles-container" *ngIf="achievement.isUnlocked">
      <div class="particle" *ngFor="let i of [1,2,3,4,5,6,7,8,9,10]"></div>
    </div>

    <!-- Main Content -->
    <div class="modal-content-wrapper">
      <!-- Left Side - Badge Display -->
      <div class="badge-showcase">
        <div class="badge-container" [class.unlocked]="achievement.isUnlocked">
          <img [src]="getBadgeImage(achievement)" [alt]="achievement.title" class="badge-image">
          
          <!-- Lock Overlay -->
          <div class="lock-overlay" *ngIf="!achievement.isUnlocked">
            <i class="fas fa-lock"></i>
          </div>
          
          <!-- Glow Effect for Unlocked Badges -->
          <div class="badge-glow" *ngIf="achievement.isUnlocked"></div>
          
          <!-- Shine Animation -->
          <div class="badge-shine" *ngIf="achievement.isUnlocked"></div>
        </div>
        
        <!-- Badge Type Indicator -->
        <div class="badge-type" [ngClass]="achievement.type">
          <span>{{ getBadgeTypeLabel(achievement.type) }}</span>
        </div>
        
        <!-- Points Display -->
        <div class="badge-points" *ngIf="achievement.isUnlocked">
          <i class="fas fa-star"></i>
          <span>{{ achievement.points }}</span>
        </div>
      </div>

      <!-- Right Side - Achievement Details -->
      <div class="achievement-details">
        <h2 class="achievement-title">{{ achievement.title }}</h2>
        
        <!-- Completion Status Banner -->
        <div class="completion-banner" *ngIf="achievement.isUnlocked">
          <i class="fas fa-check-circle animated-icon"></i>
          <span>تم الإنجاز</span>
        </div>
        
        <div class="achievement-description">
          <p>{{ achievement.description }}</p>
        </div>
        
        <!-- Details Section -->
        <div class="details-section">
          <!-- If Unlocked: Show completion date -->
          <div class="detail-item" *ngIf="achievement.isUnlocked && achievement.dateUnlocked">
            <i class="fas fa-calendar-check"></i>
            <span>تم الحصول: {{ achievement.dateUnlocked | date:'mediumDate' }}</span>
          </div>
          
          <!-- If Locked: Show requirement -->
          <div class="detail-item" *ngIf="!achievement.isUnlocked">
            <i class="fas fa-tasks"></i>
            <span>المطلوب: {{ getRequirementText(achievement) }}</span>
          </div>
          
          <!-- Always show points value -->
          <div class="detail-item">
            <i class="fas fa-award"></i>
            <span>القيمة: {{ achievement.points }} نقطة</span>
          </div>
          
          <!-- Rarity indicator -->
          <div class="detail-item">
            <i class="fas fa-gem"></i>
            <span>الندرة: {{ getRarityLevel(achievement.type) }}</span>
          </div>
        </div>
        
        <!-- Progress Bar (Only for locked achievements) -->
        <div class="achievement-progress" *ngIf="!achievement.isUnlocked">
          <div class="progress-container">
            <div class="progress-bar">
              <div class="progress-fill" [style.width.%]="achievement.progress"></div>
            </div>
            <div class="progress-text">{{ achievement.progress }}%</div>
          </div>
        </div>
        
        <!-- Action Buttons -->
        <div class="action-buttons">
          <button class="action-button close-button" (click)="onClose()">
            إغلاق
          </button>
          
          <button *ngIf="achievement.isUnlocked" class="action-button share-button" (click)="onShare(achievement)">
            <i class="fas fa-share-alt"></i>
            مشاركة
          </button>
        </div>
      </div>
    </div>
  </div>
</app-modal>
```

<details><summary>risultato tool</summary>

```
OK
```
</details>



Now let me create the enhanced styles for our achievement modal:

**Artifact: Enhanced Achievement Details Modal (SCSS)** (`application/vnd.ant.code`, create)

```scss
// Enhanced achievement-details-modal.component.scss
@use "sass:map";
@use 'variables' as vars;
@use 'mixins' as mix;

// Main modal enhancements to make app-modal look more gamified
::ng-deep .achievement-modal-container {
  .modal-overlay {
    // Better blur effect similar to feedback modal
    backdrop-filter: blur(10px) !important;
    -webkit-backdrop-filter: blur(10px) !important;
    background: rgba(0, 0, 0, 0.85) !important;
  }
  
  .modal-container {
    // Transparent background to use our own styling
    background: transparent !important;
    border: none !important;
    box-shadow: none !important;
    // Make sure we have enough space in landscape
    max-height: 95vh !important;
    max-width: 900px !important;
    width: 95% !important;
  }
  
  // Enhance the close button
  .modal-close-btn {
    background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.2) !important;
    color: map-get(vars.$colors, 'accent', 'base') !important;
    top: 10px !important;
    left: 10px !important;
    z-index: 100 !important;
    
    &:hover {
      background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.4) !important;
    }
  }
}

// Main achievement modal styling
.achievement-modal {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: hidden;
  
  // Particles container for animated effects
  .particles-container {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    pointer-events: none;
    z-index: 1;
    
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
  
  // Content wrapper with flexible layout
  .modal-content-wrapper {
    position: relative;
    z-index: 2;
    display: flex;
    flex-direction: row;
    width: 100%;
    height: 100%;
    padding: 20px;
    
    // Responsive layout for portrait mode (stacked)
    @media (max-width: 768px) and (orientation: portrait) {
      flex-direction: column;
      align-items: center;
      gap: 20px;
    }
  }
  
  // Left side - Badge showcase
  .badge-showcase {
    flex: 0 0 40%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 20px;
    position: relative;
    
    // Adjust for mobile portrait
    @media (max-width: 768px) and (orientation: portrait) {
      flex: 0 0 auto;
      width: 100%;
      padding: 10px;
    }
    
    // Container for badge image and effects
    .badge-container {
      width: 220px;
      height: 220px;
      position: relative;
      margin-bottom: 15px;
      display: flex;
      align-items: center;
      justify-content: center;
      
      // For small screens
      @media (max-height: 500px) {
        width: 150px;
        height: 150px;
      }
      
      // Badge image with enhanced styling
      .badge-image {
        width: 100%;
        height: 100%;
        object-fit: contain;
        transition: all 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        filter: drop-shadow(0 10px 20px rgba(0, 0, 0, 0.5));
        z-index: 2;
        animation: badgePulse 3s infinite alternate;
      }
      
      // Lock overlay for locked achievements
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
        z-index: 3;
        
        i {
          font-size: 50px;
          color: rgba(255, 255, 255, 0.7);
          filter: drop-shadow(0 2px 5px rgba(0, 0, 0, 0.5));
        }
      }
      
      // Glow effect for unlocked achievements
      .badge-glow {
        position: absolute;
        top: -10px;
        left: -10px;
        right: -10px;
        bottom: -10px;
        border-radius: 50%;
        background: radial-gradient(
          ellipse at center,
          rgba(map-get(vars.$colors, 'accent', 'base'), 0.5) 0%,
          rgba(map-get(vars.$colors, 'accent', 'base'), 0.2) 40%,
          rgba(map-get(vars.$colors, 'accent', 'base'), 0) 70%
        );
        z-index: 1;
        animation: glowPulse 3s infinite alternate;
      }
      
      // Shine effect overlay
      .badge-shine {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(
          45deg,
          rgba(255, 255, 255, 0) 0%,
          rgba(255, 255, 255, 0.3) 50%,
          rgba(255, 255, 255, 0) 100%
        );
        background-size: 200% 200%;
        z-index: 4;
        border-radius: 50%;
        pointer-events: none;
        animation: shine 3s infinite linear;
      }
      
      // When achievement is unlocked
      &.unlocked {
        .badge-image {
          filter: drop-shadow(0 10px 25px rgba(map-get(vars.$colors, 'accent', 'base'), 0.5));
          transform: scale(1.05);
        }
      }
    }
    
    // Badge type label
    .badge-type {
      background: rgba(0, 0, 0, 0.3);
      border-radius: 20px;
      padding: 6px 15px;
      margin-bottom: 15px;
      position: relative;
      overflow: hidden;
      border: 1px solid rgba(255, 255, 255, 0.1);
      
      // Different colors for badge types
      &.bronze {
        background: linear-gradient(135deg, rgba(205, 127, 50, 0.3), rgba(205, 127, 50, 0.1));
        border: 1px solid rgba(205, 127, 50, 0.3);
        span { color: #CD7F32; }
      }
      
      &.silver {
        background: linear-gradient(135deg, rgba(192, 192, 192, 0.3), rgba(192, 192, 192, 0.1));
        border: 1px solid rgba(192, 192, 192, 0.3);
        span { color: #C0C0C0; }
      }
      
      &.gold {
        background: linear-gradient(135deg, rgba(map-get(vars.$colors, 'accent', 'base'), 0.3), rgba(map-get(vars.$colors, 'accent', 'base'), 0.1));
        border: 1px solid rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
        span { color: map-get(vars.$colors, 'accent', 'base'); }
      }
      
      &.platinum {
        background: linear-gradient(135deg, rgba(229, 228, 226, 0.3), rgba(229, 228, 226, 0.1));
        border: 1px solid rgba(229, 228, 226, 0.3);
        span { color: #E5E4E2; }
      }
      
      &.diamond {
        background: linear-gradient(135deg, rgba(185, 242, 255, 0.3), rgba(185, 242, 255, 0.1));
        border: 1px solid rgba(185, 242, 255, 0.3);
        span { color: #B9F2FF; }
      }
      
      span {
        position: relative;
        z-index: 1;
        font-weight: 600;
        font-size: 1rem;
      }
      
      // Shine effect
      &::after {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(
          90deg,
          transparent,
          rgba(255, 255, 255, 0.2),
          transparent
        );
        animation: shimmer 2s infinite;
      }
    }
    
    // Points badge for unlocked achievements
    .badge-points {
      position: absolute;
      bottom: 10px;
      right: 50%;
      transform: translateX(50%);
      background: map-get(vars.$colors, 'accent', 'base');
      color: map-get(vars.$colors, 'primary', 'dark');
      border-radius: 20px;
      padding: 5px 15px;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 8px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
      
      i {
        font-size: 1rem;
        color: map-get(vars.$colors, 'primary', 'dark');
      }
      
      span {
        font-size: 1.1rem;
      }
    }
  }
  
  // Right side - Achievement details
  .achievement-details {
    flex: 1;
    display: flex;
    flex-direction: column;
    padding: 20px;
    background: rgba(27, 67, 50, 0.7);
    border-radius: 20px;
    backdrop-filter: blur(5px);
    -webkit-backdrop-filter: blur(5px);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
    position: relative;
    overflow: hidden;
    
    // Adjust for smaller screens
    @media (max-height: 500px) {
      padding: 15px;
    }
    
    // Title styling
    .achievement-title {
      font-size: 1.8rem;
      font-weight: 700;
      color: white;
      margin: 0 0 15px;
      position: relative;
      text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
      
      // Bottom border
      &::after {
        content: '';
        position: absolute;
        bottom: -5px;
        right: 0;
        width: 80px;
        height: 3px;
        background: map-get(vars.$colors, 'accent', 'base');
        border-radius: 1.5px;
      }
      
      // Smaller on mobile
      @media (max-height: 500px) {
        font-size: 1.5rem;
        margin-bottom: 10px;
      }
    }
    
    // Completion banner for unlocked achievements
    .completion-banner {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 15px;
      background: rgba(39, 174, 96, 0.2);
      padding: 8px 15px;
      border-radius: 10px;
      border-right: 3px solid #27AE60;
      
      .animated-icon {
        font-size: 1.4rem;
        color: #27AE60;
        animation: pulse 2s infinite alternate;
      }
      
      span {
        font-weight: 600;
        color: #27AE60;
      }
    }
    
    // Description text
    .achievement-description {
      margin-bottom: 20px;
      flex: 0 0 auto;
      
      p {
        color: rgba(255, 255, 255, 0.9);
        line-height: 1.6;
        margin: 0;
        font-size: 1.1rem;
      }
      
      @media (max-height: 500px) {
        margin-bottom: 10px;
        
        p {
          font-size: 0.95rem;
          line-height: 1.4;
        }
      }
    }
    
    // Details section
    .details-section {
      display: flex;
      flex-direction: column;
      gap: 8px;
      margin-bottom: 20px;
      background: rgba(0, 0, 0, 0.2);
      padding: 12px;
      border-radius: 10px;
      flex: 0 0 auto;
      
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
          font-size: 0.9rem;
        }
        
        span {
          color: rgba(255, 255, 255, 0.8);
          font-size: 0.95rem;
        }
      }
      
      @media (max-height: 500px) {
        margin-bottom: 10px;
        padding: 8px;
        gap: 5px;
        
        .detail-item {
          i {
            width: 24px;
            height: 24px;
            font-size: 0.8rem;
          }
          
          span {
            font-size: 0.85rem;
          }
        }
      }
    }
    
    // Progress bar
    .achievement-progress {
      margin-bottom: 20px;
      
      .progress-container {
        .progress-bar {
          height: 8px;
          background: rgba(0, 0, 0, 0.2);
          border-radius: 4px;
          overflow: hidden;
          margin-bottom: 5px;
          
          .progress-fill {
            height: 100%;
            background: linear-gradient(to right,
              rgba(map-get(vars.$colors, 'accent', 'dark'), 0.8),
              rgba(map-get(vars.$colors, 'accent', 'base'), 0.8)
            );
            border-radius: 4px;
            position: relative;
            transition: width 0.8s cubic-bezier(0.22, 1, 0.36, 1);
            
            // Shimmer effect
            &::after {
              content: '';
              position: absolute;
              top: 0;
              left: -100%;
              width: 100%;
              height: 100%;
              background: linear-gradient(
                90deg,
                transparent,
                rgba(255, 255, 255, 0.3),
                transparent
              );
              animation: shimmer 2s infinite;
            }
          }
        }
        
        .progress-text {
          font-size: 0.85rem;
          color: rgba(255, 255, 255, 0.7);
          text-align: left;
        }
      }
      
      @media (max-height: 500px) {
        margin-bottom: 10px;
      }
    }
    
    // Action buttons
    .action-buttons {
      display: flex;
      gap: 15px;
      justify-content: center;
      margin-top: auto;
      
      .action-button {
        padding: 10px 25px;
        border: none;
        border-radius: 25px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        font-size: 1rem;
        display: flex;
        align-items: center;
        gap: 8px;
        
        // Close button styling
        &.close-button {
          background: rgba(255, 255, 255, 0.1);
          color: white;
          
          &:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-2px);
          }
          
          &:active {
            transform: translateY(0);
          }
        }
        
        // Share button styling
        &.share-button {
          background: map-get(vars.$colors, 'accent', 'base');
          color: map-get(vars.$colors, 'primary', 'dark');
          
          &:hover {
            background: map-get(vars.$colors, 'accent', 'light');
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(map-get(vars.$colors, 'accent', 'base'), 0.4);
          }
          
          &:active {
            transform: translateY(0);
            box-shadow: 0 2px 8px rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
          }
          
          i {
            font-size: 1rem;
          }
        }
        
        @media (max-height: 500px) {
          padding: 8px 20px;
          font-size: 0.9rem;
        }
      }
    }
  }
}

// Animations
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

@keyframes badgePulse {
  0% {
    transform: scale(1);
  }
  
  100% {
    transform: scale(1.05);
  }
}

@keyframes glowPulse {
  0% {
    opacity: 0.5;
    transform: scale(0.95);
  }
  
  100% {
    opacity: 0.8;
    transform: scale(1.05);
  }
}

@keyframes shine {
  0% {
    background-position: -200% -200%;
  }
  
  100% {
    background-position: 200% 200%;
  }
}

@keyframes shimmer {
  0% {
    left: -100%;
  }
  
  100% {
    left: 100%;
  }
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  
  50% {
    transform: scale(1.2);
  }
}
```

<details><summary>risultato tool</summary>

```
OK
```
</details>



Now, let's enhance the TypeScript component to support the new features and animations:

**Artifact: Enhanced Achievement Details Modal (TypeScript)** (`application/vnd.ant.code`, create)

```typescript
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy, OnInit } from '@angular/core';
import { Achievement } from '../../../services/gamification.service';
import { trigger, transition, style, animate, query, stagger } from '@angular/animations';
import { PlatformService } from '../../../../../core/services/platform.service';

@Component({
  selector: 'app-achievement-details-modal',
  standalone: false,
  templateUrl: './achievement-details-modal.component.html',
  styleUrls: ['./achievement-details-modal.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    // Animation for the entire modal content
    trigger('modalContentAnimation', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('400ms cubic-bezier(0.4, 0.0, 0.2, 1)', style({ opacity: 1 })),
        // Animate child elements with stagger
        query('.badge-container, .achievement-title, .completion-banner, .achievement-description, .details-section, .achievement-progress, .action-buttons', [
          style({ opacity: 0, transform: 'translateY(20px)' }),
          stagger(80, [
            animate('400ms cubic-bezier(0.4, 0.0, 0.2, 1)', 
              style({ opacity: 1, transform: 'translateY(0)' }))
          ])
        ], { optional: true })
      ])
    ])
  ]
})
export class AchievementDetailsModalComponent implements OnInit {
  @Input() isOpen: boolean = false;
  @Input() achievement: Achievement | null = null;

  @Output() close = new EventEmitter<void>();
  @Output() share = new EventEmitter<Achievement>();

  // Flag to track if we've already played haptic feedback
  private hapticFeedbackPlayed = false;

  constructor(private platformService: PlatformService) {}

  ngOnInit() {
    // Reset haptic flag when component initializes
    this.hapticFeedbackPlayed = false;
  }

  /**
   * When the modal becomes visible, play haptic feedback based on achievement status
   */
  ngOnChanges() {
    // Only play haptic feedback once per modal opening
    if (this.isOpen && this.achievement && !this.hapticFeedbackPlayed) {
      this.playHapticFeedback();
      this.hapticFeedbackPlayed = true;
    }
    
    // Reset the flag when modal closes
    if (!this.isOpen) {
      this.hapticFeedbackPlayed = false;
    }
  }

  /**
   * Play appropriate haptic feedback based on achievement status
   */
  private playHapticFeedback() {
    if (!this.achievement) return;
    
    if (this.achievement.isUnlocked) {
      // Success vibration pattern for unlocked achievements
      this.platformService.vibrateSuccess().catch(() => {});
    } else {
      // Standard vibration for locked achievements
      this.platformService.vibrateWarning().catch(() => {});
    }
  }

  /**
   * Get badge image based on achievement type and unlock status
   */
  getBadgeImage(achievement: Achievement): string {
    const badgeType = achievement.type || 'bronze';
    const status = achievement.isUnlocked ? 'unlocked' : 'locked';
    return `assets/images/badges/${badgeType}_${status}.png`;
  }

  /**
   * Get readable requirement text
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
      case 'custom':
        return `إكمال المهمة المطلوبة`;
      default:
        return `إكمال المتطلبات`;
    }
  }

  /**
   * Get badge type label in Arabic
   */
  getBadgeTypeLabel(type: string): string {
    switch (type) {
      case 'bronze': return 'برونزي';
      case 'silver': return 'فضي';
      case 'gold': return 'ذهبي';
      case 'platinum': return 'بلاتيني';
      case 'diamond': return 'ماسي';
      default: return 'عادي';
    }
  }

  /**
   * Get rarity level text in Arabic
   */
  getRarityLevel(type: string): string {
    switch (type) {
      case 'bronze': return 'شائع';
      case 'silver': return 'غير شائع';
      case 'gold': return 'نادر';
      case 'platinum': return 'أسطوري';
      case 'diamond': return 'خرافي';
      default: return 'عادي';
    }
  }

  /**
   * Close the modal
   */
  onClose(): void {
    // Play haptic feedback when closing
    this.platformService.vibrateSuccess().catch(() => {});
    this.close.emit();
  }

  /**
   * Share the achievement
   */
  onShare(achievement: Achievement): void {
    // Play haptic feedback when sharing
    this.platformService.vibrateSuccess().catch(() => {});
    this.share.emit(achievement);
  }
}
```

<details><summary>risultato tool</summary>

```
OK
```
</details>



## What's Been Enhanced

I've created a completely redesigned achievement details modal that's more gamified, better optimized for landscape mode, and includes visual effects similar to your feedback modal.

### Key Improvements:

1. **Optimized Layout for Landscape Mode**
   - Split layout with badge showcase on the left and details on the right
   - Responsive design that adjusts for portrait mode on mobile
   - Proper spacing and arrangement for all screen sizes

2. **Enhanced Visual Effects**
   - Particle effects for unlocked achievements
   - Pulsing glow effect around badges
   - Shimmer animations across various elements
   - Badge shine effect similar to modern game UIs
   - Smooth entrance animations with staggered timing

3. **Gamified Experience**
   - Vibrant colors and dynamic effects
   - Haptic feedback tied to achievement status
   - Achievement type badges with proper coloring
   - Achievement rarity indicators
   - Eye-catching progress bar for locked achievements

4. **Better Modal Integration**
   - Uses the app's centralized modal system
   - Enhanced backdrop with proper blur effect
   - Customized container styling with proper z-indexing
   - Smooth animations for opening and closing

5. **Badge Showcase**
   - Prominently displays the badge with custom styling
   - Special visual effects for unlocked achievements
   - Points display with star icon
   - Badge type indicator with color-coding

6. **Responsive to All Scenarios**
   - Special styling for unlocked vs. locked achievements
   - Progress tracking for incomplete achievements
   - Detailed information display with icons
   - Optimized for different screen sizes and orientations

### Implementation Notes:

- The modal uses Angular animations for smooth transitions
- Haptic feedback is provided through the platform service
- The design maintains Arabic RTL (right-to-left) text direction
- All the custom badge styles are preserved and enhanced

This modal now delivers a truly gamified experience while effectively using screen space, especially in landscape mode which is your primary use case. The visual effects create excitement when showing achievements, making the entire experience more rewarding for users.

Would you like me to explain any specific part of the implementation in more detail?

## Yassin (2025-04-23T20:41)

it looks so bad and odnt match the sizes of my app consider using same of feedback modal with the blurry backgournd and the positin correclty

_file allegato (non incluso nell'export): image.png_

## Claude (2025-04-23T20:45)

I understand now - the design I created doesn't match your app's interface and scale. Let me create a more compact version that better matches your feedback modal style with the blurry background and proper positioning.

**Artifact update: achievement-modal-component**

Sostituito:
```
<!-- Enhanced achievement-details-modal.component.html -->
<app-modal [isOpen]="isOpen" (closed)="onClose()" size="lg" [showCloseButton]="true" position="center" customClass="achievement-modal-container">
  <div class="achievement-modal" *ngIf="achievement" [@modalContentAnimation]>
    <!-- Particle Effects for Unlocked Achievements -->
    <div class="particles-container" *ngIf="achievement.isUnlocked">
      <div class="particle" *ngFor="let i of [1,2,3,4,5,6,7,8,9,10]"></div>
    </div>

    <!-- Main Content -->
    <div class="modal-content-wrapper">
      <!-- Left Side - Badge Display -->
      <div class="badge-showcase">
        <div class="badge-container" [class.unlocked]="achievement.isUnlocked">
          <img [src]="getBadgeImage(achievement)" [alt]="achievement.title" class="badge-image">
          
          <!-- Lock Overlay -->
          <div class="lock-overlay" *ngIf="!achievement.isUnlocked">
            <i class="fas fa-lock"></i>
          </div>
          
          <!-- Glow Effect for Unlocked Badges -->
          <div class="badge-glow" *ngIf="achievement.isUnlocked"></div>
          
          <!-- Shine Animation -->
          <div class="badge-shine" *ngIf="achievement.isUnlocked"></div>
        </div>
        
        <!-- Badge Type Indicator -->
        <div class="badge-type" [ngClass]="achievement.type">
          <span>{{ getBadgeTypeLabel(achievement.type) }}</span>
        </div>
        
        <!-- Points Display -->
        <div class="badge-points" *ngIf="achievement.isUnlocked">
          <i class="fas fa-star"></i>
          <span>{{ achievement.points }}</span>
        </div>
      </div>

      <!-- Right Side - Achievement Details -->
      <div class="achievement-details">
        <h2 class="achievement-title">{{ achievement.title }}</h2>
        
        <!-- Completion Status Banner -->
        <div class="completion-banner" *ngIf="achievement.isUnlocked">
          <i class="fas fa-check-circle animated-icon"></i>
          <span>تم الإنجاز</span>
        </div>
        
        <div class="achievement-description">
          <p>{{ achievement.description }}</p>
        </div>
        
        <!-- Details Section -->
        <div class="details-section">
          <!-- If Unlocked: Show completion date -->
          <div class="detail-item" *ngIf="achievement.isUnlocked && achievement.dateUnlocked">
            <i class="fas fa-calendar-check"></i>
            <span>تم الحصول: {{ achievement.dateUnlocked | date:'mediumDate' }}</span>
          </div>
          
          <!-- If Locked: Show requirement -->
          <div class="detail-item" *ngIf="!achievement.isUnlocked">
            <i class="fas fa-tasks"></i>
            <span>المطلوب: {{ getRequirementText(achievement) }}</span>
          </div>
          
          <!-- Always show points value -->
          <div class="detail-item">
            <i class="fas fa-award"></i>
            <span>القيمة: {{ achievement.points }} نقطة</span>
          </div>
          
          <!-- Rarity indicator -->
          <div class="detail-item">
            <i class="fas fa-gem"></i>
            <span>الندرة: {{ getRarityLevel(achievement.type) }}</span>
          </div>
        </div>
        
        <!-- Progress Bar (Only for locked achievements) -->
        <div class="achievement-progress" *ngIf="!achievement.isUnlocked">
          <div class="progress-container">
            <div class="progress-bar">
              <div class="progress-fill" [style.width.%]="achievement.progress"></div>
            </div>
            <div class="progress-text">{{ achievement.progress }}%</div>
          </div>
        </div>
        
        <!-- Action Buttons -->
        <div class="action-buttons">
          <button class="action-button close-button" (click)="onClose()">
            إغلاق
          </button>
          
          <button *ngIf="achievement.isUnlocked" class="action-button share-button" (click)="onShare(achievement)">
            <i class="fas fa-share-alt"></i>
            مشاركة
          </button>
        </div>
      </div>
    </div>
  </div>
</app-modal>
```

con:
```
<!-- Revised achievement-details-modal.component.html -->
<div class="achievement-modal-overlay" *ngIf="isOpen" [@fadeIn]>
  <div class="achievement-modal-content" *ngIf="achievement" [@modalAnimation]>
    <!-- Close Button -->
    <button class="close-button" (click)="onClose()">
      <i class="fas fa-times"></i>
    </button>

    <!-- Achievement Title -->
    <h2 class="achievement-title">{{ achievement.title }}</h2>
    
    <!-- Main Content Area -->
    <div class="modal-body">
      <!-- Badge Image with Effects -->
      <div class="badge-display" [class.unlocked]="achievement.isUnlocked">
        <div class="badge-container">
          <img [src]="getBadgeImage(achievement)" [alt]="achievement.title" class="badge-image">
          
          <!-- Lock Overlay -->
          <div class="lock-overlay" *ngIf="!achievement.isUnlocked">
            <i class="fas fa-lock"></i>
          </div>
          
          <!-- Glow Effect -->
          <div class="badge-glow" *ngIf="achievement.isUnlocked"></div>
        </div>
        
        <!-- Completion Status -->
        <div class="completion-status" *ngIf="achievement.isUnlocked">
          <i class="fas fa-check-circle"></i>
          <span>تم الإنجاز</span>
        </div>
        
        <!-- Points Badge -->
        <div class="points-badge">
          <i class="fas fa-star"></i>
          <span>{{ achievement.points }}</span>
        </div>
      </div>

      <!-- Achievement Details -->
      <div class="achievement-info">
        <p class="achievement-desc">{{ achievement.description }}</p>
        
        <!-- Details List -->
        <div class="details-list">
          <!-- Date Received -->
          <div class="detail-row" *ngIf="achievement.isUnlocked && achievement.dateUnlocked">
            <i class="fas fa-calendar-alt"></i>
            <span>تم الحصول: {{ achievement.dateUnlocked | date:'shortDate' }}</span>
          </div>
          
          <!-- Required Task -->
          <div class="detail-row" *ngIf="!achievement.isUnlocked">
            <i class="fas fa-tasks"></i>
            <span>{{ getRequirementText(achievement) }}</span>
          </div>
          
          <!-- Badge Type -->
          <div class="detail-row">
            <i class="fas fa-medal"></i>
            <span>{{ getBadgeTypeLabel(achievement.type) }}</span>
          </div>
        </div>
        
        <!-- Progress Bar -->
        <div class="progress-container" *ngIf="!achievement.isUnlocked">
          <div class="progress-bar">
            <div class="progress-fill" [style.width.%]="achievement.progress"></div>
          </div>
          <div class="progress-text">{{ achievement.progress }}%</div>
        </div>
      </div>
    </div>
    
    <!-- Actions -->
    <div class="modal-actions">
      <button class="action-btn close-btn" (click)="onClose()">
        إغلاق
      </button>
      
      <button *ngIf="achievement.isUnlocked" class="action-btn share-btn" (click)="onShare(achievement)">
        <i class="fas fa-share-alt"></i>
        مشاركة
      </button>
    </div>
    
    <!-- Particles for Visual Effect -->
    <div class="achievement-particles" *ngIf="achievement.isUnlocked">
      <div class="particle" *ngFor="let i of [1,2,3,4,5,6]"></div>
    </div>
  </div>
</div>
```

<details><summary>risultato tool</summary>

```
OK
```
</details>

**Artifact update: achievement-modal-styles**

Sostituito:
```
// Enhanced achievement-details-modal.component.scss
@use "sass:map";
@use 'variables' as vars;
@use 'mixins' as mix;

// Main modal enhancements to make app-modal look more gamified
::ng-deep .achievement-modal-container {
  .modal-overlay {
    // Better blur effect similar to feedback modal
    backdrop-filter: blur(10px) !important;
    -webkit-backdrop-filter: blur(10px) !important;
    background: rgba(0, 0, 0, 0.85) !important;
  }
  
  .modal-container {
    // Transparent background to use our own styling
    background: transparent !important;
    border: none !important;
    box-shadow: none !important;
    // Make sure we have enough space in landscape
    max-height: 95vh !important;
    max-width: 900px !important;
    width: 95% !important;
  }
  
  // Enhance the close button
  .modal-close-btn {
    background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.2) !important;
    color: map-get(vars.$colors, 'accent', 'base') !important;
    top: 10px !important;
    left: 10px !important;
    z-index: 100 !important;
    
    &:hover {
      background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.4) !important;
    }
  }
}

// Main achievement modal styling
.achievement-modal {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: hidden;
  
  // Particles container for animated effects
  .particles-container {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    pointer-events: none;
    z-index: 1;
    
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
  
  // Content wrapper with flexible layout
  .modal-content-wrapper {
    position: relative;
    z-index: 2;
    display: flex;
    flex-direction: row;
    width: 100%;
    height: 100%;
    padding: 20px;
    
    // Responsive layout for portrait mode (stacked)
    @media (max-width: 768px) and (orientation: portrait) {
      flex-direction: column;
      align-items: center;
      gap: 20px;
    }
  }
  
  // Left side - Badge showcase
  .badge-showcase {
    flex: 0 0 40%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 20px;
    position: relative;
    
    // Adjust for mobile portrait
    @media (max-width: 768px) and (orientation: portrait) {
      flex: 0 0 auto;
      width: 100%;
      padding: 10px;
    }
    
    // Container for badge image and effects
    .badge-container {
      width: 220px;
      height: 220px;
      position: relative;
      margin-bottom: 15px;
      display: flex;
      align-items: center;
      justify-content: center;
      
      // For small screens
      @media (max-height: 500px) {
        width: 150px;
        height: 150px;
      }
      
      // Badge image with enhanced styling
      .badge-image {
        width: 100%;
        height: 100%;
        object-fit: contain;
        transition: all 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        filter: drop-shadow(0 10px 20px rgba(0, 0, 0, 0.5));
        z-index: 2;
        animation: badgePulse 3s infinite alternate;
      }
      
      // Lock overlay for locked achievements
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
        z-index: 3;
        
        i {
          font-size: 50px;
          color: rgba(255, 255, 255, 0.7);
          filter: drop-shadow(0 2px 5px rgba(0, 0, 0, 0.5));
        }
      }
      
      // Glow effect for unlocked achievements
      .badge-glow {
        position: absolute;
        top: -10px;
        left: -10px;
        right: -10px;
        bottom: -10px;
        border-radius: 50%;
        background: radial-gradient(
          ellipse at center,
          rgba(map-get(vars.$colors, 'accent', 'base'), 0.5) 0%,
          rgba(map-get(vars.$colors, 'accent', 'base'), 0.2) 40%,
          rgba(map-get(vars.$colors, 'accent', 'base'), 0) 70%
        );
        z-index: 1;
        animation: glowPulse 3s infinite alternate;
      }
      
      // Shine effect overlay
      .badge-shine {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(
          45deg,
          rgba(255, 255, 255, 0) 0%,
          rgba(255, 255, 255, 0.3) 50%,
          rgba(255, 255, 255, 0) 100%
        );
        background-size: 200% 200%;
        z-index: 4;
        border-radius: 50%;
        pointer-events: none;
        animation: shine 3s infinite linear;
      }
      
      // When achievement is unlocked
      &.unlocked {
        .badge-image {
          filter: drop-shadow(0 10px 25px rgba(map-get(vars.$colors, 'accent', 'base'), 0.5));
          transform: scale(1.05);
        }
      }
    }
    
    // Badge type label
    .badge-type {
      background: rgba(0, 0, 0, 0.3);
      border-radius: 20px;
      padding: 6px 15px;
      margin-bottom: 15px;
      position: relative;
      overflow: hidden;
      border: 1px solid rgba(255, 255, 255, 0.1);
      
      // Different colors for badge types
      &.bronze {
        background: linear-gradient(135deg, rgba(205, 127, 50, 0.3), rgba(205, 127, 50, 0.1));
        border: 1px solid rgba(205, 127, 50, 0.3);
        span { color: #CD7F32; }
      }
      
      &.silver {
        background: linear-gradient(135deg, rgba(192, 192, 192, 0.3), rgba(192, 192, 192, 0.1));
        border: 1px solid rgba(192, 192, 192, 0.3);
        span { color: #C0C0C0; }
      }
      
      &.gold {
        background: linear-gradient(135deg, rgba(map-get(vars.$colors, 'accent', 'base'), 0.3), rgba(map-get(vars.$colors, 'accent', 'base'), 0.1));
        border: 1px solid rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
        span { color: map-get(vars.$colors, 'accent', 'base'); }
      }
      
      &.platinum {
        background: linear-gradient(135deg, rgba(229, 228, 226, 0.3), rgba(229, 228, 226, 0.1));
        border: 1px solid rgba(229, 228, 226, 0.3);
        span { color: #E5E4E2; }
      }
      
      &.diamond {
        background: linear-gradient(135deg, rgba(185, 242, 255, 0.3), rgba(185, 242, 255, 0.1));
        border: 1px solid rgba(185, 242, 255, 0.3);
        span { color: #B9F2FF; }
      }
      
      span {
        position: relative;
        z-index: 1;
        font-weight: 600;
        font-size: 1rem;
      }
      
      // Shine effect
      &::after {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(
          90deg,
          transparent,
          rgba(255, 255, 255, 0.2),
          transparent
        );
        animation: shimmer 2s infinite;
      }
    }
    
    // Points badge for unlocked achievements
    .badge-points {
      position: absolute;
      bottom: 10px;
      right: 50%;
      transform: translateX(50%);
      background: map-get(vars.$colors, 'accent', 'base');
      color: map-get(vars.$colors, 'primary', 'dark');
      border-radius: 20px;
      padding: 5px 15px;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 8px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
      
      i {
        font-size: 1rem;
        color: map-get(vars.$colors, 'primary', 'dark');
      }
      
      span {
        font-size: 1.1rem;
      }
    }
  }
  
  // Right side - Achievement details
  .achievement-details {
    flex: 1;
    display: flex;
    flex-direction: column;
    padding: 20px;
    background: rgba(27, 67, 50, 0.7);
    border-radius: 20px;
    backdrop-filter: blur(5px);
    -webkit-backdrop-filter: blur(5px);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
    position: relative;
    overflow: hidden;
    
    // Adjust for smaller screens
    @media (max-height: 500px) {
      padding: 15px;
    }
    
    // Title styling
    .achievement-title {
      font-size: 1.8rem;
      font-weight: 700;
      color: white;
      margin: 0 0 15px;
      position: relative;
      text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
      
      // Bottom border
      &::after {
        content: '';
        position: absolute;
        bottom: -5px;
        right: 0;
        width: 80px;
        height: 3px;
        background: map-get(vars.$colors, 'accent', 'base');
        border-radius: 1.5px;
      }
      
      // Smaller on mobile
      @media (max-height: 500px) {
        font-size: 1.5rem;
        margin-bottom: 10px;
      }
    }
    
    // Completion banner for unlocked achievements
    .completion-banner {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 15px;
      background: rgba(39, 174, 96, 0.2);
      padding: 8px 15px;
      border-radius: 10px;
      border-right: 3px solid #27AE60;
      
      .animated-icon {
        font-size: 1.4rem;
        color: #27AE60;
        animation: pulse 2s infinite alternate;
      }
      
      span {
        font-weight: 600;
        color: #27AE60;
      }
    }
    
    // Description text
    .achievement-description {
      margin-bottom: 20px;
      flex: 0 0 auto;
      
      p {
        color: rgba(255, 255, 255, 0.9);
        line-height: 1.6;
        margin: 0;
        font-size: 1.1rem;
      }
      
      @media (max-height: 500px) {
        margin-bottom: 10px;
        
        p {
          font-size: 0.95rem;
          line-height: 1.4;
        }
      }
    }
    
    // Details section
    .details-section {
      display: flex;
      flex-direction: column;
      gap: 8px;
      margin-bottom: 20px;
      background: rgba(0, 0, 0, 0.2);
      padding: 12px;
      border-radius: 10px;
      flex: 0 0 auto;
      
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
          font-size: 0.9rem;
        }
        
        span {
          color: rgba(255, 255, 255, 0.8);
          font-size: 0.95rem;
        }
      }
      
      @media (max-height: 500px) {
        margin-bottom: 10px;
        padding: 8px;
        gap: 5px;
        
        .detail-item {
          i {
            width: 24px;
            height: 24px;
            font-size: 0.8rem;
          }
          
          span {
            font-size: 0.85rem;
          }
        }
      }
    }
    
    // Progress bar
    .achievement-progress {
      margin-bottom: 20px;
      
      .progress-container {
        .progress-bar {
          height: 8px;
          background: rgba(0, 0, 0, 0.2);
          border-radius: 4px;
          overflow: hidden;
          margin-bottom: 5px;
          
          .progress-fill {
            height: 100%;
            background: linear-gradient(to right,
              rgba(map-get(vars.$colors, 'accent', 'dark'), 0.8),
              rgba(map-get(vars.$colors, 'accent', 'base'), 0.8)
            );
            border-radius: 4px;
            position: relative;
            transition: width 0.8s cubic-bezier(0.22, 1, 0.36, 1);
            
            // Shimmer effect
            &::after {
              content: '';
              position: absolute;
              top: 0;
              left: -100%;
              width: 100%;
              height: 100%;
              background: linear-gradient(
                90deg,
                transparent,
                rgba(255, 255, 255, 0.3),
                transparent
              );
              animation: shimmer 2s infinite;
            }
          }
        }
        
        .progress-text {
          font-size: 0.85rem;
          color: rgba(255, 255, 255, 0.7);
          text-align: left;
        }
      }
      
      @media (max-height: 500px) {
        margin-bottom: 10px;
      }
    }
    
    // Action buttons
    .action-buttons {
      display: flex;
      gap: 15px;
      justify-content: center;
      margin-top: auto;
      
      .action-button {
        padding: 10px 25px;
        border: none;
        border-radius: 25px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        font-size: 1rem;
        display: flex;
        align-items: center;
        gap: 8px;
        
        // Close button styling
        &.close-button {
          background: rgba(255, 255, 255, 0.1);
          color: white;
          
          &:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-2px);
          }
          
          &:active {
            transform: translateY(0);
          }
        }
        
        // Share button styling
        &.share-button {
          background: map-get(vars.$colors, 'accent', 'base');
          color: map-get(vars.$colors, 'primary', 'dark');
          
          &:hover {
            background: map-get(vars.$colors, 'accent', 'light');
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(map-get(vars.$colors, 'accent', 'base'), 0.4);
          }
          
          &:active {
            transform: translateY(0);
            box-shadow: 0 2px 8px rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
          }
          
          i {
            font-size: 1rem;
          }
        }
        
        @media (max-height: 500px) {
          padding: 8px 20px;
          font-size: 0.9rem;
        }
      }
    }
  }
}

// Animations
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

@keyframes badgePulse {
  0% {
    transform: scale(1);
  }
  
  100% {
    transform: scale(1.05);
  }
}

@keyframes glowPulse {
  0% {
    opacity: 0.5;
    transform: scale(0.95);
  }
  
  100% {
    opacity: 0.8;
    transform: scale(1.05);
  }
}

@keyframes shine {
  0% {
    background-position: -200% -200%;
  }
  
  100% {
    background-position: 200% 200%;
  }
}

@keyframes shimmer {
  0% {
    left: -100%;
  }
  
  100% {
    left: 100%;
  }
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  
  50% {
    transform: scale(1.2);
  }
}
```

con:
```
// Revised achievement-details-modal.component.scss
@use "sass:map";
@use 'variables' as vars;
@use 'mixins' as mix;

// Fullscreen overlay with blurred background
.achievement-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.8);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 999999;
  padding: 15px;
  direction: rtl;
}

// Main modal container
.achievement-modal-content {
  background: rgba(map-get(vars.$colors, 'primary', 'base'), 0.95);
  border-radius: 18px;
  max-width: 500px;
  width: 95%;
  position: relative;
  overflow: hidden;
  border: 1px solid rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
  // Subtle gold gradient at the top
  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 4px;
    background: linear-gradient(to right,
      rgba(map-get(vars.$colors, 'accent', 'dark'), 0.7),
      rgba(map-get(vars.$colors, 'accent', 'base'), 0.9),
      rgba(map-get(vars.$colors, 'accent', 'dark'), 0.7)
    );
  }
}

// Close button
.close-button {
  position: absolute;
  top: 12px;
  left: 12px;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: none;
  background: rgba(255, 255, 255, 0.1);
  color: rgba(255, 255, 255, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  z-index: 5;
  transition: all 0.2s ease;

  &:hover {
    background: rgba(255, 255, 255, 0.2);
    transform: rotate(90deg);
  }
  
  i {
    font-size: 16px;
  }
}

// Achievement Title
.achievement-title {
  text-align: center;
  color: white;
  font-size: 1.5rem;
  font-weight: 700;
  margin: 12px 0;
  padding: 0 20px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  position: relative;
  
  // Gold underline
  &::after {
    content: '';
    position: absolute;
    bottom: -4px;
    left: 50%;
    transform: translateX(-50%);
    width: 50px;
    height: 2px;
    background: map-get(vars.$colors, 'accent', 'base');
    border-radius: 1px;
  }
}

// Main content area with badge and details
.modal-body {
  display: grid;
  grid-template-columns: auto 1fr;
  padding: 15px;
  gap: 15px;
  
  // Switch to stacked layout in portrait mode
  @media (max-width: 480px) and (orientation: portrait) {
    grid-template-columns: 1fr;
    justify-items: center;
  }
}

// Badge display section
.badge-display {
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  
  // Badge container with effects
  .badge-container {
    width: 130px;
    height: 130px;
    position: relative;
    margin-bottom: 10px;
    
    @media (max-height: 480px) {
      width: 100px;
      height: 100px;
    }
    
    // Achievement badge image
    .badge-image {
      width: 100%;
      height: 100%;
      object-fit: contain;
      filter: drop-shadow(0 5px 15px rgba(0, 0, 0, 0.4));
      position: relative;
      z-index: 2;
      animation: float 5s infinite ease-in-out;
    }
    
    // Lock overlay for locked achievements
    .lock-overlay {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      background: rgba(0, 0, 0, 0.5);
      border-radius: 50%;
      z-index: 3;
      
      i {
        font-size: 32px;
        color: rgba(255, 255, 255, 0.7);
      }
    }
    
    // Glow effect for unlocked achievements
    .badge-glow {
      position: absolute;
      top: -10%;
      left: -10%;
      width: 120%;
      height: 120%;
      border-radius: 50%;
      background: radial-gradient(
        ellipse at center,
        rgba(map-get(vars.$colors, 'accent', 'base'), 0.3) 0%,
        rgba(map-get(vars.$colors, 'accent', 'base'), 0.1) 40%,
        rgba(map-get(vars.$colors, 'accent', 'base'), 0) 70%
      );
      z-index: 1;
      animation: pulse 3s infinite alternate;
    }
  }
  
  // Completion status indicator
  .completion-status {
    display: flex;
    align-items: center;
    gap: 5px;
    background: rgba(39, 174, 96, 0.2);
    border-radius: 12px;
    padding: 5px 10px;
    margin-bottom: 10px;
    
    i {
      color: #27AE60;
      font-size: 0.9rem;
      animation: pulse 2s infinite alternate;
    }
    
    span {
      color: #27AE60;
      font-size: 0.9rem;
      font-weight: 600;
    }
  }
  
  // Points badge
  .points-badge {
    display: flex;
    align-items: center;
    gap: 5px;
    background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.2);
    border: 1px solid rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
    border-radius: 12px;
    padding: 5px 10px;
    
    i {
      color: map-get(vars.$colors, 'accent', 'base');
      font-size: 0.9rem;
    }
    
    span {
      color: map-get(vars.$colors, 'accent', 'base');
      font-size: 0.9rem;
      font-weight: 600;
    }
  }
}

// Achievement information section
.achievement-info {
  display: flex;
  flex-direction: column;
  
  // Description text
  .achievement-desc {
    color: rgba(255, 255, 255, 0.9);
    font-size: 0.95rem;
    line-height: 1.5;
    margin: 0 0 15px;
    
    @media (max-height: 480px) {
      font-size: 0.85rem;
      line-height: 1.4;
      margin-bottom: 10px;
    }
  }
  
  // Details list
  .details-list {
    background: rgba(0, 0, 0, 0.2);
    border-radius: 10px;
    padding: 10px;
    margin-bottom: 15px;
    
    .detail-row {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 6px;
      
      &:last-child {
        margin-bottom: 0;
      }
      
      i {
        width: 24px;
        height: 24px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.1);
        display: flex;
        align-items: center;
        justify-content: center;
        color: map-get(vars.$colors, 'accent', 'base');
        font-size: 0.8rem;
      }
      
      span {
        color: rgba(255, 255, 255, 0.8);
        font-size: 0.9rem;
      }
    }
    
    @media (max-height: 480px) {
      padding: 8px;
      margin-bottom: 10px;
      
      .detail-row {
        margin-bottom: 4px;
        
        i {
          width: 20px;
          height: 20px;
          font-size: 0.7rem;
        }
        
        span {
          font-size: 0.8rem;
        }
      }
    }
  }
  
  // Progress bar
  .progress-container {
    margin-bottom: 5px;
    
    .progress-bar {
      height: 6px;
      background: rgba(0, 0, 0, 0.3);
      border-radius: 3px;
      overflow: hidden;
      margin-bottom: 5px;
      
      .progress-fill {
        height: 100%;
        background: map-get(vars.$colors, 'accent', 'base');
        border-radius: 3px;
        position: relative;
        
        // Shimmer effect
        &::after {
          content: '';
          position: absolute;
          top: 0;
          left: -100%;
          width: 70%;
          height: 100%;
          background: linear-gradient(
            90deg,
            transparent,
            rgba(255, 255, 255, 0.3),
            transparent
          );
          animation: shimmer 2s infinite;
        }
      }
    }
    
    .progress-text {
      font-size: 0.8rem;
      color: rgba(255, 255, 255, 0.7);
      text-align: left;
    }
  }
}

// Action buttons at the bottom
.modal-actions {
  display: flex;
  justify-content: center;
  gap: 15px;
  padding: 10px 15px 20px;
  
  // Button styling
  .action-btn {
    padding: 8px 20px;
    border: none;
    border-radius: 20px;
    font-size: 0.95rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    gap: 5px;
    
    // Close button (gray)
    &.close-btn {
      background: rgba(255, 255, 255, 0.1);
      color: white;
      
      &:hover {
        background: rgba(255, 255, 255, 0.2);
      }
    }
    
    // Share button (gold)
    &.share-btn {
      background: map-get(vars.$colors, 'accent', 'base');
      color: #0B1C17;
      
      &:hover {
        background: lighten(map-get(vars.$colors, 'accent', 'base'), 10%);
      }
      
      i {
        font-size: 0.9rem;
      }
    }
  }
}

// Particle animation for unlocked achievements
.achievement-particles {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  pointer-events: none;
  overflow: hidden;
  
  .particle {
    position: absolute;
    width: 5px;
    height: 5px;
    background: radial-gradient(circle, rgba(map-get(vars.$colors, 'accent', 'base'), 0.7) 0%, rgba(map-get(vars.$colors, 'accent', 'base'), 0) 70%);
    border-radius: 50%;
    opacity: 0;
    
    @for $i from 1 through 6 {
      &:nth-child(#{$i}) {
        $size: random(6) + 2 + px;
        width: $size;
        height: $size;
        left: random(100) + 0%;
        top: random(100) + 0%;
        animation: floatParticle 4s infinite ease-in-out;
        animation-delay: $i * 0.5s;
      }
    }
  }
}

// Animation keyframes
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes modalAnimation {
  from {
    opacity: 0;
    transform: scale(0.9);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

@keyframes float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-7px);
  }
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
    opacity: 0.8;
  }
  50% {
    transform: scale(1.1);
    opacity: 1;
  }
}

@keyframes shimmer {
  0% {
    left: -100%;
  }
  100% {
    left: 100%;
  }
}

@keyframes floatParticle {
  0% {
    transform: translate(0, 0);
    opacity: 0;
  }
  25% {
    opacity: 0.5;
  }
  50% {
    transform: translate(15px, -20px);
    opacity: 0.8;
  }
  75% {
    opacity: 0.4;
  }
  100% {
    transform: translate(30px, 0);
    opacity: 0;
  }
}
```

<details><summary>risultato tool</summary>

```
OK
```
</details>

**Artifact update: achievement-modal-typescript**

Sostituito:
```
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy, OnInit } from '@angular/core';
import { Achievement } from '../../../services/gamification.service';
import { trigger, transition, style, animate, query, stagger } from '@angular/animations';
import { PlatformService } from '../../../../../core/services/platform.service';

@Component({
  selector: 'app-achievement-details-modal',
  standalone: false,
  templateUrl: './achievement-details-modal.component.html',
  styleUrls: ['./achievement-details-modal.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    // Animation for the entire modal content
    trigger('modalContentAnimation', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('400ms cubic-bezier(0.4, 0.0, 0.2, 1)', style({ opacity: 1 })),
        // Animate child elements with stagger
        query('.badge-container, .achievement-title, .completion-banner, .achievement-description, .details-section, .achievement-progress, .action-buttons', [
          style({ opacity: 0, transform: 'translateY(20px)' }),
          stagger(80, [
            animate('400ms cubic-bezier(0.4, 0.0, 0.2, 1)', 
              style({ opacity: 1, transform: 'translateY(0)' }))
          ])
        ], { optional: true })
      ])
    ])
  ]
})
export class AchievementDetailsModalComponent implements OnInit {
  @Input() isOpen: boolean = false;
  @Input() achievement: Achievement | null = null;

  @Output() close = new EventEmitter<void>();
  @Output() share = new EventEmitter<Achievement>();

  // Flag to track if we've already played haptic feedback
  private hapticFeedbackPlayed = false;

  constructor(private platformService: PlatformService) {}

  ngOnInit() {
    // Reset haptic flag when component initializes
    this.hapticFeedbackPlayed = false;
  }

  /**
   * When the modal becomes visible, play haptic feedback based on achievement status
   */
  ngOnChanges() {
    // Only play haptic feedback once per modal opening
    if (this.isOpen && this.achievement && !this.hapticFeedbackPlayed) {
      this.playHapticFeedback();
      this.hapticFeedbackPlayed = true;
    }
    
    // Reset the flag when modal closes
    if (!this.isOpen) {
      this.hapticFeedbackPlayed = false;
    }
  }

  /**
   * Play appropriate haptic feedback based on achievement status
   */
  private playHapticFeedback() {
    if (!this.achievement) return;
    
    if (this.achievement.isUnlocked) {
      // Success vibration pattern for unlocked achievements
      this.platformService.vibrateSuccess().catch(() => {});
    } else {
      // Standard vibration for locked achievements
      this.platformService.vibrateWarning().catch(() => {});
    }
  }

  /**
   * Get badge image based on achievement type and unlock status
   */
  getBadgeImage(achievement: Achievement): string {
    const badgeType = achievement.type || 'bronze';
    const status = achievement.isUnlocked ? 'unlocked' : 'locked';
    return `assets/images/badges/${badgeType}_${status}.png`;
  }

  /**
   * Get readable requirement text
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
      case 'custom':
        return `إكمال المهمة المطلوبة`;
      default:
        return `إكمال المتطلبات`;
    }
  }

  /**
   * Get badge type label in Arabic
   */
  getBadgeTypeLabel(type: string): string {
    switch (type) {
      case 'bronze': return 'برونزي';
      case 'silver': return 'فضي';
      case 'gold': return 'ذهبي';
      case 'platinum': return 'بلاتيني';
      case 'diamond': return 'ماسي';
      default: return 'عادي';
    }
  }

  /**
   * Get rarity level text in Arabic
   */
  getRarityLevel(type: string): string {
    switch (type) {
      case 'bronze': return 'شائع';
      case 'silver': return 'غير شائع';
      case 'gold': return 'نادر';
      case 'platinum': return 'أسطوري';
      case 'diamond': return 'خرافي';
      default: return 'عادي';
    }
  }

  /**
   * Close the modal
   */
  onClose(): void {
    // Play haptic feedback when closing
    this.platformService.vibrateSuccess().catch(() => {});
    this.close.emit();
  }

  /**
   * Share the achievement
   */
  onShare(achievement: Achievement): void {
    // Play haptic feedback when sharing
    this.platformService.vibrateSuccess().catch(() => {});
    this.share.emit(achievement);
  }
}
```

con:
```
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy, OnInit, OnChanges } from '@angular/core';
import { Achievement } from '../../../services/gamification.service';
import { trigger, transition, style, animate } from '@angular/animations';
import { PlatformService } from '../../../../../core/services/platform.service';

@Component({
  selector: 'app-achievement-details-modal',
  standalone: false,
  templateUrl: './achievement-details-modal.component.html',
  styleUrls: ['./achievement-details-modal.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    // Fade-in animation for the overlay
    trigger('fadeIn', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('300ms ease-out', style({ opacity: 1 }))
      ]),
      transition(':leave', [
        animate('200ms ease-in', style({ opacity: 0 }))
      ])
    ]),
    // Scale-in animation for the modal
    trigger('modalAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.9)' }),
        animate('300ms cubic-bezier(0.25, 0.8, 0.25, 1)', 
          style({ opacity: 1, transform: 'scale(1)' }))
      ]),
      transition(':leave', [
        animate('200ms cubic-bezier(0.25, 0.8, 0.25, 1)', 
          style({ opacity: 0, transform: 'scale(0.9)' }))
      ])
    ])
  ]
})
export class AchievementDetailsModalComponent implements OnInit, OnChanges {
  @Input() isOpen: boolean = false;
  @Input() achievement: Achievement | null = null;

  @Output() close = new EventEmitter<void>();
  @Output() share = new EventEmitter<Achievement>();

  // Flag to track haptic feedback
  private hapticFeedbackPlayed = false;

  constructor(private platformService: PlatformService) {}

  ngOnInit() {
    this.hapticFeedbackPlayed = false;
  }

  ngOnChanges() {
    // Play haptic feedback when modal opens
    if (this.isOpen && this.achievement && !this.hapticFeedbackPlayed) {
      this.playHapticFeedback();
      this.hapticFeedbackPlayed = true;
    }
    
    // Reset the flag when modal closes
    if (!this.isOpen) {
      this.hapticFeedbackPlayed = false;
    }
  }

  /**
   * Play appropriate haptic feedback based on achievement status
   */
  private playHapticFeedback() {
    if (!this.achievement) return;
    
    if (this.achievement.isUnlocked) {
      // Success vibration for unlocked achievements
      this.platformService.vibrateSuccess().catch(() => {});
    } else {
      // Standard vibration for locked achievements
      this.platformService.vibrateWarning().catch(() => {});
    }
  }

  /**
   * Get badge image based on achievement type and unlock status
   */
  getBadgeImage(achievement: Achievement): string {
    const badgeType = achievement.type || 'bronze';
    const status = achievement.isUnlocked ? 'unlocked' : 'locked';
    return `assets/images/badges/${badgeType}_${status}.png`;
  }

  /**
   * Get requirement text in Arabic
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
      case 'custom':
        return `إكمال المهمة المطلوبة`;
      default:
        return `إكمال المتطلبات`;
    }
  }

  /**
   * Get badge type label in Arabic
   */
  getBadgeTypeLabel(type: string): string {
    switch (type) {
      case 'bronze': return 'برونزي';
      case 'silver': return 'فضي';
      case 'gold': return 'ذهبي';
      case 'platinum': return 'بلاتيني';
      case 'diamond': return 'ماسي';
      default: return 'عادي';
    }
  }

  /**
   * Close the modal
   */
  onClose(): void {
    this.platformService.vibrateSuccess().catch(() => {});
    this.close.emit();
  }

  /**
   * Share the achievement
   */
  onShare(achievement: Achievement): void {
    this.platformService.vibrateSuccess().catch(() => {});
    this.share.emit(achievement);
  }
}
```

<details><summary>risultato tool</summary>

```
OK
```
</details>



I've completely redesigned the achievement modal to better match your app's style and the feedback modal you mentioned. Here's what I've changed:

### Key Improvements:

1. **Simplified Layout & Better Scaling**
   - More compact design that fits better in landscape mode
   - Proper spacing that matches your app's scale from the screenshot
   - Clean, focused layout with better proportions

2. **Proper Blurred Background**
   - Full-screen overlay with backdrop blur effect
   - Similar to your feedback modal style
   - Proper z-index to ensure it displays above other content

3. **Badge Display**
   - Central badge display with subtle floating animation
   - Gold accents that match your app's color scheme
   - Lock overlay for locked achievements

4. **Streamlined Content**
   - Focused on essential information only
   - Clean details section that's easy to read
   - Progress bar that matches your app's style

5. **Responsive Design**
   - Optimized for landscape mode on mobile (your primary use case)
   - Automatically adjusts for both portrait and landscape orientations
   - Proper sizing for different screen dimensions

### Layout Structure:

The new modal is structured as a full-screen overlay with a centered content panel:

```
Achievement Modal
├── Blurred Overlay Background
├── Content Panel
│   ├── Close Button
│   ├── Achievement Title
│   ├── Main Content Area
│   │   ├── Badge Display (left)
│   │   │   ├── Badge Image
│   │   │   ├── Completion Status
│   │   │   └── Points Badge
│   │   └── Achievement Info (right)
│   │       ├── Description
│   │       ├── Details List
│   │       └── Progress Bar
│   └── Action Buttons
└── Particle Effects (for unlocked achievements)
```

This implementation uses standard DOM elements with animations rather than a complex component setup, making it lighter weight and directly similar to your feedback modal style. It's also more appropriate for your app's scale as shown in the screenshot.

Would you like me to make any additional adjustments to better match your app's style?
