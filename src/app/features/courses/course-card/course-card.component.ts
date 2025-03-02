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

  progressValue: number = 0;
  private oldProgress: number = 0;
  private oldCourseId: string = '';
  private oldCompletedState: boolean = false;

  constructor(private cdr: ChangeDetectorRef) { }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['course'] && this.course) {
      this.progressValue = this.course.progress || 0;
      this.oldProgress = this.progressValue;
      this.oldCourseId = this.course.id || '';
      this.oldCompletedState = this.course.isCompleted || false;
    }
  }

  ngDoCheck(): void {
    if (this.course && this.course.id === this.oldCourseId) {
      const currentProgress = this.course.progress || 0;
      const isCompleted = this.course.isCompleted || false;

      if (currentProgress !== this.oldProgress || isCompleted !== this.oldCompletedState) {
        console.debug(`[CourseCard:${this.course.id}] State changed - progress: ${this.oldProgress} → ${currentProgress}, completed: ${this.oldCompletedState} → ${isCompleted}`);
        this.progressValue = currentProgress;
        this.oldProgress = currentProgress;
        this.oldCompletedState = isCompleted;
        this.cdr.detectChanges(); // Force immediate update
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