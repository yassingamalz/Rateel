import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy, OnInit } from '@angular/core';
import { Achievement } from '../../../services/gamification.service';
import { trigger, transition, style, animate } from '@angular/animations';

interface Particle {
  tx: string;
  ty: string;
  size: string;
  color: string;
  delay: string;
}

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
    ])
  ]
})
export class AchievementDetailsModalComponent implements OnInit {
  @Input() isOpen: boolean = false;
  @Input() achievement: Achievement | null = null;

  @Output() close = new EventEmitter<void>();
  @Output() share = new EventEmitter<Achievement>();

  // Particles for background animation
  particles: Particle[] = [];

  ngOnInit(): void {
    // Generate particles for background animation
    this.generateParticles();
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
   * Get badge type label in Arabic
   */
  getBadgeTypeLabel(type: string | undefined): string {
    switch (type) {
      case 'bronze': return 'برونزي';
      case 'silver': return 'فضي';
      case 'gold': return 'ذهبي';
      case 'platinum': return 'بلاتيني';
      case 'diamond': return 'ماسي';
      default: return 'برونزي';
    }
  }

  /**
   * Get requirement icon based on achievement type
   */
  getRequirementIcon(achievement: Achievement): string {
    switch (achievement.requirement.type) {
      case 'lessons_completed': return 'fa-book';
      case 'score_reached': return 'fa-chart-line';
      case 'streak': return 'fa-fire';
      case 'perfect_score': return 'fa-award';
      default: return 'fa-trophy';
    }
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
      default:
        return `إكمال المهمة المطلوبة`;
    }
  }

  /**
   * Close modal handler
   */
  onClose(): void {
    this.close.emit();
  }

  /**
   * Share achievement handler
   */
  onShare(): void {
    if (this.achievement) {
      this.share.emit(this.achievement);
    }
  }

  /**
   * Generate random particles for background effects
   */
  private generateParticles(): void {
    // Create particles with random properties
    this.particles = Array(20).fill(0).map(() => {
      // Random angle and distance for particle movement
      const angle = Math.random() * Math.PI * 2;
      const distance = 100 + Math.random() * 200;

      // Calculate x and y movement
      const tx = Math.cos(angle) * distance;
      const ty = Math.sin(angle) * distance;

      // Random size between 5px and 20px
      const size = (5 + Math.random() * 15) + 'px';

      // Random delay for staggered animation
      const delay = (Math.random() * 0.5) + 's';

      // Colors based on badge types - gold, silver, bronze, etc.
      const colors = [
        '#DAA520', // Gold
        '#C0C0C0', // Silver
        '#CD7F32', // Bronze
        '#E5E4E2', // Platinum
        '#B9F2FF'  // Diamond
      ];

      // Select random color
      const color = colors[Math.floor(Math.random() * colors.length)];

      return {
        tx: `${tx}px`,
        ty: `${ty}px`,
        size,
        color,
        delay
      };
    });
  }
}