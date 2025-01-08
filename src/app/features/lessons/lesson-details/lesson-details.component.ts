// lesson-details.component.ts
import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { LessonsService } from '../lessons.service';
import { Lesson, LessonType } from '../../../shared/interfaces/lesson';
import { Subscription } from 'rxjs';
import { InteractiveQuestion } from '../interactive-lesson/interactive-lesson.types';

@Component({
  selector: 'app-lesson-details',
  standalone: false,
  templateUrl: './lesson-details.component.html',
  styleUrls: ['./lesson-details.component.scss']
})
export class LessonDetailsComponent implements OnInit, OnDestroy {
  lesson: Lesson | undefined;
  practiceQuestions: InteractiveQuestion[] = [];
  currentProgress: number = 0;
  private subscriptions: Subscription[] = [];

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private lessonsService: LessonsService
  ) { }

  ngOnInit(): void {
    const courseId = this.route.snapshot.paramMap.get('courseId')!;
    const unitId = this.route.snapshot.paramMap.get('unitId')!;
    const lessonId = this.route.snapshot.paramMap.get('lessonId')!;

    const lessonSub = this.lessonsService.getLessonById(courseId, unitId, lessonId)
      .subscribe(lesson => {
        this.lesson = lesson;
      });

    this.subscriptions.push(lessonSub);
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  get lessonTypeText(): string {
    switch (this.lesson?.type) {
      case 'video':
        return 'درس مرئي';
      case 'practice':
        return 'تدريب عملي';
      case 'listen':
        return 'درس صوتي';
      case 'read':
        return 'درس قراءة';
      case 'test':
        return 'اختبار';
      default:
        return 'درس';
    }
  }

  getLessonTypeIcon(): string {
    switch (this.lesson?.type) {
      case 'video':
        return 'fa-play-circle';
      case 'practice':
        return 'fa-pen-to-square';
      case 'listen':
        return 'fa-headphones';
      case 'read':
        return 'fa-book';
      case 'test':
        return 'fa-check-circle';
      default:
        return 'fa-book-open';
    }
  }

  updateProgress(progress: number): void {
    this.currentProgress = progress;
    if (progress === 100) {
      this.markAsCompleted();
    }
  }

  markAsCompleted(): void {
    if (this.lesson && !this.lesson.isCompleted) {
      const courseId = this.route.snapshot.paramMap.get('courseId')!;
      const unitId = this.route.snapshot.paramMap.get('unitId')!;

      const completeSub = this.lessonsService.markLessonAsCompleted(courseId, unitId, this.lesson.id)
        .subscribe(() => {
          if (this.lesson) {
            this.lesson.isCompleted = true;
          }
        });

      this.subscriptions.push(completeSub);
    }
  }

  // New method to handle answer tracking
  handleAnswer(questionId: string, answer: string | boolean): void {
    console.log(`Question ${questionId} answered: ${answer}`);
    // Implement any additional logic for tracking answers
  }

  onNavigateBack(): void {
    this.router.navigate(['../'], { relativeTo: this.route });
  }
}