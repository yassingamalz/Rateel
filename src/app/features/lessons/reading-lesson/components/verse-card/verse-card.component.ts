import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { trigger, state, style, transition, animate } from '@angular/animations';
import { VerseSection } from '../../reading-lesson.types';

@Component({
  selector: 'app-verse-card',
  standalone: false,
  templateUrl: './verse-card.component.html',
  styleUrls: ['./verse-card.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('verseAnimation', [
      state('inactive', style({
        opacity: 0.7,
        transform: 'scale(1)'
      })),
      state('active', style({
        opacity: 1,
        transform: 'scale(1.01)'
      })),
      state('completed', style({
        opacity: 0.8,
        transform: 'scale(1)'
      })),
      transition('* => active', [
        animate('300ms ease-out')
      ]),
      transition('active => *', [
        animate('200ms ease-in')
      ])
    ]),
    trigger('slideDown', [
      transition(':enter', [
        style({ opacity: 0, height: 0, overflow: 'hidden' }),
        animate('300ms ease-out', style({ opacity: 1, height: '*', overflow: 'hidden' }))
      ]),
      transition(':leave', [
        style({ overflow: 'hidden' }),
        animate('300ms ease-out', style({ opacity: 0, height: 0, overflow: 'hidden' }))
      ])
    ])
  ]
})
export class VerseCardComponent {
  @Input() verse!: VerseSection;
  @Input() verseIndex!: number;
  @Input() currentIndex: number = 0;
  @Input() expandedExplanation: boolean = false;
  @Input() formattedText: string = '';
  @Input() currentTheme: string = 'theme-dark';

  @Output() explanationToggled = new EventEmitter<number>();

  toggleExplanation(): void {
    this.explanationToggled.emit(this.verseIndex);
  }

  isCompleted(): boolean {
    return this.verseIndex < this.currentIndex;
  }

  isActive(): boolean {
    return this.verseIndex === this.currentIndex;
  }

  getAnimationState(): string {
    if (this.isActive()) {
      return 'active';
    } else if (this.isCompleted()) {
      return 'completed';
    }
    return 'inactive';
  }
}