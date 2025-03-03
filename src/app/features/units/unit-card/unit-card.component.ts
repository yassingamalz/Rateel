// Updated UnitCardComponent
import { Component, Input, Output, EventEmitter, OnChanges, SimpleChanges, ChangeDetectionStrategy, ChangeDetectorRef, DoCheck } from '@angular/core';
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
export class UnitCardComponent implements OnChanges, DoCheck {
  @Input() unit!: Unit;
  @Input() isActive = false;
  @Input() isCompleting = false;
  @Output() unitSelected = new EventEmitter<Unit>();

  animationState: 'default' | 'hovered' = 'default';
  progressCircleValue: string = '0';
  private oldProgress: number = -1; // Changed from 0 to -1 to ensure first update
  private prevUnitId: string = '';
  private prevCompletedState: boolean = false;
  private prevLockedState: boolean = false;
  private changeCount = 0;

  constructor(private cdr: ChangeDetectorRef) { }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['unit'] && this.unit) {
      // Always update progress circle on explicit input changes
      this.updateProgressCircle();
      this.prevUnitId = this.unit.id;
      this.oldProgress = this.unit.progress || 0;
      this.prevCompletedState = this.unit.isCompleted || false;
      this.prevLockedState = this.unit.isLocked || false;
      
      // Log for debugging
      console.log(`[UnitCard:${this.unit.id}] Input changed: progress=${this.unit.progress}, completed=${this.unit.isCompleted}, locked=${this.unit.isLocked}`);
    }

    if (changes['isCompleting'] || changes['isActive']) {
      // Force update for animation state changes
      this.cdr.markForCheck();
    }
  }

  ngDoCheck(): void {
    // Enhanced deep state checking that's more sensitive to changes
    if (this.unit && this.unit.id === this.prevUnitId) {
      const currentProgress = this.unit.progress || 0;
      const isCompleted = this.unit.isCompleted || false;
      const isLocked = this.unit.isLocked || false;

      // Check for any state changes that should trigger updates
      if (currentProgress !== this.oldProgress || 
          isCompleted !== this.prevCompletedState ||
          isLocked !== this.prevLockedState) {
        
        this.changeCount++;
        console.log(`[UnitCard:${this.unit.id}] State changed (${this.changeCount}) - progress: ${this.oldProgress} → ${currentProgress}, completed: ${this.prevCompletedState} → ${isCompleted}, locked: ${this.prevLockedState} → ${isLocked}`);
        
        // Update values
        this.updateProgressCircle();
        this.oldProgress = currentProgress;
        this.prevCompletedState = isCompleted;
        this.prevLockedState = isLocked;
        
        // Force immediate change detection
        this.cdr.detectChanges();
      }
    } else if (this.unit && this.unit.id !== this.prevUnitId) {
      // Handle unit object replacement (reference changes but still same ID)
      console.log(`[UnitCard] Unit ID changed from ${this.prevUnitId} to ${this.unit.id}`);
      this.prevUnitId = this.unit.id;
      this.updateProgressCircle();
      this.oldProgress = this.unit.progress || 0;
      this.prevCompletedState = this.unit.isCompleted || false;
      this.prevLockedState = this.unit.isLocked || false;
      
      // Force immediate change detection
      this.cdr.detectChanges();
    }
  }

  private updateProgressCircle(): void {
    if (!this.unit) return;
    
    const circumference = 2 * Math.PI * 46;
    const progress = this.unit.progress || 0;
    const dashArray = (progress / 100) * circumference;
    this.progressCircleValue = `${dashArray}, ${circumference}`;
    
    // Log progress updates
    console.log(`[UnitCard:${this.unit.id}] Updating progress circle to ${progress}% (dashArray: ${dashArray})`);
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