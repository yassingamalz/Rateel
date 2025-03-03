//src\app\features\courses\course-card\course-card.component.ts
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
  private oldProgress: number = -1; // Changed to -1 to ensure first update
  private oldCourseId: string = '';
  private oldCompletedState: boolean = false;
  private oldLockedState: boolean = false;
  private changeCount = 0;

  constructor(private cdr: ChangeDetectorRef) { }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['course'] && this.course) {
      // Always update on direct input changes
      this.progressValue = this.course.progress || 0;
      this.oldProgress = this.progressValue;
      this.oldCourseId = this.course.id || '';
      this.oldCompletedState = this.course.isCompleted || false;
      this.oldLockedState = this.course.isLocked || false;
      
      // Log for debugging
      console.log(`[CourseCard:${this.course.id}] Input changed: progress=${this.progressValue}, completed=${this.course.isCompleted}, locked=${this.course.isLocked}`);
    }
  }

  ngDoCheck(): void {
    if (this.course && this.course.id === this.oldCourseId) {
      const currentProgress = this.course.progress || 0;
      const isCompleted = this.course.isCompleted || false;
      const isLocked = this.course.isLocked || false;

      // Check for any state changes that would require UI updates
      if (currentProgress !== this.oldProgress || 
          isCompleted !== this.oldCompletedState ||
          isLocked !== this.oldLockedState) {
        
        this.changeCount++;
        console.log(`[CourseCard:${this.course.id}] State changed (${this.changeCount}) - progress: ${this.oldProgress} → ${currentProgress}, completed: ${this.oldCompletedState} → ${isCompleted}, locked: ${this.oldLockedState} → ${isLocked}`);
        
        // Update tracking values
        this.progressValue = currentProgress;
        this.oldProgress = currentProgress;
        this.oldCompletedState = isCompleted;
        this.oldLockedState = isLocked;
        
        // Force immediate UI update
        this.cdr.detectChanges();
      }
    } else if (this.course && this.course.id !== this.oldCourseId) {
      // Course reference changed completely
      console.log(`[CourseCard] Course changed from ${this.oldCourseId} to ${this.course.id}`);
      this.progressValue = this.course.progress || 0;
      this.oldProgress = this.progressValue;
      this.oldCourseId = this.course.id;
      this.oldCompletedState = this.course.isCompleted || false;
      this.oldLockedState = this.course.isLocked || false;
      
      // Force update
      this.cdr.detectChanges();
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