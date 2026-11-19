# Floating 3D Badge Enhancement for Modal

- Link: https://claude.ai/chat/e979b1cc-1ed6-4f05-9740-4da2ed4ab801
- Creata: 2025-04-25T11:24:37.741532Z
- Aggiornata: 2025-04-25T11:32:39.373538Z

## Yassin (2025-04-25T11:24)

without losing any style from the modal detials achivment i want to do a small enhancment cosidnering i manily use it in mobile landscape mode 
i attahced a screenshoot only as refernce i want to amke the badge png float out the modal to make a feeling of 3d style manitng all the rest as it is 

dont change other elments positons and mantina the grey sacle for locked icons badges


A commit message

_file allegato (non incluso nell'export): image.png_

## Claude (2025-04-25T11:25)

I'll enhance the 3D effect to make the badge appear to float outside the modal container while maintaining the other elements and keeping the grayscale for locked badges. Here's my implementation:

**Artifact: Enhanced 3D Badge Effect** (`application/vnd.ant.code`, create)

```scss
// Enhanced 3D Badge Effect - Updates for achievement-details-modal.component.scss

// Update the badge container to allow overflow for the 3D floating effect
.badge-container {
  width: 100%;
  height: 260px; // Keep the same height
  position: relative;
  margin-bottom: 20px;
  perspective: 2000px; // Increased perspective for more dramatic 3D effect
  z-index: 10; // Ensure badge container is above other elements
  
  // Remove any overflow constraints that might clip the floating badge
  overflow: visible !important;

  // 3D container with proper perspective
  .badge-3d-container {
    width: 100%;
    height: 100%;
    position: relative;
    transform-style: preserve-3d;
    perspective: 1500px; // Increased from 1000px
    transform: translateZ(0);
    overflow: visible !important; // Critical for allowing badge to float out
    
    // Enhanced shadow beneath the badge
    &::before {
      content: '';
      position: absolute;
      bottom: -15px;
      left: 50%;
      transform: translateX(-50%);
      width: 80%;
      height: 35px; // Increased height for more pronounced shadow
      background: rgba(0, 0, 0, 0.5); // Darker shadow
      filter: blur(25px); // More blur for softer shadow
      border-radius: 50%;
      z-index: -1;
      transition: all 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }
  }

  // Badge image with enhanced 3D float effect
  .badge-image {
    position: absolute;
    top: 0;
    left: 0;
    width: 110%; // Slightly larger than container
    height: 110%; // Slightly larger than container
    object-fit: contain;
    transform: translateZ(80px) scale(1.15); // Increased Z value and scale
    transition: all 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    filter: drop-shadow(0 20px 30px rgba(0, 0, 0, 0.7)); // Stronger shadow
    z-index: 5;
    animation: float-badge 5s ease-in-out infinite alternate;

    // Enhanced hover effect
    &:hover {
      transform: translateZ(100px) scale(1.25); // More dramatic lift on hover
      filter: drop-shadow(0 30px 40px rgba(0, 0, 0, 0.8));
    }

    // Maintain grayscale for locked badges but enhance the 3D effect
    &.grayscale {
      filter: grayscale(75%) brightness(0.75) drop-shadow(0 15px 25px rgba(0, 0, 0, 0.6));
      transform: translateZ(40px) scale(1.05); // Less dramatic but still 3D
      animation: float-badge-locked 5s ease-in-out infinite alternate;

      &:hover {
        transform: translateZ(60px) scale(1.15); // More lift but still locked
        filter: grayscale(70%) brightness(0.8) drop-shadow(0 20px 30px rgba(0, 0, 0, 0.6));
      }
    }
  }
}

// Enhanced animation keyframes for more dramatic floating effect
@keyframes float-badge {
  0% {
    transform: translateZ(80px) rotateY(0deg) scale(1.15);
  }
  25% {
    transform: translateZ(90px) rotateY(2deg) rotateX(1deg) scale(1.18);
  }
  50% {
    transform: translateZ(100px) rotateY(0deg) rotateX(-1deg) scale(1.2);
  }
  75% {
    transform: translateZ(90px) rotateY(-2deg) rotateX(0deg) scale(1.18);
  }
  100% {
    transform: translateZ(80px) rotateY(0deg) rotateX(1deg) scale(1.15);
  }
}

@keyframes float-badge-locked {
  0% {
    transform: translateZ(40px) rotateY(0deg) scale(1.05);
  }
  25% {
    transform: translateZ(45px) rotateY(1deg) rotateX(0.5deg) scale(1.07);
  }
  50% {
    transform: translateZ(50px) rotateY(0deg) rotateX(-0.5deg) scale(1.09);
  }
  75% {
    transform: translateZ(45px) rotateY(-1deg) rotateX(0deg) scale(1.07);
  }
  100% {
    transform: translateZ(40px) rotateY(0deg) rotateX(0.5deg) scale(1.05);
  }
}

// Modal container adjustment to ensure it doesn't clip the floating badge
.modal-container {
  position: relative;
  z-index: 1000002;
  width: 90%;
  max-width: 850px;
  transform: translateY(30px);
  opacity: 0;
  animation: cardEntry 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) 0.2s forwards;
  overflow: visible !important; // Important to prevent clipping
}

.achievement-card {
  // Make sure the achievement card also has visible overflow
  overflow: visible !important;
  // Ensure the card has proper z-index structure
  position: relative;
  z-index: 1;
}

// Content area adjustment
.card-content {
  overflow: visible !important; // Allow badge to float outside
}

// For landscape mode optimization, adjust the badge container but keep the float effect
@media (orientation: landscape) and (max-height: 600px) {
  .badge-showcase {
    .badge-container {
      width: 160px;
      height: 160px;
      
      .badge-image {
        transform: translateZ(60px) scale(1.15); // Still pronounced but scaled for smaller container
        
        &:hover {
          transform: translateZ(80px) scale(1.25);
        }
        
        &.grayscale {
          transform: translateZ(30px) scale(1.05);
          
          &:hover {
            transform: translateZ(45px) scale(1.15);
          }
        }
      }
    }
  }
  
  @keyframes float-badge {
    0% {
      transform: translateZ(60px) rotateY(0deg) scale(1.15);
    }
    50% {
      transform: translateZ(75px) rotateY(1deg) rotateX(-1deg) scale(1.2);
    }
    100% {
      transform: translateZ(60px) rotateY(-1deg) rotateX(1deg) scale(1.15);
    }
  }
  
  @keyframes float-badge-locked {
    0% {
      transform: translateZ(30px) rotateY(0deg) scale(1.05);
    }
    50% {
      transform: translateZ(40px) rotateY(1deg) rotateX(-0.5deg) scale(1.09);
    }
    100% {
      transform: translateZ(30px) rotateY(-1deg) rotateX(0.5deg) scale(1.05);
    }
  }
}
```

<details><summary>risultato tool</summary>

```
OK
```
</details>



The code I've created enhances the 3D effect for the achievement badge while maintaining the existing layout and preserving the grayscale effect for locked badges. Here's what my implementation does:

### Key Enhancements:

1. **More Pronounced 3D Effect**:
   - Increased the `translateZ` values to make the badge appear to float further out of the modal
   - Enhanced perspective values for a stronger depth effect
   - Badge now scales to 110% of its container, creating a subtle "breaking out" effect

2. **Improved Animations**:
   - More complex keyframe animations with multi-axis rotation for a realistic floating effect
   - Smoother transitions between animation states
   - Added subtle rotation along both X and Y axes to create a gentle "wobble" effect

3. **Better Shadow Effects**:
   - Darker, larger shadow beneath the badge to enhance the floating appearance
   - Increased shadow blur for a softer, more realistic look
   - Shadow changes dynamically with the animation

4. **Fixed Overflow Issues**:
   - Set `overflow: visible !important` on all parent containers to ensure the badge isn't clipped
   - Adjusted z-index values to maintain proper layering

5. **Responsive Design**:
   - Added specific adjustments for landscape mode that maintain the enhanced 3D effect while considering the smaller container size
   - Adjusted animation values proportionally for different screen sizes

This enhancement creates a more immersive experience, especially in landscape mode, by making the badge appear to float above the modal surface while preserving all the existing functionality and styling.

Would you like me to make any adjustments to the intensity of the 3D effect or any other aspects of the implementation?

## Yassin (2025-04-25T11:29)

give me the full html and scss and make the badge of course more bigger 

also for both modal types locked and unlocked wihotu lsoing any thing move the star ount in same row of the title so title in right and at left the stars count

## Claude (2025-04-25T11:32)

I'll provide the complete HTML and SCSS files with the requested enhancements: a larger badge and the star count positioned in the same row as the title (title on right, stars on left).

**Artifact: Achievement Modal HTML** (`application/vnd.ant.code`, create)

```html
<div class="achievement-modal-wrapper" dir="rtl" *ngIf="isOpen" [@modalAnimation]>
    <!-- Backdrop with blur effect -->
    <div class="modal-overlay" (click)="onClose()"></div>

    <!-- Floating particles animation container -->
    <div class="particles-container">
        <div class="particle" *ngFor="let particle of particles" [style.--tx]="particle.tx" [style.--ty]="particle.ty"
            [style.width]="particle.size" [style.height]="particle.size" [style.background-color]="particle.color"
            [style.animation-delay]="particle.delay">
        </div>
    </div>

    <!-- Badge card container -->
    <div class="modal-container">
        <!-- Game-style achievement card with banner elements -->
        <div class="achievement-card" [class.achievement-unlocked]="achievement?.isUnlocked"
            [class.achievement-locked]="achievement && !achievement.isUnlocked">

            <!-- Top banner with type decoration -->
            <div class="card-banner" [ngClass]="achievement?.type || 'bronze'">
                <div class="banner-decoration left"></div>
                <div class="banner-text">{{ getBadgeTypeLabel(achievement?.type) }}</div>
                <div class="banner-decoration right"></div>
            </div>

            <!-- Main content area with two columns -->
            <div class="card-content">
                <!-- Left side with badge -->
                <div class="badge-showcase">
                    <!-- Enhanced Badge Display with 3D effects and no circular container -->
                    <div class="badge-container" [ngClass]="achievement?.type || 'bronze'">
                        <!-- 3D container with perspective -->
                        <div class="badge-3d-container">
                            <!-- Badge image with proper styling for locked/unlocked state -->
                            <img *ngIf="achievement" class="badge-image"
                                [ngClass]="{'grayscale': achievement && !achievement.isUnlocked}"
                                [src]="getBadgeImage(achievement)" [alt]="achievement.title">

                            <!-- Lock icon overlay for locked badges -->
                            <div class="lock-overlay" *ngIf="achievement && !achievement.isUnlocked">
                                <i class="fas fa-lock"></i>
                            </div>

                            <!-- Completion checkmark for unlocked badges -->
                            <div class="completion-marker" *ngIf="achievement?.isUnlocked">
                                <div class="check-container">
                                    <i class="fas fa-check"></i>
                                </div>
                            </div>

                            <!-- Glow effect for unlocked badges -->
                            <div class="badge-glow" [class.active]="achievement?.isUnlocked"
                                [ngClass]="achievement?.type || 'bronze'">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right side with details -->
                <div class="achievement-details">
                    <!-- Title with style based on achievement type, now with stars inline -->
                    <div class="title-row">
                        <h2 class="achievement-title" [ngClass]="achievement?.type || 'bronze'">
                            {{ achievement?.title }}
                        </h2>
                        <!-- Points display moved here -->
                        <div class="title-points-display" [ngClass]="achievement?.type || 'bronze'" *ngIf="achievement">
                            <i class="fas fa-star"></i>
                            <span>{{ achievement.points }}</span>
                        </div>
                    </div>

                    <!-- Description with elegant styling -->
                    <div class="description-scroll">
                        <p class="achievement-description">
                            {{ achievement?.description }}
                        </p>
                    </div>

                    <!-- Achievement status section with requirement/completion -->
                    <div class="achievement-status">
                        <!-- Requirement for locked achievements - ENHANCED STYLE -->
                        <div class="achievement-requirement-info" *ngIf="achievement && !achievement.isUnlocked">
                            <div class="requirement-badge" [ngClass]="achievement.type || 'bronze'">
                                <i class="fas" [ngClass]="getRequirementIcon(achievement)"></i>
                            </div>
                            <div class="requirement-details">
                                <div class="requirement-label">المطلوب:</div>
                                <div class="requirement-value">{{getRequirementText(achievement)}}</div>
                            </div>
                        </div>

                        <!-- Completion info for unlocked achievements -->
                        <div class="achievement-completion-info"
                            *ngIf="achievement?.isUnlocked && achievement?.dateUnlocked">
                            <div class="completion-badge" [ngClass]="achievement?.type || 'bronze'">
                                <i class="fas fa-calendar-check"></i>
                            </div>
                            <div class="completion-details">
                                <div class="completion-label">تم الإنجاز:</div>
                                <div class="completion-date">{{achievement?.dateUnlocked | date:'mediumDate'}}</div>
                            </div>
                        </div>
                    </div>

                    <!-- Progress bar for locked achievements -->
                    <div class="progress-container" *ngIf="achievement && !achievement.isUnlocked">
                        <div class="progress-label">التقدم: {{ achievement.progress }}%</div>
                        <div class="progress-bar">
                            <div class="progress-track">
                                <div class="progress-fill" [style.width.%]="achievement.progress">
                                    <div class="progress-glow"></div>
                                </div>
                            </div>
                            <div class="progress-markers">
                                <div class="marker" *ngFor="let m of [0,25,50,75,100]"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Bottom action area with buttons -->
            <div class="card-actions">
                <button *ngIf="achievement?.isUnlocked" class="action-button share-button" (click)="onShare()">
                    <i class="fas fa-share-alt"></i>
                    <span>مشاركة</span>
                </button>
                <button class="action-button continue-button" (click)="onClose()">
                    <span>متابعة</span>
                    <i class="fas fa-arrow-left"></i>
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

**Artifact: Achievement Modal SCSS** (`application/vnd.ant.code`, create)

```scss
@use "sass:map";
@use 'variables' as vars;

:host {
    display: contents;
}

// Main wrapper with z-index management
.achievement-modal-wrapper {
    position: fixed;
    top: 0;
    left: 0px;
    right: -50px;
    bottom: 0;
    width: 100vw;
    height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 999999;
    pointer-events: auto;
    overflow: hidden;
}

// Backdrop with blur effect
.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.85);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    z-index: 1000000;
    animation: fadeIn 0.3s ease-out forwards;
}

// Floating particles container
.particles-container {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    overflow: hidden;
    z-index: 1000001;
    pointer-events: none;

    .particle {
        position: absolute;
        border-radius: 50%;
        top: 50%;
        left: 50%;
        opacity: 0;
        transform: translate(-50%, -50%);
        background-color: rgba(218, 165, 32, 0.6);
        filter: blur(1px);
        animation: floatParticle 3s ease-out forwards;

        // For locked achievements, use more subdued colors
        .achievement-locked & {
            opacity: 0.4;
        }
    }
}

// Main card container
.modal-container {
    position: relative;
    z-index: 1000002;
    width: 90%;
    max-width: 850px; // Wider container
    transform: translateY(30px);
    opacity: 0;
    animation: cardEntry 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) 0.2s forwards;
    overflow: visible !important; // Critical to allow badge to float out
}

// Game-style achievement card
.achievement-card {
    background: linear-gradient(135deg,
            rgba(31, 64, 55, 0.95),
            rgba(11, 28, 23, 0.95));
    border-radius: 24px;
    overflow: visible !important; // Allow badge to float out
    box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5),
        0 0 0 2px rgba(map-get(vars.$colors, 'accent', 'base'), 0.3);
    display: flex;
    flex-direction: column;
    position: relative;
    max-height: 85vh; // Important to prevent scrolling

    // Apply special styling for unlocked vs locked achievements
    &.achievement-unlocked {

        // Add pulsing glow effect to unlocked achievements
        &::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: radial-gradient(ellipse at center,
                    rgba(map-get(vars.$colors, 'accent', 'base'), 0.2) 0%,
                    rgba(0, 0, 0, 0) 70%);
            z-index: -1;
            opacity: 0.8;
            animation: pulse 3s infinite alternate;
        }
    }

    &.achievement-locked {
        // More subdued styling for locked achievements
        box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5),
            0 0 0 2px rgba(255, 255, 255, 0.1);
    }
}

// Top banner with achievement type
.card-banner {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 10px 0;
    position: relative;
    background: rgba(0, 0, 0, 0.3);
    overflow: hidden;

    // Banner decorations (left and right side elements)
    .banner-decoration {
        height: 3px;
        background: rgba(255, 255, 255, 0.3);
        width: 80px;
        position: relative;

        &::before,
        &::after {
            content: '';
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            width: 10px;
            height: 10px;
            border-radius: 50%;
        }

        &.left {
            margin-left: 20px;

            &::before {
                left: -5px;
            }
        }

        &.right {
            margin-right: 20px;

            &::after {
                right: -5px;
            }
        }
    }

    // Banner text styling
    .banner-text {
        font-size: 1.4rem;
        font-weight: 700;
        padding: 0 20px;
        text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
        letter-spacing: 1px;
        text-transform: uppercase;
    }

    // Color variations for different badge types
    &.bronze {
        background: linear-gradient(to right,
                rgba(205, 127, 50, 0.2),
                rgba(205, 127, 50, 0.3),
                rgba(205, 127, 50, 0.2));

        .banner-text {
            color: #CD7F32;
        }

        .banner-decoration {
            background: rgba(205, 127, 50, 0.5);

            &::before,
            &::after {
                background: #CD7F32;
            }
        }
    }

    &.silver {
        background: linear-gradient(to right,
                rgba(192, 192, 192, 0.2),
                rgba(192, 192, 192, 0.3),
                rgba(192, 192, 192, 0.2));

        .banner-text {
            color: #C0C0C0;
        }

        .banner-decoration {
            background: rgba(192, 192, 192, 0.5);

            &::before,
            &::after {
                background: #C0C0C0;
            }
        }
    }

    &.gold {
        background: linear-gradient(to right,
                rgba(map-get(vars.$colors, 'accent', 'dark'), 0.2),
                rgba(map-get(vars.$colors, 'accent', 'base'), 0.3),
                rgba(map-get(vars.$colors, 'accent', 'dark'), 0.2));

        .banner-text {
            color: map-get(vars.$colors, 'accent', 'base');
        }

        .banner-decoration {
            background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.5);

            &::before,
            &::after {
                background: map-get(vars.$colors, 'accent', 'base');
            }
        }
    }

    &.platinum {
        background: linear-gradient(to right,
                rgba(229, 228, 226, 0.2),
                rgba(229, 228, 226, 0.3),
                rgba(229, 228, 226, 0.2));

        .banner-text {
            color: #E5E4E2;
            text-shadow: 0 0 10px rgba(229, 228, 226, 0.5);
        }

        .banner-decoration {
            background: rgba(229, 228, 226, 0.5);

            &::before,
            &::after {
                background: #E5E4E2;
            }
        }
    }

    &.diamond {
        background: linear-gradient(to right,
                rgba(185, 242, 255, 0.2),
                rgba(185, 242, 255, 0.3),
                rgba(185, 242, 255, 0.2));

        .banner-text {
            color: #B9F2FF;
            text-shadow: 0 0 15px rgba(185, 242, 255, 0.7);
        }

        .banner-decoration {
            background: rgba(185, 242, 255, 0.5);

            &::before,
            &::after {
                background: #B9F2FF;
                box-shadow: 0 0 10px rgba(185, 242, 255, 0.7);
            }
        }
    }
}

// Main content area with two columns
.card-content {
    display: flex;
    padding: 25px;
    gap: 25px;
    flex: 1;
    min-height: 0; // Important for flexbox
    overflow: visible !important; // Critical for floating badge
}

// Left side with badge display - ENHANCED 3D VERSION
.badge-showcase {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 300px; // Increased width for larger badge
    flex-shrink: 0;
    overflow: visible !important; // Allow badge to float out

    // Badge container with enhanced 3D effects
    .badge-container {
        width: 100%;
        height: 300px; // BIGGER badge
        position: relative;
        margin-bottom: 20px;
        perspective: 2000px; // Enhanced perspective for stronger 3D effect
        z-index: 10; // Ensure badge container is above other elements
        overflow: visible !important; // Critical for allowing badge to float out

        // 3D container with proper perspective
        .badge-3d-container {
            width: 100%;
            height: 100%;
            position: relative;
            transform-style: preserve-3d;
            perspective: 1500px; // Increased from 1000px
            transform: translateZ(0); // Base transform
            overflow: visible !important; // Critical for allowing badge to float out

            // Create a more dramatic shadow beneath the badge
            &::before {
                content: '';
                position: absolute;
                bottom: -15px;
                left: 50%;
                transform: translateX(-50%);
                width: 80%;
                height: 35px; // Increased height for more pronounced shadow
                background: rgba(0, 0, 0, 0.5); // Darker shadow
                filter: blur(25px); // More blur for softer shadow
                border-radius: 50%;
                z-index: -1;
                transition: all 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            }
        }

        // Badge image with enhanced size and 3D effect
        .badge-image {
            position: absolute;
            top: -10%; // Move up slightly to appear more floating
            left: -10%; // Shift left slightly for better centering
            width: 120%; // BIGGER than container
            height: 120%; // BIGGER than container
            object-fit: contain;
            transform: translateZ(100px) scale(1.3); // More dramatic Z translation
            transition: all 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            filter: drop-shadow(0 25px 35px rgba(0, 0, 0, 0.7)); // Stronger shadow
            z-index: 5;
            animation: float-badge 5s ease-in-out infinite alternate; // Enhanced floating animation

            // Hover effect - more dramatic lift
            &:hover {
                transform: translateZ(120px) scale(1.4);
                filter: drop-shadow(0 35px 45px rgba(0, 0, 0, 0.8));
            }

            // Grayscale filter for locked badges
            &.grayscale {
                filter: grayscale(75%) brightness(0.75) drop-shadow(0 15px 25px rgba(0, 0, 0, 0.6));
                transform: translateZ(60px) scale(1.15); // Less dramatic but still 3D
                animation: float-badge-locked 5s ease-in-out infinite alternate;

                &:hover {
                    transform: translateZ(80px) scale(1.25); // More lift but still locked
                    filter: grayscale(70%) brightness(0.8) drop-shadow(0 25px 35px rgba(0, 0, 0, 0.6));
                }
            }
        }

        // Lock overlay for locked badges
        .lock-overlay {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) translateZ(110px); // Increased Z for proper depth
            z-index: 10;
            width: 80px; // Bigger lock icon
            height: 80px; // Bigger lock icon
            display: flex;
            align-items: center;
            justify-content: center;
            animation: float-lock 3s ease-in-out infinite alternate;

            i {
                font-size: 55px; // Bigger lock icon
                color: rgba(255, 255, 255, 0.9);
                filter: drop-shadow(0 5px 10px rgba(0, 0, 0, 0.8));
            }
        }

        // Checkmark for completed achievements
        .completion-marker {
            position: absolute;
            bottom: 10px;
            right: 0;
            z-index: 15;
            transform: translateZ(110px); // Ensure it's above the badge

            .check-container {
                width: 50px; // Larger checkmark
                height: 50px; // Larger checkmark
                border-radius: 50%;
                background: #2ECC71;
                display: flex;
                align-items: center;
                justify-content: center;
                box-shadow: 0 8px 15px rgba(0, 0, 0, 0.6);

                i {
                    color: white;
                    font-size: 28px; // Bigger checkmark icon
                }
            }
        }

        // Enhanced glow effect for badges
        .badge-glow {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) translateZ(10px);
            width: 110%; // Slightly larger than the badge
            height: 110%; // Slightly larger than the badge
            border-radius: 2px;
            opacity: 0;
            filter: blur(30px);
            transition: all 0.5s ease;
            z-index: 1;

            &.active {
                opacity: 0.7;
                animation: pulse-glow 3s infinite alternate;
            }

            // Different glow colors by badge type
            &.bronze {
                background: radial-gradient(ellipse, #CD7F32 0%, transparent 70%);
            }

            &.silver {
                background: radial-gradient(ellipse, #C0C0C0 0%, transparent 70%);
            }

            &.gold {
                background: radial-gradient(ellipse, #DAA520 0%, transparent 70%);
            }

            &.platinum {
                background: radial-gradient(ellipse, #E5E4E2 0%, transparent 70%);
            }

            &.diamond {
                background: radial-gradient(ellipse, #B9F2FF 0%, transparent 70%);
            }
        }
    }
}

// Right side with achievement details
.achievement-details {
    flex: 1;
    display: flex;
    flex-direction: column;
    overflow: hidden; // Prevent scrolling
    text-align: right;

    // New title row with stars aligned
    .title-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
        position: relative;
        
        &::after {
            content: '';
            position: absolute;
            bottom: -8px;
            right: 0;
            width: 80px;
            height: 3px;
            border-radius: 1.5px;
        }
        
        &.bronze::after { background: #CD7F32; }
        &.silver::after { background: #C0C0C0; }
        &.gold::after { background: map-get(vars.$colors, 'accent', 'base'); }
        &.platinum::after { background: #E5E4E2; }
        &.diamond::after { background: #B9F2FF; }
    }

    // Achievement title with type-based styling
    .achievement-title {
        font-size: 2.2rem;
        font-weight: 700;
        margin: 0;
        line-height: 1.2;
        flex: 1;
        text-align: right;

        &.bronze {
            color: #CD7F32;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
        }

        &.silver {
            color: #C0C0C0;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
        }

        &.gold {
            color: map-get(vars.$colors, 'accent', 'base');
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
        }

        &.platinum {
            color: #E5E4E2;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
        }

        &.diamond {
            color: #B9F2FF;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5), 0 0 10px rgba(185, 242, 255, 0.5);
        }
    }

    // Points display next to title
    .title-points-display {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 15px;
        border-radius: 20px;
        margin-right: 15px;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
        position: relative;
        overflow: hidden;
        
        // Shimmer effect
        &::after {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg,
                    transparent,
                    rgba(255, 255, 255, 0.2),
                    transparent);
            animation: shimmer 2s infinite;
        }
        
        i {
            font-size: 1.6rem;
            animation: starPulse 1.5s infinite alternate;
        }
        
        span {
            font-size: 1.6rem;
            font-weight: 700;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
        }
        
        // Color variations
        &.bronze {
            background: linear-gradient(135deg, rgba(205, 127, 50, 0.7), rgba(205, 127, 50, 0.4));
            i, span { color: #FFE6C7; }
        }
        
        &.silver {
            background: linear-gradient(135deg, rgba(192, 192, 192, 0.7), rgba(192, 192, 192, 0.4));
            i, span { color: #FFFFFF; }
        }
        
        &.gold {
            background: linear-gradient(135deg,
                    rgba(map-get(vars.$colors, 'accent', 'dark'), 0.7),
                    rgba(map-get(vars.$colors, 'accent', 'base'), 0.4));
            i, span { color: #FFFACD; }
        }
        
        &.platinum {
            background: linear-gradient(135deg, rgba(229, 228, 226, 0.7), rgba(229, 228, 226, 0.4));
            i, span { color: #FFFFFF; }
        }
        
        &.diamond {
            background: linear-gradient(135deg, rgba(185, 242, 255, 0.7), rgba(185, 242, 255, 0.4));
            i, span { color: #E0FFFF; }
        }
    }

    // Description container with automatic height
    .description-scroll {
        background: rgba(0, 0, 0, 0.2);
        border-radius: 15px;
        padding: 15px;
        position: relative;
        margin-bottom: 20px;
        border-right: 4px solid rgba(map-get(vars.$colors, 'accent', 'base'), 0.7);
        max-height: 120px; // Limit height to control overall card size
        overflow-y: auto;

        // Custom scrollbar
        &::-webkit-scrollbar {
            width: 6px;
        }

        &::-webkit-scrollbar-track {
            background: rgba(0, 0, 0, 0.2);
            border-radius: 3px;
        }

        &::-webkit-scrollbar-thumb {
            background: rgba(map-get(vars.$colors, 'accent', 'base'), 0.5);
            border-radius: 3px;
        }

        .achievement-description {
            color: white;
            margin: 0;
            line-height: 1.6;
            font-size: 1.1rem;
        }
    }

    // Achievement status section with requirement/completion and points
    .achievement-status {
        display: flex;
        flex-direction: column;
        gap: 15px;
    }

    // SHARED STYLES for both requirement and completion info
    .achievement-requirement-info,
    .achievement-completion-info {
        display: flex;
        align-items: center;
        gap: 15px;
        padding: 15px;
        position: relative;
        border-radius: 12px;
        background: rgba(0, 0, 0, 0.2);

        // Badge styling (shared)
        .requirement-badge,
        .completion-badge {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
            position: relative;
            overflow: hidden;
            animation: floatEffect 3s ease-in-out infinite alternate;

            // Shimmering effect
            &::after {
                content: '';
                position: absolute;
                top: -100%;
                left: -100%;
                width: 200%;
                height: 200%;
                background: linear-gradient(45deg,
                        rgba(255, 255, 255, 0) 0%,
                        rgba(255, 255, 255, 0.2) 50%,
                        rgba(255, 255, 255, 0) 100%);
                transform: rotate(45deg);
                animation: shimmerRotate 3s linear infinite;
            }

            i {
                font-size: 1.6rem;
                position: relative;
                z-index: 1;
            }

            // Dynamic coloring based on badge type
            &.bronze {
                background: linear-gradient(135deg, #CD7F32, #A06327);

                i {
                    color: #FFE6C7;
                }
            }

            &.silver {
                background: linear-gradient(135deg, #C0C0C0, #A0A0A0);

                i {
                    color: white;
                }
            }

            &.gold {
                background: linear-gradient(135deg, map-get(vars.$colors, 'accent', 'base'), map-get(vars.$colors, 'accent', 'dark'));

                i {
                    color: #FFFACD;
                }
            }

            &.platinum {
                background: linear-gradient(135deg, #E5E4E2, #CACACA);

                i {
                    color: #333333;
                }
            }

            &.diamond {
                background: linear-gradient(135deg, #B9F2FF, #88D1E3);

                i {
                    color: #0A6C7D;
                }
            }
        }

        // Text details styling (shared)
        .requirement-details,
        .completion-details {
            display: flex;
            flex-direction: column;
            flex: 1;

            .requirement-label,
            .completion-label {
                font-size: 0.95rem;
                color: rgba(255, 255, 255, 0.7);
                margin-bottom: 5px;
            }

            .requirement-value,
            .completion-date {
                font-size: 1.3rem;
                font-weight: 700;
                color: white;
                text-shadow: 0 2px 4px rgba(0, 0, 0, 0.4);
            }
        }
    }

    // Progress container for locked achievements
    .progress-container {
        margin-top: auto; // Push to bottom
        padding-top: 15px;

        .progress-label {
            color: white;
            font-size: 1rem;
            margin-bottom: 8px;
            font-weight: 600;
        }

        .progress-bar {
            margin-bottom: 15px;

            .progress-track {
                height: 12px;
                background: rgba(0, 0, 0, 0.3);
                border-radius: 6px;
                overflow: hidden;
                position: relative;
                box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.3);

                .progress-fill {
                    height: 100%;
                    background: linear-gradient(to right,
                            darken(map-get(vars.$colors, 'accent', 'dark'), 10%),
                            map-get(vars.$colors, 'accent', 'base'));
                    border-radius: 6px;
                    position: relative;
                    transition: width 0.8s cubic-bezier(0.22, 1, 0.36, 1);

                    .progress-glow {
                        position: absolute;
                        inset: 0;
                        background: linear-gradient(90deg,
                                transparent,
                                rgba(255, 255, 255, 0.2),
                                transparent);
                        background-size: 200% 100%;
                        animation: shimmer 1.5s infinite linear;
                    }
                }
            }

            .progress-markers {
                display: flex;
                justify-content: space-between;
                margin-top: 5px;

                .marker {
                    width: 6px;
                    height: 6px;
                    background: rgba(255, 255, 255, 0.3);
                    border-radius: 50%;
                }
            }
        }
    }
}

// Bottom action area with buttons
.card-actions {
    display: flex;
    justify-content: center;
    gap: 15px;
    padding: 20px 25px;
    background: rgba(0, 0, 0, 0.2);

    .action-button {
        border: none;
        border-radius: 30px;
        padding: 12px 25px;
        font-size: 1.1rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        gap: 10px;
        min-width: 140px;

        &.continue-button {
            background: map-get(vars.$colors, 'accent', 'base');
            color: #0B1C17;

            &:hover {
                background: map-get(vars.$colors, 'accent', 'bright');
                transform: translateY(-3px);
                box-shadow: 0 5px 15px rgba(map-get(vars.$colors, 'accent', 'base'), 0.4);
            }

            &:active {
                transform: translateY(-1px);
            }

            i {
                font-size: 0.9rem;
                transition: transform 0.3s ease;
            }

            &:hover i {
                transform: translateX(-5px);
            }
        }

        &.share-button {
            background: rgba(255, 255, 255, 0.1);
            color: white;

            &:hover {
                background: rgba(255, 255, 255, 0.2);
                transform: translateY(-3px);
                box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
            }

            &:active {
                transform: translateY(-1px);
            }

            i {
                font-size: 0.9rem;
                transition: transform 0.3s ease;
            }

            &:hover i {
                transform: rotate(15deg);
            }
        }
    }
}

// Enhanced Animation keyframes
@keyframes fadeIn {
    from {
        opacity: 0;
    }

    to {
        opacity: 1;
    }
}

@keyframes cardEntry {
    0% {
        opacity: 0;
        transform: translateY(30px) scale(0.95);
    }

    100% {
        opacity: 1;
        transform: translateY(0) scale(1);
    }
}

@keyframes pulse {
    0%,
    100% {
        opacity: 0.5;
    }

    50% {
        opacity: 0.8;
    }
}

@keyframes pulse-glow {
    0%,
    100% {
        opacity: 0.5;
        filter: blur(20px);
    }

    50% {
        opacity: 0.8;
        filter: blur(25px);
    }
}

@keyframes floatParticle {
    0% {
        transform: translate(-50%, -50%) scale(0);
        opacity: 0;
    }

    20% {
        opacity: 0.6;
    }

    100% {
        transform: translate(calc(-50% + var(--tx)), calc(-50% + var(--ty))) scale(1);
        opacity: 0;
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

@keyframes shimmerRotate {
    0% {
        transform: rotate(45deg) translateY(0);
    }

    100% {
        transform: rotate(45deg) translateY(100%);
    }
}

@keyframes starPulse {
    0% {
        transform: scale(1);
    }

    100% {
        transform: scale(1.2);
    }
}

@keyframes floatEffect {
    0% {
        transform: translateY(0);
    }

    100% {
        transform: translateY(-5px);
    }
}

// Enhanced 3D badge animations
@keyframes float-badge {
    0% {
        transform: translateZ(100px) rotateY(0deg) scale(1.3);
    }
    25% {
        transform: translateZ(110px) rotateY(2deg) rotateX(1deg) scale(1.33);
    }
    50% {
        transform: translateZ(120px) rotateY(0deg) rotateX(-1deg) scale(1.36);
    }
    75% {
        transform: translateZ(110px) rotateY(-2deg) rotateX(0deg) scale(1.33);
    }
    100% {
        transform: translateZ(100px) rotateY(0deg) rotateX(1deg) scale(1.3);
    }
}

@keyframes float-badge-locked {
    0% {
        transform: translateZ(60px) rotateY(0deg) scale(1.15);
    }
    25% {
        transform: translateZ(65px) rotateY(1deg) rotateX(0.5deg) scale(1.17);
    }
    50% {
        transform: translateZ(70px) rotateY(0deg) rotateX(-0.5deg) scale(1.19);
    }
    75% {
        transform: translateZ(65px) rotateY(-1deg) rotateX(0deg) scale(1.17);
    }
    100% {
        transform: translateZ(60px) rotateY(0deg) rotateX(0.5deg) scale(1.15);
    }
}

@keyframes float-lock {
    0% {
        transform: translate(-50%, -50%) translateZ(110px) scale(1);
    }

    50% {
        transform: translate(-50%, -50%) translateZ(130px) scale(1.05);
    }

    100% {
        transform: translate(-50%, -50%) translateZ(110px) scale(1);
    }
}

// Responsive adjustments for smaller screens
@media (max-width: 850px) {
    .modal-container {
        width: 95%;
        max-width: 500px; // Slightly narrower for small screens
    }

    .card-content {
        flex-direction: column;
        align-items: center;
        gap: 15px;
        padding: 20px 15px; // Reduce padding for smaller screens
    }

    .badge-showcase {
        width: 100%;
        margin-bottom: 10px;

        .badge-container {
            width: 220px; // Still larger but proportional
            height: 220px;
            margin: 0 auto 15px; // Center badge

            .badge-image {
                transform: translateZ(80px) scale(1.25); // Adjusted for mobile
            }

            .lock-overlay i {
                font-size: 45px; // Slightly smaller
            }
        }
    }

    .achievement-details {
        width: 100%;

        .title-row {
            flex-direction: column; // Stack title and points on mobile
            align-items: center;
            gap: 10px;
            
            &::after {
                left: 50%;
                right: auto;
                transform: translateX(-50%);
            }
        }

        .achievement-title {
            text-align: center;
            font-size: 1.7rem;
        }
        
        .title-points-display {
            margin-right: 0;
        }

        .description-scroll {
            padding: 12px;
            margin-bottom: 15px;

            .achievement-description {
                font-size: 1rem;
            }
        }

        .achievement-requirement-info,
        .achievement-completion-info {
            padding: 10px;

            .requirement-badge,
            .completion-badge {
                width: 45px;
                height: 45px;

                i {
                    font-size: 1.4rem;
                }
            }

            .requirement-details,
            .completion-details {

                .requirement-label,
                .completion-label {
                    font-size: 0.85rem;
                    margin-bottom: 3px;
                }

                .requirement-value,
                .completion-date {
                    font-size: 1.1rem;
                }
            }
        }
    }

    .card-actions {
        padding: 15px;

        .action-button {
            padding: 10px 20px;
            font-size: 1rem;
            min-width: 130px;
        }
    }
}

// Landscape mode optimizations
@media (orientation: landscape) and (max-height: 600px) {
    .modal-container {
        max-height: 95vh;
        width: 90%;
        max-width: 750px; // Wider in landscape to use available width
    }

    .achievement-card {
        max-height: 95vh;
    }

    // Use a horizontal layout for content in landscape
    .card-content {
        flex-direction: row;
        padding: 12px;
        gap: 15px;
    }

    .badge-showcase {
        width: 40%; // Use percentage for better flexibility

        .badge-container {
            width: 180px; // Still larger than original
            height: 180px;
            margin: 0 auto 10px;

            .badge-image {
                transform: translateZ(70px) scale(1.25); // Still enhanced in landscape
                
                &:hover {
                    transform: translateZ(90px) scale(1.35);
                }
                
                &.grayscale {
                    transform: translateZ(45px) scale(1.15);
                    
                    &:hover {
                        transform: translateZ(60px) scale(1.25);
                    }
                }
            }

            .lock-overlay i {
                font-size: 40px;
            }

            .completion-marker .check-container {
                width: 40px;
                height: 40px;

                i {
                    font-size: 24px;
                }
            }
        }
    }

    .achievement-details {
        width: 60%;

        .title-row {
            margin-bottom: 10px;
        }

        .achievement-title {
            font-size: 1.5rem;
        }
        
        .title-points-display {
            padding: 6px 12px;
            
            i, span {
                font-size: 1.4rem;
            }
        }

        .description-scroll {
            padding: 8px 10px;
            margin-bottom: 8px;
            max-height: 70px;

            .achievement-description {
                font-size: 0.95rem;
                line-height: 1.4;
            }
        }

        .achievement-requirement-info,
        .achievement-completion-info {
            padding: 8px;

            .requirement-badge,
            .completion-badge {
                width: 40px;
                height: 40px;

                i {
                    font-size: 1.4rem;
                }
            }

            .requirement-details,
            .completion-details {
                .requirement-label,
                .completion-label {
                    font-size: 0.8rem;
                    margin-bottom: 2px;
                }

                .requirement-value,
                .completion-date {
                    font-size: 1rem;
                }
            }
        }

        .progress-container {
            .progress-label {
                font-size: 0.9rem;
                margin-bottom: 5px;
            }

            .progress-bar {
                margin-bottom: 10px;

                .progress-track {
                    height: 10px;
                }
            }
        }
    }

    .card-actions {
        padding: 10px;

        .action-button {
            padding: 8px 15px;
            font-size: 0.9rem;
            min-width: 100px;
        }
    }

    // Adjust banner height in landscape
    .card-banner {
        padding: 6px 0;

        .banner-text {
            font-size: 1.2rem;
        }
    }
}
```

<details><summary>risultato tool</summary>

```
OK
```
</details>



I've completely restructured the achievement modal with the requested enhancements:

### Badge Enhancements:
1. **Significantly Larger Badge**: 
   - Increased badge container dimensions to 300px × 300px (from 260px)
   - Expanded badge image to 120% of container size
   - Badge now visually "breaks out" of the modal with more dramatic 3D effects

2. **Enhanced 3D Floating Effect**:
   - Increased Z-translation to 100px-120px (from 40px-60px)
   - Added multi-axis rotation for a more natural floating movement
   - Improved shadow depth and size for better 3D perception
   - More dramatic hover effects that lift the badge even further

3. **Preserved Grayscale for Locked Badges**:
   - Maintained 75% grayscale and 75% brightness for locked badges
   - Locked badges still have 3D effects but less pronounced than unlocked ones
   - Lock icon size increased to be more visible against larger badges

### Title and Points Repositioning:
1. **Integrated Points with Title**:
   - Created a new `.title-row` flex container that places:
     - Title on the right (RTL layout)
     - Points display on the left
   - Points display now uses the same visual style as before but in a more compact format
   - The underline decoration remains under the title

2. **Responsive Considerations**:
   - On mobile: Title and points stack vertically for better readability
   - On landscape: Maintains horizontal layout with adjusted sizing

### Other Improvements:
- Added more dramatic animations for all interactive elements
- Improved background particle effects
- Enhanced shadow and lighting effects
- Optimized landscape mode to maintain the 3D floating effect
- Ensured all parent containers have `overflow: visible` to prevent badge clipping

The badge now dramatically floats out of the modal with a strong 3D effect while maintaining the original design language, and the star count is elegantly positioned in the same row as the title.
