// src/app/features/lessons/lesson-card/lesson-card.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { trigger, transition, style, animate } from '@angular/animations';
import { Lesson } from '../../../shared/interfaces/lesson';

@Component({
  selector: 'app-lesson-card',
  standalone:false,

  templateUrl: './lesson-card.component.html',
  styleUrls: ['./lesson-card.component.scss'],
  animations: [
    trigger('cardAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateX(20px)' }),
        animate('300ms ease-out', style({ opacity: 1, transform: 'translateX(0)' }))
      ])
    ])
  ]
})
export class LessonCardComponent {
  @Input() lesson!: Lesson;
  @Output() lessonSelected = new EventEmitter<Lesson>();

  onCardClick(): void {
    if (!this.lesson.isLocked) {
      this.lessonSelected.emit(this.lesson);
    }
  }
}


