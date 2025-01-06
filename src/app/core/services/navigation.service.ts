// navigation.service.ts
import { Injectable } from '@angular/core';
import { MenuItem } from '../../shared/interfaces/menu-item';

@Injectable({
  providedIn: 'root'
})
export class NavigationService {
  readonly menuItems: MenuItem[] = [
    { path: '/quran', icon: 'book-quran', label: 'القرآن', count: 114 },
    { path: '/lessons', icon: 'education', label: 'الدروس', count: 30 },
    { path: '/practice', icon: 'mic', label: 'التدريب', count: 0 },
    { path: '/certificates', icon: 'certificate', label: 'الشهادات', count: 0 }
  ];
}