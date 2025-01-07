// navigation.service.ts
import { Injectable } from '@angular/core';
import { MenuItem } from '../../shared/interfaces/menu-item';

@Injectable({
  providedIn: 'root'
})
export class NavigationService {
  readonly menuItems: MenuItem[] = [
    { path: '/courses', icon: 'graduation-cap', label: 'الدروس', count: 30 },
    { path: '/quran', icon: 'book', label: 'القرآن', count: 114 },
    { path: '/practice', icon: 'microphone', label: 'التدريب', count: 2 },
    { path: '/certificates', icon: 'certificate', label: 'الشهادات', count: 3 }
  ];
}