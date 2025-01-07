// courses-list.component.ts
import { Component, OnInit, ViewChild, ElementRef, AfterViewInit } from '@angular/core';
import { Router } from '@angular/router';
import { Observable } from 'rxjs';
import { Course } from '../../../shared/interfaces/course';
import { CoursesService } from '../../../core/services/courses.service';

@Component({
  selector: 'app-courses-list',
  standalone: false,
  templateUrl: './courses-list.component.html',
  styleUrls: ['./courses-list.component.scss']
})
export class CoursesListComponent implements OnInit, AfterViewInit {
  @ViewChild('coursesContainer') coursesContainer!: ElementRef;
  courses$: Observable<Course[]>;
  currentCourseIndex = 0;
  isDragging = false;
  startX = 0;
  scrollLeft = 0;

  constructor(
    private coursesService: CoursesService,
    private router: Router
  ) {
    this.courses$ = this.coursesService.getCourses();
  }

  ngOnInit(): void { }

  ngAfterViewInit(): void {
    // Initialize any scroll behaviors if needed
  }


  isCourseCompleted(index: number): boolean {
    return index <= this.currentCourseIndex;
  }

  onCourseSelected(course: Course): void {
    console.log('Navigating to units for course:', course.id);
    this.router.navigate(['/courses', course.id, 'units'])
      .then(success => {
        console.log('Navigation successful:', success);
      })
      .catch(err => {
        console.error('Navigation error:', err);
      });
  }

  // Mouse event handlers for smooth dragging
  onMouseDown(event: MouseEvent): void {
    this.isDragging = true;
    this.startX = event.pageX - this.coursesContainer.nativeElement.offsetLeft;
    this.scrollLeft = this.coursesContainer.nativeElement.scrollLeft;
  }

  onMouseMove(event: MouseEvent): void {
    if (!this.isDragging) return;
    event.preventDefault();
    const x = event.pageX - this.coursesContainer.nativeElement.offsetLeft;
    const walk = (x - this.startX) * 2;
    this.coursesContainer.nativeElement.scrollLeft = this.scrollLeft - walk;
  }

  onMouseUp(): void {
    this.isDragging = false;
  }

  onMouseLeave(): void {
    this.isDragging = false;
  }
}