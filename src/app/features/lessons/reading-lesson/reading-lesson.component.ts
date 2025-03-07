// reading-lesson.component.ts
import {
  Component,
  Input,
  Output,
  EventEmitter,
  ViewChild,
  ElementRef,
  OnInit,
  OnDestroy,
  ChangeDetectionStrategy,
  ChangeDetectorRef
} from '@angular/core';
import { trigger, state, style, transition, animate } from '@angular/animations';
import { ReadingLessonService } from './reading-lesson.service';
import { ReadingContent, ReadingState, TajweedRule } from './reading-lesson.types';
import { Subscription } from 'rxjs';
import { ThemeService } from '../../../shared/services/theme.service';

@Component({
  selector: 'app-reading-lesson',
  standalone: false,
  templateUrl: './reading-lesson.component.html',
  styleUrls: ['./reading-lesson.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('slideInOut', [
      transition(':enter', [
        style({ transform: 'translateX(100%)' }),
        animate('300ms ease-out', style({ transform: 'translateX(0)' }))
      ]),
      transition(':leave', [
        animate('300ms ease-out', style({ transform: 'translateX(-100%)' }))
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
    ]),
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
    ])
  ]
})
export class ReadingLessonComponent implements OnInit, OnDestroy {
  @ViewChild('verseContainer') verseContainer!: ElementRef<HTMLElement>;

  @Input() content?: string;
  @Input() isCompleted?: boolean;
  @Output() onProgress = new EventEmitter<number>();
  @Output() onComplete = new EventEmitter<void>();

  // State management
  state!: ReadingState;
  parsedContent?: ReadingContent;
  currentVerseIndex = 0;

  // Typography controls
  isDarkMode = false;
  showFontMenu = false;
  selectedFont = 'Uthmanic';
  lineHeight = 2;
  letterSpacing = 0;

  availableFonts = [
    { name: 'خط عثماني', value: 'Uthmanic' },
    { name: 'خط القرآن', value: 'me_quran' },
    { name: 'القاهرة', value: 'Cairo' },
    { name: 'نسخ', value: 'Naskh, serif' }
  ];

  // Verse explanations
  expandedExplanations: { [verseIndex: number]: boolean } = {};

  // Rules search
  searchTerm = '';
  tajweedRules: TajweedRule[] = [];
  filteredRules: TajweedRule[] = [];

  private subscriptions: Subscription[] = [];
  private isCompleting = false;

  constructor(
    private readingService: ReadingLessonService,
    private cdr: ChangeDetectorRef,
    private themeService?: ThemeService
  ) { }

  ngOnInit(): void {
    console.log('[ReadingLessonComponent] Initializing with content:', this.content ? 'provided' : 'missing');

    if (this.content) {
      try {
        // Parse the content if it's a string
        this.parsedContent = this.readingService.parseContent(this.content);
        console.log('[ReadingLessonComponent] Parsed content:', this.parsedContent);
      } catch (error) {
        console.error('[ReadingLessonComponent] Error parsing content:', error);
      }
    } else {
      console.warn('[ReadingLessonComponent] No content provided');
    }

    this.tajweedRules = this.readingService.getTajweedRules();
    this.filteredRules = [...this.tajweedRules];

    // Subscribe to state changes
    this.subscriptions.push(
      this.readingService.getState().subscribe(state => {
        this.state = state;
        this.onProgress.emit(state.progress);

        if (state.isCompleted && !this.isCompleted && !this.isCompleting) {
          this.handleCompletion();
        }

        this.cdr.markForCheck();
      })
    );

    // Check if there's a saved theme preference
    if (this.themeService) {
      this.subscriptions.push(
        this.themeService.theme$.subscribe(theme => {
          this.isDarkMode = theme === 'dark';
          this.cdr.markForCheck();
        })
      );
    }
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.readingService.resetState();
  }

  /**
   * Scroll to the currently selected verse
   */
  private scrollToVerse(index: number): void {
    if (!this.verseContainer) return;

    setTimeout(() => {
      const verseElement = this.verseContainer.nativeElement.querySelector(`#verse-${index}`) as HTMLElement;

      if (verseElement) {
        const containerRect = this.verseContainer.nativeElement.getBoundingClientRect();
        const verseRect = verseElement.getBoundingClientRect();

        // Calculate the scroll position with some offset to center the verse
        const scrollPosition =
          verseElement.offsetTop -
          this.verseContainer.nativeElement.offsetTop -
          (containerRect.height / 2) +
          (verseRect.height / 2);

        // Scroll smoothly to the verse
        this.verseContainer.nativeElement.scrollTo({
          top: scrollPosition,
          behavior: 'smooth'
        });
      }
    }, 100);
  }

  private async handleCompletion(): Promise<void> {
    if (this.isCompleting) return;
    this.isCompleting = true;

    console.log('[ReadingLessonComponent] Lesson completed, triggering completion handler');

    // Emit completion event after a delay for animation
    setTimeout(() => {
      this.onComplete.emit();
      this.isCompleting = false;
    }, 1500); // Match animation duration
  }

  handleSkip(): void {
    console.log("[ReadingLessonComponent] Skip button clicked, isCompleted:", this.isCompleted);

    // Always emit completion event immediately for any click
    this.onComplete.emit();

    // If not already completed, also mark as completed
    if (!this.isCompleted && this.parsedContent) {
      this.readingService.updateProgress(
        this.parsedContent.verses.length - 1,
        this.parsedContent.verses.length
      );
    }
  }

  getFormattedVerse(verseIndex: number): string {
    if (!this.parsedContent?.verses[verseIndex]) return '';
    const verse = this.parsedContent.verses[verseIndex];
    return this.readingService.formatTajweedText(verse.text, verse.marks || []);
  }

  onRuleClick(ruleId: string): void {
    this.readingService.selectRule(ruleId);
  }

  nextVerse(): void {
    if (this.parsedContent && this.currentVerseIndex < this.parsedContent.verses.length - 1) {
      this.currentVerseIndex++;
      this.updateProgress();
      this.scrollToVerse(this.currentVerseIndex);
    }
  }

  previousVerse(): void {
    if (this.currentVerseIndex > 0) {
      this.currentVerseIndex--;
      this.updateProgress();
      this.scrollToVerse(this.currentVerseIndex);
    }
  }

  goToVerse(index: number): void {
    if (this.parsedContent && index >= 0 && index < this.parsedContent.verses.length) {
      this.currentVerseIndex = index;
      this.updateProgress();
      this.scrollToVerse(index);
    }
  }

  isVerseCompleted(index: number): boolean {
    // Check if all verses up to this index are completed
    return index < this.currentVerseIndex;
  }

  getVerseAnimationState(index: number): string {
    if (index === this.currentVerseIndex) {
      return 'active';
    } else if (this.isVerseCompleted(index)) {
      return 'completed';
    }
    return 'inactive';
  }

  private updateProgress(): void {
    if (this.parsedContent) {
      this.readingService.updateProgress(
        this.currentVerseIndex,
        this.parsedContent.verses.length
      );
    }
  }

  // Typography Controls
  toggleRules(): void {
    this.readingService.toggleRulesPanel();
  }

  toggleFontMenu(): void {
    this.showFontMenu = !this.showFontMenu;
    
    // When closing the menu, update the component with changes
    if (!this.showFontMenu) {
      this.cdr.markForCheck();
    }
  }

  toggleDarkMode(): void {
    this.isDarkMode = !this.isDarkMode;

    // Update theme service if available
    if (this.themeService) {
      this.themeService.setTheme(this.isDarkMode ? 'dark' : 'light');
    }
  }

  selectFont(fontFamily: string): void {
    this.selectedFont = fontFamily;
    // Don't close the menu immediately - let the user make other typography changes
  }

  increaseFontSize(): void {
    this.readingService.increaseFontSize();
  }

  decreaseFontSize(): void {
    this.readingService.decreaseFontSize();
  }

  increaseLineHeight(): void {
    this.lineHeight = Math.min(3, this.lineHeight + 0.1);
  }

  decreaseLineHeight(): void {
    this.lineHeight = Math.max(1, this.lineHeight - 0.1);
  }

  // Explanations toggle
  toggleExplanation(verseIndex: number): void {
    this.expandedExplanations[verseIndex] = !this.expandedExplanations[verseIndex];
  }

  // Rules search and filtering
  filterRules(): void {
    if (!this.searchTerm.trim()) {
      this.filteredRules = [...this.tajweedRules];
      return;
    }

    const searchLower = this.searchTerm.toLowerCase();
    this.filteredRules = this.tajweedRules.filter(rule =>
      rule.name.toLowerCase().includes(searchLower) ||
      rule.description.toLowerCase().includes(searchLower)
    );
  }

  clearSearch(): void {
    this.searchTerm = '';
    this.filteredRules = [...this.tajweedRules];
  }

  onVerseScroll(event: Event): void {
    const element = event.target as HTMLElement;
    const scrollPercentage = (element.scrollTop / (element.scrollHeight - element.clientHeight)) * 100;

    if (scrollPercentage > 90 && !this.state.isCompleted && this.parsedContent) {
      this.readingService.updateProgress(
        this.parsedContent.verses.length - 1,
        this.parsedContent.verses.length
      );
    }
  }
}