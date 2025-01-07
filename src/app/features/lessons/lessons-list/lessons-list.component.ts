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
  startX = 0;
  scrollLeft = 0;

  constructor(
    private lessonsService: LessonsService,
    private unitsService: UnitsService,
    public route: ActivatedRoute,
    public router: Router
  ) { }

  ngOnInit(): void {
    // Access the route parameters using the parent routes
    this.route.params.subscribe(params => {
      console.log('Direct route params:', params);
    });

    this.route.parent?.params.subscribe(params => {
      console.log('Parent route params:', params);
    });

    combineLatest([
      this.route.parent?.parent?.params || this.route.params,
      this.route.parent?.params || this.route.params
    ]).pipe(
      tap(([parentParams, currentParams]) => {
        console.log('Combined route params:', { parentParams, currentParams });
      }),
      map(([parentParams, currentParams]) => {
        return {
          courseId: parentParams['courseId'] || currentParams['courseId'],
          unitId: parentParams['unitId'] || currentParams['unitId']
        };
      }),
      filter(params => !!params.courseId && !!params.unitId)
    ).subscribe(({ courseId, unitId }) => {
      this.courseId = courseId;
      this.unitId = unitId;
      console.log('Loading lessons for:', { courseId, unitId });

      // Try getting lessons from UnitsService first
      this.unitsService.getLessonsByUnitId(courseId, unitId).pipe(
        tap(lessonsFromUnits => {
          console.log('Lessons from UnitsService:', lessonsFromUnits);
          if (lessonsFromUnits.length === 0) {
            // If no lessons from UnitsService, try LessonsService
            this.lessonsService.getLessonsByUnitId(courseId, unitId).subscribe(lessonsFromLessons => {
              console.log('Lessons from LessonsService:', lessonsFromLessons);
              this.lessons$ = of(lessonsFromLessons);
            });
          } else {
            this.lessons$ = of(lessonsFromUnits);
          }
        })
      ).subscribe();
    });
  }

  onLessonSelected(lesson: Lesson): void {
    if (!lesson.isLocked) {
      console.log('Navigating to lesson:', {
        courseId: this.courseId,
        unitId: this.unitId,
        lessonId: lesson.id
      });

      this.router.navigate(['/courses', this.courseId, 'units', this.unitId, 'lessons', lesson.id])
        .then(success => console.log('Lesson navigation success:', success))
        .catch(error => console.error('Lesson navigation error:', error));
    }
  }


  // Mouse event handlers for dragging
  onMouseDown(event: MouseEvent): void {
    this.isDragging = true;
    this.startX = event.pageX - this.lessonsContainer.nativeElement.offsetLeft;
    this.scrollLeft = this.lessonsContainer.nativeElement.scrollLeft;
  }

  onMouseMove(event: MouseEvent): void {
    if (!this.isDragging) return;
    event.preventDefault();
    const x = event.pageX - this.lessonsContainer.nativeElement.offsetLeft;
    const walk = (x - this.startX) * 2;
    this.lessonsContainer.nativeElement.scrollLeft = this.scrollLeft - walk;
  }

  onMouseUp(): void {
    this.isDragging = false;
  }

  onMouseLeave(): void {
    this.isDragging = false;
  }

  // Touch event handlers for mobile
  onTouchStart(event: TouchEvent): void {
    this.isDragging = true;
    this.startX = event.touches[0].pageX - this.lessonsContainer.nativeElement.offsetLeft;
    this.scrollLeft = this.lessonsContainer.nativeElement.scrollLeft;
  }

  onTouchMove(event: TouchEvent): void {
    if (!this.isDragging) return;
    const x = event.touches[0].pageX - this.lessonsContainer.nativeElement.offsetLeft;
    const walk = (x - this.startX) * 2;
    this.lessonsContainer.nativeElement.scrollLeft = this.scrollLeft - walk;
  }

  onTouchEnd(): void {
    this.isDragging = false;
  }
}