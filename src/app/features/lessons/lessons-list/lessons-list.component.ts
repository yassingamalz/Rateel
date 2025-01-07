// src/app/features/lessons/lessons-list/lessons-list.component.ts
import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Observable, BehaviorSubject } from 'rxjs';
import { tap } from 'rxjs/operators';
import { trigger, transition, style, animate } from '@angular/animations';
import { LessonsService } from '../lessons.service';
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
    public route: ActivatedRoute,
    public router: Router
  ) { }

  ngOnInit(): void {
    // Get parent route parameters
    this.route.parent?.parent?.paramMap.subscribe(params => {
      this.courseId = params.get('courseId')!;
      this.unitId = params.get('unitId')!;

      console.log('CourseId:', this.courseId);
      console.log('UnitId:', this.unitId);

      this.lessonsService.setCurrentUnit(this.unitId);
      this.lessons$ = this.lessonsService.getLessonsByUnitId(this.courseId, this.unitId)
        .pipe(
          tap(lessons => {
            console.log('Fetched lessons:', lessons);
          })
        );
    });
  }

  onLessonSelected(lesson: Lesson): void {
    if (!lesson.isLocked) {
      this.router.navigate(['lesson', lesson.id], {
        relativeTo: this.route
      });
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