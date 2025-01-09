// main-layout.component.ts
import {
  Component, OnInit, ViewChild, ElementRef, AfterViewInit, ChangeDetectionStrategy,
  ChangeDetectorRef, OnDestroy
} from '@angular/core';
import { Router, NavigationEnd, ActivatedRoute, NavigationStart, Event } from '@angular/router';
import { BehaviorSubject, Observable } from 'rxjs';
import { filter } from 'rxjs/operators';

@Component({
  selector: 'app-main-layout',
  standalone: false,
  templateUrl: './main-layout.component.html',
  styleUrls: ['./main-layout.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MainLayoutComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('mainContainer') mainContainer!: ElementRef;

  private sidebarVisibility = new BehaviorSubject<boolean>(true);
  shouldShowSidebar$ = this.sidebarVisibility.asObservable();

  isSidebarCollapsed = true;
  isMobile = window.innerWidth <= 768;
  private resizeHandler: () => void;

  constructor(
    private router: Router,
    private activatedRoute: ActivatedRoute,
    private cdr: ChangeDetectorRef
  ) {
    this.resizeHandler = this.onWindowResize.bind(this);
    this.checkMobileView();

    // Subscribe to ALL router events
    this.router.events.subscribe((event: Event) => {
      if (event instanceof NavigationStart) {
        // Get the URL directly
        const url = event.url;

        // Check if we're in a lesson view (looking for /lessons/ followed by anything)
        const isLessonView = /\/lessons\/[^\/]+$/.test(url);

        // Update sidebar visibility
        if (isLessonView !== !this.sidebarVisibility.value) {
          this.sidebarVisibility.next(!isLessonView);
          this.cdr.detectChanges();
        }
      }
    });
  }

  ngOnInit() {
    window.addEventListener('resize', this.resizeHandler);
  }

  ngAfterViewInit() {
    // Check initial route
    const currentUrl = this.router.url;
    const isLessonView = /\/lessons\/[^\/]+$/.test(currentUrl);
    this.sidebarVisibility.next(!isLessonView);
    this.cdr.detectChanges();

    document.body.style.overflow = 'hidden';
  }

  ngOnDestroy() {
    document.body.style.overflow = '';
    window.removeEventListener('resize', this.resizeHandler);
  }

  private onWindowResize(): void {
    this.checkMobileView();
    this.cdr.detectChanges();
  }

  private checkMobileView() {
    const wasMobile = this.isMobile;
    this.isMobile = window.innerWidth <= 768;

    if (!wasMobile && this.isMobile && !this.isSidebarCollapsed) {
      this.onSidebarCollapse(true);
    }
  }

  onSidebarCollapse(isCollapsed: boolean) {
    this.isSidebarCollapsed = isCollapsed;
    this.cdr.detectChanges();
  }
}