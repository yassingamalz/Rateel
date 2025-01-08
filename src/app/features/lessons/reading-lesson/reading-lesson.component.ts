// src/app/features/lessons/reading-lesson/reading-lesson.component.ts
import {
  Component,
  Input,
  Output,
  EventEmitter,
  OnInit,
  OnDestroy
} from '@angular/core';
import { ReadingLessonService } from './reading-lesson.service';
import { ReadingContent, ReadingState, TajweedRule } from './reading-lesson.types';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-reading-lesson',
  standalone: false,
  templateUrl: './reading-lesson.component.html',
  styleUrls: ['./reading-lesson.component.scss'],
  providers: [ReadingLessonService] // Scoped to this component
})
export class ReadingLessonComponent implements OnInit, OnDestroy {
  @Input() content?: string;
  @Input() isCompleted?: boolean;
  @Output() onProgress = new EventEmitter<number>();
  @Output() onComplete = new EventEmitter<void>();

  parsedContent?: ReadingContent;
  state!: ReadingState;
  tajweedRules: TajweedRule[] = [];
  currentVerseIndex = 0;

  private subscriptions: Subscription[] = [];

  constructor(private readingService: ReadingLessonService) { }

  ngOnInit(): void {
    if (this.content) {
      this.parsedContent = this.readingService.parseContent(this.content);
    }

    this.tajweedRules = this.readingService.getTajweedRules();

    // Subscribe to state changes
    this.subscriptions.push(
      this.readingService.getState().subscribe(state => {
        this.state = state;
        this.onProgress.emit(state.progress);

        if (state.isCompleted && !this.isCompleted) {
          this.onComplete.emit();
        }
      })
    );
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.readingService.resetState();
  }

  getFormattedVerse(verseIndex: number): string {
    if (!this.parsedContent?.verses[verseIndex]) return '';
    const verse = this.parsedContent.verses[verseIndex];
    return this.readingService.formatTajweedText(verse.text, verse.marks);
  }

  onRuleClick(ruleId: string): void {
    this.readingService.selectRule(ruleId);
  }

  nextVerse(): void {
    if (this.parsedContent && this.currentVerseIndex < this.parsedContent.verses.length - 1) {
      this.currentVerseIndex++;
      this.updateProgress();
    }
  }

  previousVerse(): void {
    if (this.currentVerseIndex > 0) {
      this.currentVerseIndex--;
      this.updateProgress();
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

    if (scrollPercentage > 90 && !this.state.isCompleted) {
      this.readingService.updateProgress(
        this.parsedContent!.verses.length - 1,
        this.parsedContent!.verses.length
      );
    }
  }
}