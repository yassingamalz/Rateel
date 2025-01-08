// main-layout.component.ts
import { Component, OnInit, ViewChild, ElementRef, AfterViewInit } from '@angular/core';
import { Router, NavigationEnd } from '@angular/router';
import { filter } from 'rxjs/operators';

@Component({
  selector: 'app-main-layout',
  standalone: false,
  templateUrl: './main-layout.component.html',
  styleUrls: ['./main-layout.component.scss']
})
export class MainLayoutComponent implements OnInit, AfterViewInit {
  @ViewChild('mainContainer') mainContainer!: ElementRef;
  
  isSidebarHidden = true;

  constructor(private router: Router) {}

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
    });
  }

  ngAfterViewInit() {
    document.body.style.overflow = 'hidden';
  }

  ngOnDestroy() {
    document.body.style.overflow = '';
  }

  toggleSidebar() {
    this.isSidebarHidden = !this.isSidebarHidden;
  }
}