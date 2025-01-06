// course-card.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { trigger, transition, style, animate } from '@angular/animations';
import { Course } from '../../../shared/interfaces/course';

@Component({
  selector: 'app-course-card',
  standalone:false,
  templateUrl: './course-card.component.html',
  styleUrls: ['./course-card.component.scss'],
  animations: [
    trigger('fadeInOut', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('300ms ease-in', style({ opacity: 1 }))
      ])
    ])
  ]
})
export class CourseCardComponent {
  @Input() course!: Course;
  @Output() courseClick = new EventEmitter<Course>();

  onCardClick(): void {
    if (!this.course.isLocked) {
      this.courseClick.emit(this.course);
    }
  }
}