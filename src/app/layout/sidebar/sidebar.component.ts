// sidebar.component.ts
import { Component, Output, EventEmitter, HostListener } from '@angular/core';
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
        width: '320px',
        background: 'linear-gradient(to bottom, #1B4332, #081C15)'
      })),
      state('collapsed', style({
        width: '80px',
        background: 'linear-gradient(to bottom, #1B4332, #081C15)'
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

export class SidebarComponent {
  @Output() collapse = new EventEmitter<boolean>();
  isCollapsed = true; 
  isMobile = window.innerWidth <= 768;
  menuItems: MenuItem[];

  constructor(private navigationService: NavigationService) {
    this.menuItems = this.navigationService.menuItems;
  }

  @HostListener('window:resize')
  onResize() {
    this.isMobile = window.innerWidth <= 768;
    if (this.isMobile && !this.isCollapsed) {
      this.toggleSidebar();
    }
  }

  toggleSidebar(): void {
    this.isCollapsed = !this.isCollapsed;
    this.collapse.emit(this.isCollapsed);
  }
}