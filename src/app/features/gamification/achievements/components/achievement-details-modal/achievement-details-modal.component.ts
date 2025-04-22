import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { Achievement } from '../../../services/gamification.service';

@Component({
  selector: 'app-achievement-details-modal',
  standalone: false,
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