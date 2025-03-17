import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { trigger, transition, style, animate } from '@angular/animations';

@Component({
  selector: 'app-reading-controls-bar',
  standalone: false,
  templateUrl: './reading-controls-bar.component.html',
  styleUrls: ['./reading-controls-bar.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
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
export class ReadingControlsBarComponent {
  @Input() currentVerseIndex: number = 0;
  @Input() totalVerses: number = 0;
  @Input() fontSize: number = 24;
  @Input() lineHeight: number = 2;
  @Input() selectedFont: string = 'Uthmanic';
  @Input() showRules: boolean = false;
  @Input() currentTheme: string = 'theme-dark';

  @Output() previousClicked = new EventEmitter<void>();
  @Output() nextClicked = new EventEmitter<void>();
  @Output() fontSizeIncreased = new EventEmitter<void>();
  @Output() fontSizeDecreased = new EventEmitter<void>();
  @Output() lineHeightIncreased = new EventEmitter<void>();
  @Output() lineHeightDecreased = new EventEmitter<void>();
  @Output() fontSelected = new EventEmitter<string>();
  @Output() themeToggled = new EventEmitter<void>();
  @Output() rulesToggled = new EventEmitter<void>();

  showFontMenu: boolean = false;

  availableFonts = [
    { name: 'خط عثماني', value: 'Uthmanic' },
    { name: 'خط القرآن', value: 'me_quran' },
    { name: 'القاهرة', value: 'Cairo' },
    { name: 'نسخ', value: 'Naskh, serif' }
  ];

  toggleFontMenu(): void {
    this.showFontMenu = !this.showFontMenu;
  }

  onFontSelect(fontFamily: string): void {
    this.fontSelected.emit(fontFamily);
  }

  onThemeToggle(): void {
    this.themeToggled.emit();
  }

  onRulesToggle(): void {
    this.rulesToggled.emit();
  }

  onPrevious(): void {
    this.previousClicked.emit();
  }

  onNext(): void {
    this.nextClicked.emit();
  }

  onFontSizeIncrease(): void {
    this.fontSizeIncreased.emit();
  }

  onFontSizeDecrease(): void {
    this.fontSizeDecreased.emit();
  }

  onLineHeightIncrease(): void {
    this.lineHeightIncreased.emit();
  }

  onLineHeightDecrease(): void {
    this.lineHeightDecreased.emit();
  }

  clearFontMenu(event: MouseEvent): void {
    // Prevent closing when clicking inside the menu
    if (!(event.target as HTMLElement).closest('.typography-dropdown')) {
      this.showFontMenu = false;
    }
  }
}