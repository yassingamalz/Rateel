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
  ChangeDetectorRef
} from '@angular/core';
import { trigger, state, style, transition, animate } from '@angular/animations';
import { InteractiveLessonService } from './interactive-lesson.service';
import { TajweedVerse, InteractionState } from './interactive-lesson.types';
import { Subscription } from 'rxjs';

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
    ])
  ]
})
export class InteractiveLessonComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('versesContainer') versesContainer!: ElementRef;
  @ViewChild('versesWrapper') versesWrapper!: ElementRef;

  @Input() verses: TajweedVerse[] = [];
  @Input() isCompleted?: boolean;
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
    currentAudio: undefined
  };

  isDragging = false;
  startX = 0;
  startScrollPosition = 0;
  containerWidth = 0;
  totalWidth = 0;
  private subscriptions: Subscription[] = [];

  constructor(
    private interactiveService: InteractiveLessonService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    this.subscriptions.push(
      this.interactiveService.getState().subscribe(state => {
        this.state = state;
        this.onProgress.emit(this.calculateProgress());

        if (state.isCompleted && !this.isCompleted) {
          this.onComplete.emit();
        }
        this.cdr.markForCheck();
      })
    );
  }

  ngAfterViewInit(): void {
    this.initializeContainerDimensions();
    this.setupResizeListener();
  }

  private initializeContainerDimensions(): void {
    if (this.versesContainer && this.verses.length) {
      this.containerWidth = this.versesContainer.nativeElement.clientWidth;
      this.totalWidth = this.verses.length * 500; // Match with SCSS verse card width
      this.cdr.markForCheck();
    }
  }

  private setupResizeListener(): void {
    const resizeObserver = new ResizeObserver(() => {
      this.initializeContainerDimensions();
    });

    if (this.versesContainer) {
      resizeObserver.observe(this.versesContainer.nativeElement);
    }
  }

  // Mouse Event Handlers
  onMouseDown(event: MouseEvent): void {
    if (this.state.isRecording) return; // Prevent dragging while recording

    this.isDragging = true;
    this.startX = event.pageX;
    this.startScrollPosition = this.state.scrollPosition;
    this.versesContainer.nativeElement.style.cursor = 'grabbing';
  }

  onMouseMove(event: MouseEvent): void {
    if (!this.isDragging) return;
  
    event.preventDefault();
    // Flip the delta calculation for RTL
    const deltaX = event.pageX - this.startX;
    const newPosition = this.startScrollPosition + deltaX;
  
    this.interactiveService.updateScrollPosition(
      newPosition,
      this.containerWidth,
      this.totalWidth
    );
  }

  onMouseUp(): void {
    if (!this.isDragging) return;

    this.isDragging = false;
    this.versesContainer.nativeElement.style.cursor = 'grab';
    this.interactiveService.snapToVerse(this.state.currentVerseIndex);
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
  
    // Flip the delta calculation for RTL
    const deltaX = event.touches[0].pageX - this.startX;
    const newPosition = this.startScrollPosition + deltaX;
  
    this.interactiveService.updateScrollPosition(
      newPosition,
      this.containerWidth,
      this.totalWidth
    );
  }

  onTouchEnd(): void {
    if (!this.isDragging) return;

    this.isDragging = false;
    this.interactiveService.snapToVerse(this.state.currentVerseIndex);
  }

  // Recording Functions
  async toggleRecording(): Promise<void> {
    if (this.state.isRecording) {
      try {
        await this.interactiveService.stopRecording();
        await this.handleRecordingComplete();
      } catch (error) {
        console.error('Error stopping recording:', error);
      }
    } else {
      try {
        await this.interactiveService.startRecording();
      } catch (error) {
        console.error('Error starting recording:', error);
      }
    }
  }

  private async handleRecordingComplete(): Promise<void> {
    // Here you would implement actual verification logic
    // For now, using a simple simulation
    const isCorrect = Math.random() > 0.3;

    if (isCorrect) {
      await this.interactiveService.completeCurrentVerse(this.verses.length);
    } else {
      this.interactiveService.showFeedback('حاول مرة أخرى');
    }
  }

  getHighlightedText(verse: TajweedVerse): string {
    if (!verse.highlights?.length) {
      return verse.text;
    }

    let result = verse.text;
    verse.highlights
      .sort((a, b) => b.start - a.start)
      .forEach(highlight => {
        const before = result.slice(0, highlight.start);
        const highlighted = result.slice(highlight.start, highlight.end);
        const after = result.slice(highlight.end);
        result = `${before}<span class="highlight" style="color: ${highlight.color}">${highlighted}</span>${after}`;
      });

    return result;
  }

  calculateProgress(): number {
    return (Array.from(this.state.answers.values()).filter(Boolean).length / this.verses.length) * 100;
  }

  isVerseCompleted(index: number): boolean {
    return this.state.answers.get(index.toString()) === true;
  }

  isVerseActive(index: number): boolean {
    return index === this.state.currentVerseIndex;
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.interactiveService.resetState();
  }
}