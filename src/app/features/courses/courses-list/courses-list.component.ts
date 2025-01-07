import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';
import { Observable } from 'rxjs';
import Swiper from 'swiper';
import { Navigation as SwiperNavigation, Pagination as SwiperPagination } from 'swiper/modules';
import type { SwiperOptions } from 'swiper/types';
import { CoursesService } from '../../../core/services/courses.service';
import { Course } from '../../../shared/interfaces/course';
import { Router } from '@angular/router';

@Component({
  selector: 'app-courses-list',
  standalone: false,

  templateUrl: './courses-list.component.html',
  styleUrls: ['./courses-list.component.scss']
})
export class CoursesListComponent implements OnInit, AfterViewInit {
  @ViewChild('swiperContainer') swiperContainer!: ElementRef;
  courses$: Observable<Course[]>;
  swiper?: Swiper;

  constructor(private coursesService: CoursesService,
    private router: Router
  ) {
    this.courses$ = this.coursesService.getCourses();
  }

  ngOnInit(): void { }

  ngAfterViewInit(): void {
    this.initSwiper();
  }

  private initSwiper(): void {
    const swiperOptions: SwiperOptions = {
      modules: [SwiperNavigation, SwiperPagination],
      slidesPerView: 'auto',
      spaceBetween: 20,
      direction: 'horizontal',
      centeredSlides: false,
      navigation: {
        enabled: true
      },
      pagination: {
        el: '.swiper-pagination',
        clickable: true,
        enabled: true
      },
      breakpoints: {
        320: {
          slidesPerView: 1.2,
          spaceBetween: 10
        },
        480: {
          slidesPerView: 1.5,
          spaceBetween: 15
        },
        768: {
          slidesPerView: 2.2,
          spaceBetween: 20
        },
        1024: {
          slidesPerView: 3.2,
          spaceBetween: 20
        }
      }
    };

    this.swiper = new Swiper(this.swiperContainer.nativeElement, swiperOptions);
  }

  onCourseSelected(course: Course): void {
    console.log('Navigating to lessons for course:', course.id);
    this.router.navigate(['/units', course.id])
      .then(success => {
        console.log('Navigation successful:', success);
      })
      .catch(err => {
        console.error('Navigation error:', err);
      });
  }
}