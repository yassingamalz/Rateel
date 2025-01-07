// unit-card.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { trigger, transition, style, animate } from '@angular/animations';
import { Unit } from '../../../shared/interfaces/unit';

@Component({
  selector: 'app-unit-card',
  standalone: false,
  templateUrl: './unit-card.component.html',
  styleUrls: ['./unit-card.component.scss'],
  animations: [
    trigger('circleAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.8)' }),
        animate('300ms ease-out', style({ opacity: 1, transform: 'scale(1)' }))
      ])
    ])
  ]
})
export class UnitCardComponent {
  @Input() unit!: Unit;
  @Output() unitSelected = new EventEmitter<Unit>();

  onUnitClick(): void {
    if (!this.unit.isLocked) {
      this.unitSelected.emit(this.unit);
    }
  }

  getTypeIcon(): string {
    switch (this.unit.type) {
      case 'video':
        return 'fa-play-circle';
      case 'listening':
        return 'fa-headphones';
      case 'reading':
        return 'fa-book-open';
      case 'exercise':
        return 'fa-pen-to-square';
      default:
        return 'fa-circle';
    }
  }

  getProgressCircleValue(): string {
    const circumference = 2 * Math.PI * 46; // r = 46 (from SVG)
    const offset = circumference - ((this.unit.progress || 0) / 100) * circumference;
    return `${offset}, ${circumference}`;
  }
}