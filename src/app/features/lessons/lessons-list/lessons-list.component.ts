// src/app/features/lessons/lessons-list/lessons-list.component.ts
import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Observable, BehaviorSubject, combineLatest, of } from 'rxjs';
import { tap, map, filter } from 'rxjs/operators';
import { trigger, transition, style, animate } from '@angular/animations';
import { LessonsService } from '../lessons.service';
import { UnitsService } from '../../units/units.service';
import { Lesson } from '../../../shared/interfaces/lesson';

@Component({
  selector: 'app-lessons-list',
  standalone: false,
  templateUrl: './lessons-list.component.html',
  styleUrls: ['./lessons-list.component.scss'],
  animations: [
    trigger('slideInOut', [
      transition(':enter', [
        style({ transform: 'translateX(100%)' }),
        animate('300ms ease-out', style({ transform: 'translateX(0)' }))
      ]),
      transition(':leave', [
        animate('300ms ease-out', style({ transform: 'translateX(-100%)' }))
      ])
    ])
  ]
})
export class LessonsListComponent implements OnInit {
  @ViewChild('lessonsContainer') lessonsContainer!: ElementRef;

  lessons$!: Observable<Lesson[]>;
  courseId!: string;
  unitId!: string;
  currentLessonIndex = new BehaviorSubject<number>(0);
  isDragging = false;
  dragStarted = false;
  startX = 0;
  scrollLeft = 0;
  dragThreshold = 5;
  dragStartTime = Date.now();
  mouseInitialX = 0;
  dragSpeedMultiplier = 2.5;
  inertiaMultiplier = 200;
  activeLessonId: string | null = null;

  constructor(
    private lessonsService: LessonsService,
    private unitsService: UnitsService,
    public route: ActivatedRoute,
    public router: Router
  ) { }

  ngOnInit(): void {
    this.courseId = this.route.snapshot.paramMap.get('courseId')!;
    this.unitId = this.route.snapshot.paramMap.get('unitId')!;
    this.lessonsService.setCurrentUnit(this.unitId);

    this.lessons$ = this.lessonsService.getLessonsByUnitId(this.courseId, this.unitId).pipe(
      tap(lessons => {
        const lessonId = this.route.snapshot.paramMap.get('lessonId');

        if (lessonId) {
          this.activeLessonId = lessonId;
        } else {
          // Find first unlocked incomplete lesson
          const nextLesson = lessons.find(l => !l.isCompleted && !l.isLocked);
          if (nextLesson) {
            this.activeLessonId = nextLesson.id;
          } else {
            // If all complete, show first lesson
            this.activeLessonId = lessons[0]?.id;
          }
        }
      })
    );
  }

  onLessonSelected(lesson: Lesson): void {
    if (!lesson.isLocked) {
      this.activeLessonId = lesson.id;
      this.router.navigate(['/courses', this.courseId, 'units', this.unitId, 'lessons', lesson.id]);
    }
  }

  onMouseDown(event: MouseEvent): void {
    if ((event.target as HTMLElement).closest('.lesson-item')) {
      this.dragStarted = true;
      this.mouseInitialX = event.pageX;
      this.startX = event.pageX;
      this.scrollLeft = this.lessonsContainer.nativeElement.scrollLeft;
      this.dragStartTime = Date.now();
    }
  }

  onMouseMove(event: MouseEvent): void {
    if (!this.dragStarted) return;

    const dragDistance = Math.abs(event.pageX - this.mouseInitialX);
    if (dragDistance > this.dragThreshold) {
      this.isDragging = true;
    }

    const walk = (event.pageX - this.startX) * this.dragSpeedMultiplier;
    this.lessonsContainer.nativeElement.scrollLeft = this.scrollLeft - walk;
  }

  onMouseUp(event: MouseEvent): void {
    if (!this.dragStarted) return;

    const dragDistance = Math.abs(event.pageX - this.mouseInitialX);
    const dragDuration = Date.now() - this.dragStartTime;

    if (!this.isDragging && dragDistance < this.dragThreshold && dragDuration < 200) {
      const lessonElement = (event.target as HTMLElement).closest('[data-lesson-id]');
      if (lessonElement) {
        const lessonId = lessonElement.getAttribute('data-lesson-id');
        const lessons = (this.lessons$ as any).value;
        const lesson = lessons?.find((l: Lesson) => l.id === lessonId);
        if (lesson && !lesson.isLocked) {
          this.onLessonSelected(lesson);
        }
      }
    } else if (dragDistance > this.dragThreshold) {
      const speed = dragDistance / dragDuration;
      const inertiaDistance = speed * this.inertiaMultiplier;

      this.lessonsContainer.nativeElement.scrollBy({
        left: -inertiaDistance,
        behavior: 'smooth'
      });
    }

    this.isDragging = false;
    this.dragStarted = false;
  }

  onMouseLeave(): void {
    if (this.dragStarted) {
      this.isDragging = false;
      this.dragStarted = false;
    }
  }

  onTouchStart(event: TouchEvent): void {
    if ((event.target as HTMLElement).closest('.lesson-item')) {
      this.dragStarted = true;
      this.mouseInitialX = event.touches[0].pageX;
      this.startX = event.touches[0].pageX;
      this.scrollLeft = this.lessonsContainer.nativeElement.scrollLeft;
      this.dragStartTime = Date.now();
    }
  }

  onTouchMove(event: TouchEvent): void {
    if (!this.dragStarted) return;

    const dragDistance = Math.abs(event.touches[0].pageX - this.mouseInitialX);
    if (dragDistance > this.dragThreshold) {
      this.isDragging = true;
    }

    const walk = (event.touches[0].pageX - this.startX) * this.dragSpeedMultiplier;
    this.lessonsContainer.nativeElement.scrollLeft = this.scrollLeft - walk;
  }

  onTouchEnd(event: TouchEvent): void {
    if (!this.dragStarted) return;

    const touch = event.changedTouches[0];
    const dragDistance = Math.abs(touch.pageX - this.mouseInitialX);
    const dragDuration = Date.now() - this.dragStartTime;

    if (!this.isDragging && dragDistance < this.dragThreshold && dragDuration < 200) {
      const lessonElement = (event.target as HTMLElement).closest('[data-lesson-id]');
      if (lessonElement) {
        const lessonId = lessonElement.getAttribute('data-lesson-id');
        const lessons = (this.lessons$ as any).value;
        const lesson = lessons?.find((l: Lesson) => l.id === lessonId);
        if (lesson && !lesson.isLocked) {
          this.onLessonSelected(lesson);
        }
      }
    } else if (dragDistance > this.dragThreshold) {
      const speed = dragDistance / dragDuration;
      const inertiaDistance = speed * this.inertiaMultiplier;

      this.lessonsContainer.nativeElement.scrollBy({
        left: -inertiaDistance,
        behavior: 'smooth'
      });
    }

    this.isDragging = false;
    this.dragStarted = false;
  }
}