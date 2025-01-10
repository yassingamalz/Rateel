// lesson-card.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { trigger, transition, style, animate } from '@angular/animations';
import { Lesson } from '../../../shared/interfaces/lesson';
import { BorderFillDirective } from '../../../shared/directives/border-fill.directive';

@Component({
  selector: 'app-lesson-card',
  standalone: false,
  templateUrl: './lesson-card.component.html',
  styleUrls: ['./lesson-card.component.scss'],
  animations: [
    trigger('cardAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.95)' }),
        animate('200ms ease-out', style({ opacity: 1, transform: 'scale(1)' }))
      ])
    ])
  ],
})
export class LessonCardComponent {
  @Input() lesson!: Lesson;
  @Input() isActive = false;
  @Input() isCompleting = false;
  @Output() lessonClick = new EventEmitter<Lesson>();

  getBackgroundClass(): string {
    if (this.lesson.isLocked) return 'lesson-card--locked';
    if (this.lesson.isCompleted) return 'lesson-card--completed';
    if (this.isActive) return 'lesson-card--active';
    return '';
  }

  getProgressIndicator(): string {
    if (this.lesson.isCompleted) return '✓';
    return `${this.lesson.stepNumber}/${this.lesson.totalSteps}`;
  }

  onCardClick(): void {
    if (!this.lesson.isLocked) {
      this.lessonClick.emit(this.lesson);
    }
  }
}