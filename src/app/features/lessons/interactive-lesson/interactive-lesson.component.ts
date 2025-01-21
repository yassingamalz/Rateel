// interactive-lesson.component.ts
import {
  Component,
  Input,
  Output,
  EventEmitter,
  ViewChild,
  ElementRef,
  OnInit,
  OnDestroy,
  AfterViewInit,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  NgZone
} from '@angular/core';
import { trigger, state, style, transition, animate } from '@angular/animations';
import { InteractiveLessonService } from './interactive-lesson.service';
import { TajweedVerse, InteractionState } from './interactive-lesson.types';
import { Subscription, fromEvent } from 'rxjs';
import { debounceTime, takeUntil } from 'rxjs/operators';
import { Capacitor } from '@capacitor/core';
import { PlatformService } from '../../../core/services/platform.service';

@Component({
  selector: 'app-interactive-lesson',
  standalone: false,
  templateUrl: './interactive-lesson.component.html',
  styleUrls: ['./interactive-lesson.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('feedbackAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateY(-20px)' }),
        animate('200ms ease-out', style({ opacity: 1, transform: 'translateY(0)' }))
      ]),
      transition(':leave', [
        animate('200ms ease-in', style({ opacity: 0, transform: 'translateY(-20px)' }))
      ])
    ]),
    trigger('audioWave', [
      state('active', style({ height: '{{height}}px' }), { params: { height: 20 } }),
      state('inactive', style({ height: '2px' })),
      transition('inactive <=> active', animate('100ms ease-in-out'))
    ])
  ]
})
export class InteractiveLessonComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('versesContainer') versesContainer!: ElementRef<HTMLElement>;
  @ViewChild('versesWrapper') versesWrapper!: ElementRef<HTMLElement>;
  private subscriptions: Subscription[] = [];

  @Input() set verses(value: TajweedVerse[]) {
    if (value && value.length > 0) {
      this._verses = value;
      if (this.interactiveService) {
        console.log('Setting verses:', value);
        this.interactiveService.setVerses(value);
      }
    }
  }
  get verses(): TajweedVerse[] {
    return this._verses;
  }
  private _verses: TajweedVerse[] = []; @Input() isCompleted?: boolean;
  @Output() onProgress = new EventEmitter<number>();
  @Output() onComplete = new EventEmitter<void>();

  state: InteractionState = {
    currentVerseIndex: 0,
    answers: new Map<string, boolean>(),
    score: 0,
    isCompleted: false,
    progress: 0,
    scrollPosition: 0,
    feedback: undefined,
    isRecording: false,
    currentAudio: undefined,
    currentWordIndex: 0,
    recognizedWords: new Set<number>()
  };

  isDragging = false;
  startX = 0;
  startScrollPosition = 0;
  containerWidth = 0;
  totalWidth = 0;
  hasStartedLesson = false;
  autoScrollEnabled = true;
  private destroy$ = new Subscription();
  private readonly VERSE_WIDTH = 500; // Base width of verse card
  private readonly INITIAL_PADDING = 0.15; // 15% padding
  rightSpaceWidth = 100; // Width of right space container
  private readonly WORD_WIDTH = 500; // Width of each verse card
  private readonly AUTO_SCROLL_THRESHOLD = 0.8; // 80% of words recognized triggers scroll

  constructor(
    private interactiveService: InteractiveLessonService,
    private platformService: PlatformService,
    private cdr: ChangeDetectorRef,
    private ngZone: NgZone
  ) { }

  async ngOnInit() {
    if (this.verses.length > 0) {
      this.interactiveService.setVerses(this.verses);

      // Debug log
      console.log('Initializing with verses:', this.verses);

      // Initialize with default verse if none provided
      if (!this.verses || this.verses.length === 0) {
        this.verses = [{
          id: '1',
          text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          highlights: [
            {
              start: 5,
              end: 8,
              rule: 'noon-mushaddad',
              color: '#DAA520'
            },
            {
              start: 10,
              end: 13,
              rule: 'meem-mushaddad',
              color: '#DAA520'
            }
          ]
        }];
      }

      // Initialize service with verses
      this.interactiveService.setVerses(this.verses);

      // Start subscription
      this.subscriptions.push(
        this.interactiveService.getState().subscribe({
          next: (state) => {
            console.log('New state:', state);
            this.state = state;
            this.cdr.markForCheck();
          },
          error: (error) => console.error('State subscription error:', error)
        })
      );
    }
  }

  onRecordClick() {
    console.log('Record clicked, current verses:', this.verses);
    this.toggleRecording();
  }

  ngAfterViewInit(): void {
    this.initializeContainerDimensions();
    this.setupResizeListener();

    // Initialize scroll position to show first card
    setTimeout(() => {
      this.snapToVerse(0);
    });
  }

  private initializeContainerDimensions(): void {
    if (this.versesContainer && this.verses.length) {
      this.containerWidth = this.versesContainer.nativeElement.clientWidth;
      this.totalWidth = this.verses.length * this.VERSE_WIDTH;

      // Calculate initial position to show first verse
      if (!this.isDragging) {
        this.snapToVerse(0);
      }
    }
  }

  private snapToVerse(index: number): void {
    const containerWidth = this.versesContainer.nativeElement.clientWidth;
    const padding = containerWidth * this.INITIAL_PADDING;

    // Calculate position considering RTL layout and padding
    const position = -(index * this.VERSE_WIDTH) + padding;

    this.updateScrollPosition(position);
  }

  private updateScrollPosition(position: number): void {
    const containerWidth = this.versesContainer.nativeElement.clientWidth;
    const padding = containerWidth * this.INITIAL_PADDING;
    const maxScroll = -(this.totalWidth - containerWidth + padding);

    // Bound the position between max scroll and initial padding
    const boundedPosition = Math.max(
      maxScroll,
      Math.min(padding, position)
    );

    if (this.versesWrapper) {
      this.versesWrapper.nativeElement.style.transform =
        `translateX(${boundedPosition}px)`;

      this.state = {
        ...this.state,
        scrollPosition: boundedPosition
      };
    }
  }

  private snapToNearestVerse(): void {
    const containerWidth = this.versesContainer.nativeElement.clientWidth;
    const padding = containerWidth * this.INITIAL_PADDING;
    const currentOffset = Math.abs(this.state.scrollPosition - padding);
    const verseWidth = this.VERSE_WIDTH;

    const nearestVerseIndex = Math.round(currentOffset / verseWidth);

    this.snapToVerse(
      Math.max(0, Math.min(nearestVerseIndex, this.verses.length - 1))
    );
  }

  // Update the scroll to next verse logic
  scrollToNextVerse(): void {
    if (this.state.currentVerseIndex < this.verses.length - 1) {
      const nextIndex = this.state.currentVerseIndex + 1;
      this.snapToVerse(nextIndex);

      this.state = {
        ...this.state,
        currentVerseIndex: nextIndex
      };
    }
  }

  private setupResizeListener(): void {
    const resizeObserver = new ResizeObserver(() => {
      this.ngZone.run(() => {
        this.initializeContainerDimensions();
        if (!this.isDragging) {
          this.snapToCurrentVerse();
        }
      });
    });

    if (this.versesContainer) {
      resizeObserver.observe(this.versesContainer.nativeElement);
    }
  }

  private handleStateUpdate(state: InteractionState): void {
    // Handle progress updates
    this.onProgress.emit(this.calculateProgress());

    // Check for completion
    if (state.isCompleted && !this.isCompleted) {
      this.onComplete.emit();
    }

    // Handle auto-scrolling
    if (this.autoScrollEnabled && state.currentWordIndex !== undefined) {
      const currentVerseWords = this.splitVerseIntoWords(
        this.verses[state.currentVerseIndex].text
      ).length;
      const progress = (state.currentWordIndex % currentVerseWords) / currentVerseWords;

      if (progress > this.AUTO_SCROLL_THRESHOLD) {
        this.scrollToNextVerse();
      }
    }
  }

  // Word Processing Methods
  splitVerseIntoWords(text: string): string[] {
    return text.split(/\s+/).filter(word => word.length > 0);
  }

  hasHighlight(verse: TajweedVerse, word: string, wordIndex: number): boolean {
    if (!verse.highlights) return false;

    const wordStart = this.getWordStartIndex(verse.text, wordIndex);
    const wordEnd = wordStart + word.length;

    return verse.highlights.some(h =>
      (h.start >= wordStart && h.start < wordEnd) ||
      (h.end > wordStart && h.end <= wordEnd)
    );
  }

  getWordColor(verse: TajweedVerse, word: string, wordIndex: number): string {
    if (!verse.highlights) return 'inherit';

    const wordStart = this.getWordStartIndex(verse.text, wordIndex);
    const highlight = verse.highlights.find(h =>
      h.start <= wordStart && h.end >= wordStart + word.length
    );

    return highlight ? highlight.color : 'inherit';
  }

  private getWordStartIndex(text: string, wordIndex: number): number {
    const words = text.split(/\s+/);
    return words
      .slice(0, wordIndex)
      .reduce((acc, word) => acc + word.length + 1, 0);
  }

  isWordSpoken(verseIndex: number, wordIndex: number): boolean {
    const globalIndex = this.getGlobalWordIndex(verseIndex, wordIndex);
    return this.state.recognizedWords?.has(globalIndex) ?? false;
  }

  isCurrentWord(verseIndex: number, wordIndex: number): boolean {
    const globalIndex = this.getGlobalWordIndex(verseIndex, wordIndex);
    return this.state.currentWordIndex === globalIndex;
  }

  private getGlobalWordIndex(verseIndex: number, wordIndex: number): number {
    let globalIndex = wordIndex;
    for (let i = 0; i < verseIndex; i++) {
      globalIndex += this.splitVerseIntoWords(this.verses[i].text).length;
    }
    return globalIndex;
  }


  private snapToCurrentVerse(): void {
    this.snapToVerse(this.state.currentVerseIndex);
  }

  // Event Handlers
  async onMouseDown(event: MouseEvent): Promise<void> {
    if (this.state.isRecording) return;

    this.isDragging = true;
    this.startX = event.pageX;
    this.startScrollPosition = this.state.scrollPosition;
    this.versesContainer.nativeElement.style.cursor = 'grabbing';
  }

  onMouseMove(event: MouseEvent): void {
    if (!this.isDragging) return;

    event.preventDefault();
    const deltaX = event.pageX - this.startX;
    const newPosition = this.startScrollPosition + deltaX;

    this.updateScrollPosition(
      Math.max(
        -this.totalWidth + this.containerWidth,
        Math.min(0, newPosition)
      )
    );
  }

  onMouseUp(): void {
    if (!this.isDragging) return;

    this.isDragging = false;
    this.versesContainer.nativeElement.style.cursor = 'grab';
    this.snapToNearestVerse();
  }

  onMouseLeave(): void {
    this.onMouseUp();
  }

  // Touch Event Handlers
  onTouchStart(event: TouchEvent): void {
    if (this.state.isRecording) return;

    this.isDragging = true;
    this.startX = event.touches[0].pageX;
    this.startScrollPosition = this.state.scrollPosition;
  }

  onTouchMove(event: TouchEvent): void {
    if (!this.isDragging) return;

    const deltaX = event.touches[0].pageX - this.startX;
    const newPosition = this.startScrollPosition + deltaX;

    this.updateScrollPosition(
      Math.max(
        -this.totalWidth + this.containerWidth,
        Math.min(0, newPosition)
      )
    );
  }

  onTouchEnd(): void {
    if (!this.isDragging) return;

    this.isDragging = false;
    this.snapToNearestVerse();
  }

  // Recording Controls
  async toggleRecording(): Promise<void> {
    if (!this.hasStartedLesson) {
      this.hasStartedLesson = true;
    }

    try {
      if (this.state.isRecording) {
        await this.interactiveService.stopRecording();
        await this.platformService.vibrateSuccess();
      } else {
        if (Capacitor.isNativePlatform()) {
          const hasPermission = await this.platformService.initializeMicrophone();
          if (!hasPermission) {
            this.interactiveService.showFeedback('تحتاج إلى السماح باستخدام الميكروفون');
            return;
          }
        }
        await this.interactiveService.startRecording();
        await this.platformService.vibrateSuccess();
      }
    } catch (error) {
      console.error('Recording error:', error);
      await this.platformService.vibrateError();
      this.interactiveService.showFeedback(
        this.state.isRecording ?
          'عذراً، حدث خطأ في التسجيل' :
          'عذراً، لا يمكن بدء التسجيل'
      );
    }
  }

  // Helper Methods
  calculateProgress(): number {
    return (Array.from(this.state.answers.values()).filter(Boolean).length / this.verses.length) * 100;
  }

  isVerseCompleted(index: number): boolean {
    return this.state.answers.get(index.toString()) === true;
  }

  isVerseActive(index: number): boolean {
    return index === this.state.currentVerseIndex;
  }

  getConnectorProgress(verseIndex: number): number {
    if (this.isVerseCompleted(verseIndex)) return 100;
    if (!this.isVerseActive(verseIndex)) return 0;

    const verse = this.verses[verseIndex];
    const words = this.splitVerseIntoWords(verse.text);
    const spokenWords = words.filter((_, idx) =>
      this.isWordSpoken(verseIndex, idx)
    ).length;

    return (spokenWords / words.length) * 100;
  }

  getUniqueRules(verse: TajweedVerse): { rule: string; color: string; }[] {
    if (!verse.highlights) return [];

    return Array.from(new Set(
      verse.highlights.map(h => ({ rule: h.rule, color: h.color }))
    ));
  }

  isSuccessFeedback(feedback: string): boolean {
    return feedback.includes('أحسنت');
  }


  ngOnDestroy(): void {
    this.destroy$.unsubscribe();
    this.interactiveService.resetState();
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }
}