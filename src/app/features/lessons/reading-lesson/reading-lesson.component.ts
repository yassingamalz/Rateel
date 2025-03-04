// src/app/features/lessons/reading-lesson/reading-lesson.component.ts
import {
  Component,
  Input,
  Output,
  EventEmitter,
  OnInit,
  OnDestroy,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  ViewChild,
  ElementRef,
  AfterViewInit
} from '@angular/core';
import { ReadingLessonService } from './reading-lesson.service';
import { ReadingContent, ReadingState, TajweedRule } from './reading-lesson.types';
import { Subscription } from 'rxjs';
import { PlatformService } from '../../../core/services/platform.service';
import { trigger, state, style, transition, animate } from '@angular/animations';

@Component({
  selector: 'app-reading-lesson',
  standalone: false,
  templateUrl: './reading-lesson.component.html',
  styleUrls: ['./reading-lesson.component.scss'],
  providers: [ReadingLessonService], // Scoped to this component
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
    ])
  ]
})
export class ReadingLessonComponent implements OnInit, OnDestroy, AfterViewInit {
  @ViewChild('verseContainer') verseContainer!: ElementRef<HTMLElement>;
  
  @Input() content?: string;
  @Input() isCompleted?: boolean;
  @Output() onProgress = new EventEmitter<number>();
  @Output() onComplete = new EventEmitter<void>();

  parsedContent?: ReadingContent;
  state!: ReadingState;
  tajweedRules: TajweedRule[] = [];
  currentVerseIndex = 0;
  private subscriptions: Subscription[] = [];
  private isCompleting = false;

  constructor(
    private readingService: ReadingLessonService,
    private platformService: PlatformService,
    private cdr: ChangeDetectorRef
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
  }

  ngAfterViewInit(): void {
    // Initial scroll to the current verse if needed
    setTimeout(() => {
      this.scrollToCurrentVerse();
    }, 100);
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.readingService.resetState();
  }

  /**
   * Scroll to the currently selected verse
   */
  private scrollToCurrentVerse(): void {
    if (!this.verseContainer) return;
    
    const verseElement = this.verseContainer.nativeElement.querySelector(`#verse-${this.currentVerseIndex}`) as HTMLElement;
    
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
  }

  private async handleCompletion(): Promise<void> {
    if (this.isCompleting) return;
    this.isCompleting = true;

    // Provide haptic feedback on mobile
    try {
      await this.platformService.vibrateSuccess();
    } catch (error) {
      console.warn('Haptic feedback not available', error);
    }

    // Emit completion event after a delay for animation
    setTimeout(() => {
      this.onComplete.emit();
      this.isCompleting = false;
    }, 1500); // Match border fill animation duration
  }

  handleSkip(): void {
    console.log("[ReadingLessonComponent] Skip button clicked, isCompleted:", this.isCompleted);
    
    // Always emit completion event immediately for any click
    this.onComplete.emit();
    
    // Add haptic feedback
    this.platformService.vibrateSuccess().catch(() => {
      // Ignore errors if vibration is not available
    });
    
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
      
      // Scroll to the new current verse
      setTimeout(() => {
        this.scrollToCurrentVerse();
      }, 50);
    }
  }

  previousVerse(): void {
    if (this.currentVerseIndex > 0) {
      this.currentVerseIndex--;
      this.updateProgress();
      
      // Scroll to the new current verse
      setTimeout(() => {
        this.scrollToCurrentVerse();
      }, 50);
    }
  }

  private updateProgress(): void {
    if (this.parsedContent) {
      this.readingService.updateProgress(
        this.currentVerseIndex,
        this.parsedContent.verses.length
      );
    }
  }

  toggleRules(): void {
    this.readingService.toggleRulesPanel();
  }

  increaseFontSize(): void {
    this.readingService.increaseFontSize();
  }

  decreaseFontSize(): void {
    this.readingService.decreaseFontSize();
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