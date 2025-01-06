// sidebar.component.ts
import { Component, Output, EventEmitter } from '@angular/core';
import { NavigationService } from '../../core/services/navigation.service';
import { MenuItem } from '../../shared/interfaces/menu-item';

@Component({
  selector: 'app-sidebar',
  standalone: false,
  
  templateUrl: './sidebar.component.html',
  styleUrl: './sidebar.component.scss'
})
export class SidebarComponent {
  @Output() collapse = new EventEmitter<boolean>();
  isCollapsed = false;
  menuItems: MenuItem[];

  constructor(private navigationService: NavigationService) {
    this.menuItems = this.navigationService.menuItems;
  }

  toggleSidebar(): void {
    this.isCollapsed = !this.isCollapsed;
    this.collapse.emit(this.isCollapsed);
  }
}