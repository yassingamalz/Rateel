// course-card.component.ts
import { Component, Input, Output, EventEmitter, OnChanges, SimpleChanges, ChangeDetectionStrategy, ChangeDetectorRef, DoCheck } from '@angular/core';
import { Course } from '../../../shared/interfaces/course';

@Component({
  selector: 'app-course-card',
  standalone: false,
  templateUrl: './course-card.component.html',
  styleUrls: ['./course-card.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CourseCardComponent implements OnChanges, DoCheck {
  @Input() course!: Course;
  @Output() courseSelected = new EventEmitter<Course>();
  
  // Track progress for change detection
  progressValue: number = 0;
  private oldProgress: number = 0;
  private oldCourseId: string = '';
  
  constructor(private cdr: ChangeDetectorRef) {}
  
  ngOnChanges(changes: SimpleChanges): void {
    if (changes['course']) {
      // Update local progress value to help change detection
      this.progressValue = this.course?.progress || 0;
      this.oldProgress = this.progressValue;
      this.oldCourseId = this.course?.id || '';
    }
  }
  
  ngDoCheck(): void {
    // Detect object property changes even without reference changes
    if (this.course && this.course.id === this.oldCourseId) {
      const currentProgress = this.course.progress || 0;
      if (currentProgress !== this.oldProgress) {
        this.progressValue = currentProgress;
        this.oldProgress = currentProgress;
        this.cdr.markForCheck();
      }
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