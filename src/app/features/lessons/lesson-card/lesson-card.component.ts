// src/app/features/units/unit-details/lesson-card/lesson-card.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { trigger, transition, style, animate } from '@angular/animations';
import { Lesson } from '../../../shared/interfaces/lesson';

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
  ]
})
export class LessonCardComponent {
  @Input() lesson!: Lesson;
  @Input() isActive = false;
  @Output() lessonClick = new EventEmitter<Lesson>();

  onCardClick(): void {
    if (!this.lesson.isLocked) {
      this.lessonClick.emit(this.lesson);
    }
  }

  getLessonIcon(): string {
    switch (this.lesson.type) {
      case 'video':
        return 'fa-play-circle';
      case 'practice':
        return 'fa-pencil-alt';
      case 'test':
        return 'fa-check-circle';
      default:
        return 'fa-book';
    }
  }
}

