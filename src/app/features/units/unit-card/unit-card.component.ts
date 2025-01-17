// unit-card.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { trigger, transition, style, animate, state } from '@angular/animations';
import { Unit } from '../../../shared/interfaces/unit';

@Component({
  selector: 'app-unit-card',
  standalone: false,
  templateUrl: './unit-card.component.html',
  styleUrls: ['./unit-card.component.scss'],
  animations: [
    trigger('cardState', [
      state('default', style({
        transform: 'scale(1)'
      })),
      state('hovered', style({
        transform: 'scale(1.05)'
      })),
      transition('default => hovered', animate('200ms ease-out')),
      transition('hovered => default', animate('150ms ease-in'))
    ]),
    trigger('lockState', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.8)' }),
        animate('300ms ease-out', style({ opacity: 1, transform: 'scale(1)' }))
      ])
    ]),
    trigger('checkState', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0) rotate(-180deg)' }),
        animate('400ms ease-out', style({ opacity: 1, transform: 'scale(1) rotate(0)' }))
      ])
    ])
  ]
})
export class UnitCardComponent {
  @Input() unit!: Unit;
  @Input() isActive = false;
  @Input() isCompleting = false; 
  @Output() unitSelected = new EventEmitter<Unit>();

  animationState: 'default' | 'hovered' = 'default';

  onUnitClick(): void {
    console.log("hey - clicked");
    console.log("Unit locked status:", this.unit.isLocked);
    
    if (!this.unit.isLocked) {
      this.unitSelected.emit(this.unit);
      console.log("Unit selected:", this.unit);
    } else {
      console.log("Unit is locked, cannot select");
    }
  }

  getTypeIcon(): string {
    switch (this.unit.type) {
      case 'video': return 'fa-play-circle';
      case 'listening': return 'fa-headphones';
      case 'reading': return 'fa-book-open';
      case 'exercise': return 'fa-pen-to-square';
      default: return 'fa-circle';
    }
  }

  getProgressCircleValue(): string {
    const circumference = 2 * Math.PI * 46;
    const offset = circumference - ((this.unit.progress || 0) / 100) * circumference;
    return `${offset}, ${circumference}`;
  }
}