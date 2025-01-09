import { Component, OnInit, ViewChild, ElementRef, AfterViewInit, ChangeDetectionStrategy, ChangeDetectorRef, OnDestroy } from '@angular/core';
import { Router, NavigationEnd } from '@angular/router';
import { filter } from 'rxjs/operators';
import { trigger, state, style, transition, animate } from '@angular/animations';

@Component({
  selector: 'app-main-layout',
  standalone: false,
  templateUrl: './main-layout.component.html',
  styleUrls: ['./main-layout.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('contentState', [
      state('expanded', style({
        marginRight: '320px'
      })),
      state('collapsed', style({
        marginRight: '80px'
      })),
      transition('expanded <=> collapsed', [
        animate('300ms cubic-bezier(0.4, 0, 0.2, 1)')
      ])
    ])
  ]
})
export class MainLayoutComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('mainContainer') mainContainer!: ElementRef;

  isSidebarCollapsed = true;
  isMobile = window.innerWidth <= 768;
  isContentLoaded = true; // Set this to true by default

  private resizeHandler: () => void;

  constructor(
    private router: Router,
    private cdr: ChangeDetectorRef
  ) {
    this.resizeHandler = this.onWindowResize.bind(this);
    this.checkMobileView();
  }

  ngOnInit() {
    this.router.events.pipe(
      filter(event => event instanceof NavigationEnd)
    ).subscribe(() => {
      if (this.mainContainer?.nativeElement) {
        const contentWrapper = this.mainContainer.nativeElement.querySelector('.content-wrapper');
        if (contentWrapper) {
          contentWrapper.scrollTop = 0;
        }
      }

      if (this.isMobile && !this.isSidebarCollapsed) {
        this.onSidebarCollapse(true);
      }
    });

    window.addEventListener('resize', this.resizeHandler);
  }

  ngAfterViewInit() {
    document.body.style.overflow = 'hidden';
  }

  ngOnDestroy() {
    document.body.style.overflow = '';
    // Remove the event listener using the bound method
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