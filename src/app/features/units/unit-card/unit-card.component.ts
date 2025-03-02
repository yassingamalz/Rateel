// unit-card.component.ts
import { Component, Input, Output, EventEmitter, OnChanges, SimpleChanges, ChangeDetectionStrategy } from '@angular/core';
import { trigger, transition, style, animate, state } from '@angular/animations';
import { Unit } from '../../../shared/interfaces/unit';

@Component({
  selector: 'app-unit-card',
  standalone: false,
  templateUrl: './unit-card.component.html',
  styleUrls: ['./unit-card.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
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
export class UnitCardComponent implements OnChanges {
  @Input() unit!: Unit;
  @Input() isActive = false;
  @Input() isCompleting = false;
  @Output() unitSelected = new EventEmitter<Unit>();

  animationState: 'default' | 'hovered' = 'default';
  progressCircleValue: string = '0';

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['unit']) {
      this.updateProgressCircle();
    }
  }

  private updateProgressCircle(): void {
    const circumference = 2 * Math.PI * 46;
    const progress = this.unit.progress || 0;
    const dashArray = (progress / 100) * circumference;
    this.progressCircleValue = `${dashArray}, ${circumference}`;
  }

  onUnitClick(): void {
    if (!this.unit.isLocked) {
      this.unitSelected.emit(this.unit);
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

  get formattedProgress(): number {
    return Math.round(this.unit.progress || 0);
  }
}