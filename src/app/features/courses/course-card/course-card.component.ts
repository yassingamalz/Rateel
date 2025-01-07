// course-card.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { trigger, transition, style, animate } from '@angular/animations';
import { Course } from '../../../shared/interfaces/course';

@Component({
  selector: 'app-course-card',
  standalone: false,
  templateUrl: './course-card.component.html',
  styleUrls: ['./course-card.component.scss'],
  animations: [
    trigger('cardAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateY(20px)' }),
        animate('300ms ease-out', style({ opacity: 1, transform: 'translateY(0)' }))
      ])
    ])
  ]
})
export class CourseCardComponent {
  @Input() course!: Course;
  @Output() courseSelected = new EventEmitter<Course>();

  onCardClick(): void {
    if (!this.course.isLocked) {
      this.courseSelected.emit(this.course);
    }
  }

  getBackgroundStyle(): string {
    if (this.course.imageSrc) {
      return `url(${this.course.imageSrc})`;
    }

    return 'none';
  }
}
