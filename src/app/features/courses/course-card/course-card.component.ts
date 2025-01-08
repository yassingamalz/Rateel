// course-card.component.ts
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { Course } from '../../../shared/interfaces/course';

@Component({
  selector: 'app-course-card',
  standalone: false,
  templateUrl: './course-card.component.html',
  styleUrls: ['./course-card.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush // Add for better performance
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
    return this.course.imageSrc ? `url(${this.course.imageSrc})` : 'none';
  }
}