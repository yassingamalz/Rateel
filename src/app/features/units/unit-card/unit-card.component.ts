// src/app/features/units/unit-card/unit-card.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { trigger, transition, style, animate } from '@angular/animations';
import { Unit } from '../../../shared/interfaces/unit';

@Component({
  selector: 'app-unit-card',
  standalone: false,
  templateUrl: './unit-card.component.html',
  styleUrls: ['./unit-card.component.scss'],
  animations: [
    trigger('cardAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateX(20px)' }),
        animate('300ms ease-out', style({ opacity: 1, transform: 'translateX(0)' }))
      ])
    ])
  ]
})
export class UnitCardComponent {
  @Input() unit!: Unit;
  @Output() unitSelected = new EventEmitter<Unit>();

  onCardClick(): void {
    if (!this.unit.isLocked) {
      this.unitSelected.emit(this.unit);
    }
  }

  getUnitIcon(): string {
    return this.unit.lessons[0]?.icon || 'fa-book';
  }
}