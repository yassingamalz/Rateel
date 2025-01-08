// sidebar.component.ts
import { Component, Input, Output, EventEmitter, OnInit } from '@angular/core';
import { animate, state, style, transition, trigger } from '@angular/animations';
import { NavigationService } from '../../core/services/navigation.service';
import { MenuItem } from '../../shared/interfaces/menu-item';

@Component({
  selector: 'app-sidebar',
  standalone: false,

  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.scss'],
  animations: [
    trigger('sidebarState', [
      state('expanded', style({
        width: '320px'
      })),
      state('collapsed', style({
        width: '80px'
      })),
      transition('expanded <=> collapsed', [
        animate('300ms cubic-bezier(0.4, 0, 0.2, 1)')
      ])
    ]),
    trigger('contentFade', [
      state('visible', style({
        opacity: 1,
        transform: 'translateX(0)'
      })),
      state('hidden', style({
        opacity: 0,
        transform: 'translateX(-20px)',
        display: 'none'
      })),
      transition('visible <=> hidden', [
        animate('200ms ease-in-out')
      ])
    ])
  ]
})
export class SidebarComponent implements OnInit {
  @Input() isCollapsed = false;
  @Input() isMobile = false;
  @Output() collapse = new EventEmitter<boolean>();
  
  menuItems: MenuItem[];

  constructor(private navigationService: NavigationService) {
    this.menuItems = this.navigationService.menuItems;
  }

  ngOnInit() {
    // Initialize with mobile state if needed
    if (this.isMobile && !this.isCollapsed) {
      this.toggleSidebar();
    }
  }

  toggleSidebar(): void {
    this.collapse.emit(!this.isCollapsed);
  }

  trackByFn(index: number, item: MenuItem): string {
    return item.path;
  }
}