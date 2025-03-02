// course-card.component.ts
import { Component, Input, Output, EventEmitter, OnChanges, SimpleChanges, ChangeDetectionStrategy } from '@angular/core';
import { Course } from '../../../shared/interfaces/course';

@Component({
  selector: 'app-course-card',
  standalone: false,
  templateUrl: './course-card.component.html',
  styleUrls: ['./course-card.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CourseCardComponent implements OnChanges {
  @Input() course!: Course;
  @Output() courseSelected = new EventEmitter<Course>();
  
  // Track progress for change detection
  progressValue: number = 0;
  
  ngOnChanges(changes: SimpleChanges): void {
    if (changes['course']) {
      // Update local progress value to help change detection
      this.progressValue = this.course?.progress || 0;
    }
  }

  onCardClick(): void {
    if (!this.course.isLocked) {
      this.courseSelected.emit(this.course);
    }
  }

  getBackgroundStyle(): string {
    return this.course.imageSrc ? `url(${this.course.imageSrc})` : 'none';
  }
}