// main-layout.component.ts
import { Component, OnInit, ViewChild, ElementRef, AfterViewInit } from '@angular/core';
import { Router, NavigationEnd } from '@angular/router';
import { filter } from 'rxjs/operators';
import { trigger, state, style, transition, animate } from '@angular/animations';

@Component({
  selector: 'app-main-layout',
  standalone: false,
  templateUrl: './main-layout.component.html',
  styleUrls: ['./main-layout.component.scss'],
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
export class MainLayoutComponent implements OnInit, AfterViewInit {
  @ViewChild('mainContainer') mainContainer!: ElementRef;
  
  isSidebarCollapsed = false;
  isMobile = window.innerWidth <= 768;

  constructor(private router: Router) {
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
      
      // Auto-collapse sidebar on mobile navigation
      if (this.isMobile && !this.isSidebarCollapsed) {
        this.onSidebarCollapse(true);
      }
    });

    window.addEventListener('resize', this.onWindowResize.bind(this));
  }

  ngAfterViewInit() {
    document.body.style.overflow = 'hidden';
  }

  ngOnDestroy() {
    document.body.style.overflow = '';
    window.removeEventListener('resize', this.onWindowResize.bind(this));
  }

  private onWindowResize() {
    this.checkMobileView();
  }

  private checkMobileView() {
    const wasMobile = this.isMobile;
    this.isMobile = window.innerWidth <= 768;
    
    // Auto-collapse on mobile transition
    if (!wasMobile && this.isMobile && !this.isSidebarCollapsed) {
      this.onSidebarCollapse(true);
    }
  }

  onSidebarCollapse(isCollapsed: boolean) {
    this.isSidebarCollapsed = isCollapsed;
  }
}