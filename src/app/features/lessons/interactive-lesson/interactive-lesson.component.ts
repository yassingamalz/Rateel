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
  NgZone,
  HostListener
} from '@angular/core';
import { trigger, state, style, transition, animate, keyframes, query, stagger } from '@angular/animations';
import { InteractiveLessonService } from './interactive-lesson.service';
import { TajweedVerse, InteractionState } from './interactive-lesson.types';
import { Subscription, fromEvent, debounceTime, takeUntil, timer } from 'rxjs';
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
        style({ opacity: 0, transform: 'translateY(-30px)' }),
        animate('300ms cubic-bezier(0.4, 0, 0.2, 1)', style({ opacity: 1, transform: 'translateY(0)' }))
      ]),
      transition(':leave', [
        animate('250ms cubic-bezier(0.4, 0, 0.2, 1)', style({ opacity: 0, transform: 'translateY(-30px)' }))
      ])
    ]),
    trigger('audioWave', [
      transition(':enter', [
        query('.wave-bar', [
          style({ transform: 'scaleY(0)' }),
          stagger(50, [
            animate('300ms ease-out', style({ transform: 'scaleY(1)' }))
          ])
        ], { optional: true })
      ])
    ])
  ]
})
export class InteractiveLessonComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('versesContainer') versesContainer!: ElementRef<HTMLElement>;
  
  @Input() set verses(value: TajweedVerse[]) {
    if (value && value.length > 0) {
      this._verses = value;
      if (this.interactiveService) {
        this.interactiveService.setVerses(value);
      }
    }
  }
  get verses(): TajweedVerse[] {
    return this._verses;
  }
  
  @Input() isCompleted?: boolean;
  @Output() onProgress = new EventEmitter<number>();
  @Output() onComplete = new EventEmitter<void>();

  private _verses: TajweedVerse[] = [];
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

  // Enhanced UI state variables
  isDragging = false;
  isSnapScrolling = false;
  startX = 0;
  startScrollPosition = 0;
  containerWidth = 0;
  totalContentWidth = 0;
  hasStartedLesson = false;
  autoScrollEnabled = true;
  lastDragTimestamp = 0;
  lastDragDirection = 0;
  dragVelocity = 0;
  isNavigating = false;
  resizeObserver: ResizeObserver | null = null;
  private verseElements: HTMLElement[] = [];
  
  // Animation timers
  private readonly SNAP_ANIMATION_DURATION = 500; // ms
  private readonly FEEDBACK_DURATION = 2000; // ms
  private readonly DEBOUNCE_TIME = 150; // ms for resize and other events
  
  // Physical constants for inertia
  private readonly INERTIA_FACTOR = 0.92; // Damping factor
  private readonly MIN_DRAG_VELOCITY = 0.5; // Minimum velocity to trigger inertia
  private readonly MAX_INERTIA_DURATION = 1000; // ms
  
  // Helpers for mobile detection
  private isMobilePortrait = window.innerWidth < 768;
  private isMobileLandscape = window.innerHeight < 500;

  private subscriptions: Subscription[] = [];
  private destroy$ = new Subscription();
  private VERSE_WIDTH = 500; // Base width of verse card
  private readonly WORD_WIDTH = 500; // Width of each verse card
  private readonly AUTO_SCROLL_THRESHOLD = 0.8; // 80% of words recognized triggers scroll

  constructor(
    private interactiveService: InteractiveLessonService,
    private platformService: PlatformService,
    private cdr: ChangeDetectorRef,
    private ngZone: NgZone
  ) {}

  @HostListener('window:resize')
  onResize() {
    this.ngZone.runOutsideAngular(() => {
      timer(this.DEBOUNCE_TIME).subscribe(() => {
        this.initializeContainerDimensions();
        this.snapToVerse(this.state.currentVerseIndex);
        this.cdr.detectChanges();
      });
    });
  }

  async ngOnInit() {
    // Initialize UI state based on device
    this.updateDeviceState();
    
    if (this.verses.length > 0) {
      // Set verses in service
      this.interactiveService.setVerses(this.verses);
      
      // Initialize with proper state management
      this.subscriptions.push(
        this.interactiveService.getState().subscribe({
          next: (state) => {
            this.state = { ...state };
            
            // Update progress
            this.onProgress.emit(state.progress);
            
            // Check for completion
            if (state.isCompleted && !this.isCompleted) {
              this.handleCompletion();
            }
            
            // Auto scroll if enabled and recording
            if (this.autoScrollEnabled && state.isRecording && 
                state.currentWordIndex !== undefined && this.verses.length > 1) {
              const verseWords = this.splitVerseIntoWords(this.verses[state.currentVerseIndex].text);
              const progress = (state.currentWordIndex % verseWords.length) / verseWords.length;
              
              if (progress > this.AUTO_SCROLL_THRESHOLD) {
                this.scrollToNextVerse();
              }
            }
            
            this.cdr.markForCheck();
          },
          error: (error) => console.error('State subscription error:', error)
        })
      );
    }
    
    // Setup resize observer
    this.setupResizeObserver();
  }

  ngAfterViewInit(): void {
    this.initializeContainerDimensions();
    this.cacheVerseElements();
    
    // Initialize scroll position
    setTimeout(() => {
      this.snapToVerse(this.state.currentVerseIndex || 0);
    }, 100);
  }
  
  private handleCompletion(): void {
    if (this.isNavigating) return;
    
    this.isNavigating = true;
    
    // Emit completion event
    this.onComplete.emit();
    
    // Reset navigation lock after a delay
    setTimeout(() => {
      this.isNavigating = false;
    }, 500);
  }
  
  // Cache verse elements for better performance
  private cacheVerseElements(): void {
    if (this.versesContainer) {
      this.verseElements = Array.from(
        this.versesContainer.nativeElement.querySelectorAll('.verse-card')
      );
    }
  }
  
  private updateDeviceState(): void {
    this.isMobilePortrait = window.innerWidth < 768;
    this.isMobileLandscape = window.innerHeight < 500;
  }
  
  private setupResizeObserver(): void {
    // Clean up any existing observer
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }
    
    // Create new observer
    this.resizeObserver = new ResizeObserver(() => {
      this.ngZone.run(() => {
        this.updateDeviceState();
        this.initializeContainerDimensions();
        this.cacheVerseElements();
        
        if (!this.isDragging) {
          this.snapToVerse(this.state.currentVerseIndex);
        }
      });
    });
    
    // Observe the container
    if (this.versesContainer) {
      this.resizeObserver.observe(this.versesContainer.nativeElement);
    }
  }

  private initializeContainerDimensions(): void {
    if (!this.versesContainer || !this.verses.length) return;
    
    const container = this.versesContainer.nativeElement;
    this.containerWidth = container.clientWidth;
    
    // Recalculate verse width based on viewport
    const verseElements = container.querySelectorAll('.verse-card');
    if (verseElements.length > 0) {
      // Get actual verse width from DOM
      const firstVerseElement = verseElements[0] as HTMLElement;
      const computedStyle = window.getComputedStyle(firstVerseElement);
      const totalMargin = parseFloat(computedStyle.marginLeft) + 
                         parseFloat(computedStyle.marginRight);
      
      // Calculate total width with margins
      const verseWidth = firstVerseElement.offsetWidth + totalMargin;
      
      // Update verse width constant
      this.VERSE_WIDTH = verseWidth;
      
      // Calculate total content width
      this.totalContentWidth = (this.verses.length * verseWidth) + 
                              (this.verses.length - 1) * 100; // connector lines
    }
  }

  // Mouse Event Handlers (Enhanced)
  onMouseDown(event: MouseEvent): void {
    if (this.isSnapScrolling || this.isNavigating) return;
    
    this.isDragging = true;
    this.startX = event.pageX;
    this.startScrollPosition = this.state.scrollPosition;
    this.lastDragTimestamp = Date.now();
    this.lastDragDirection = 0;
    this.dragVelocity = 0;
  }

  onMouseMove(event: MouseEvent): void {
    if (!this.isDragging) return;
    
    event.preventDefault();
    
    // Calculate movement and timing
    const currentTime = Date.now();
    const deltaTime = currentTime - this.lastDragTimestamp;
    const deltaX = event.pageX - this.startX;
    
    // Calculate drag velocity for inertia
    if (deltaTime > 0) {
      const instantVelocity = deltaX / deltaTime;
      // Smooth velocity with weighted average
      this.dragVelocity = (this.dragVelocity * 0.7) + (instantVelocity * 0.3);
      
      // Update last direction for inertia
      this.lastDragDirection = Math.sign(deltaX);
    }
    
    // Update timestamps
    this.lastDragTimestamp = currentTime;
    
    // Calculate new position (accounting for RTL direction)
    const newPosition = this.startScrollPosition + deltaX;
    
    // Update scroll position with bounds checking
    this.updateScrollPosition(newPosition);
  }

  onMouseUp(): void {
    if (!this.isDragging) return;
    
    this.isDragging = false;
    
    // Apply inertia if drag velocity is significant
    if (Math.abs(this.dragVelocity) > this.MIN_DRAG_VELOCITY) {
      this.applyInertia();
    } else {
      // Snap to nearest verse
      this.snapToNearestVerse();
    }
  }

  onMouseLeave(): void {
    this.onMouseUp();
  }

  // Touch Event Handlers (Enhanced)
  onTouchStart(event: TouchEvent): void {
    if (this.isSnapScrolling || this.isNavigating) return;
    
    this.isDragging = true;
    this.startX = event.touches[0].pageX;
    this.startScrollPosition = this.state.scrollPosition;
    this.lastDragTimestamp = Date.now();
    this.lastDragDirection = 0;
    this.dragVelocity = 0;
  }

  onTouchMove(event: TouchEvent): void {
    if (!this.isDragging) return;
    
    // Calculate movement and timing
    const currentTime = Date.now();
    const deltaTime = currentTime - this.lastDragTimestamp;
    const deltaX = event.touches[0].pageX - this.startX;
    
    // Calculate drag velocity for inertia
    if (deltaTime > 0) {
      const instantVelocity = deltaX / deltaTime;
      // Smooth velocity with weighted average
      this.dragVelocity = (this.dragVelocity * 0.7) + (instantVelocity * 0.3);
      
      // Update last direction for inertia
      this.lastDragDirection = Math.sign(deltaX);
    }
    
    // Update timestamps
    this.lastDragTimestamp = currentTime;
    
    // Calculate new position (accounting for RTL direction)
    const newPosition = this.startScrollPosition + deltaX;
    
    // Update scroll position with bounds checking
    this.updateScrollPosition(newPosition);
  }

  onTouchEnd(): void {
    if (!this.isDragging) return;
    
    this.isDragging = false;
    
    // Apply inertia if drag velocity is significant
    if (Math.abs(this.dragVelocity) > this.MIN_DRAG_VELOCITY) {
      this.applyInertia();
    } else {
      // Snap to nearest verse
      this.snapToNearestVerse();
    }
  }
  
  // Apply inertia effect after dragging
  private applyInertia(): void {
    const initialVelocity = this.dragVelocity;
    const startTime = Date.now();
    const startPosition = this.state.scrollPosition;
    let lastTimestamp = startTime;
    
    // Use requestAnimationFrame for smooth inertia
    const animateInertia = () => {
      const now = Date.now();
      const elapsedTime = now - startTime;
      
      // Stop animation if it's been running too long
      if (elapsedTime > this.MAX_INERTIA_DURATION) {
        this.snapToNearestVerse();
        return;
      }
      
      // Calculate damped velocity
      const dampedVelocity = initialVelocity * Math.pow(this.INERTIA_FACTOR, elapsedTime / 10);
      
      // Stop animation if velocity is too low
      if (Math.abs(dampedVelocity) < 0.1) {
        this.snapToNearestVerse();
        return;
      }
      
      // Calculate new position
      const deltaTime = now - lastTimestamp;
      const deltaPosition = dampedVelocity * deltaTime;
      const newPosition = startPosition + (elapsedTime * dampedVelocity / 5);
      
      // Update position
      this.updateScrollPosition(newPosition);
      lastTimestamp = now;
      
      // Continue animation
      requestAnimationFrame(animateInertia);
    };
    
    // Start animation
    requestAnimationFrame(animateInertia);
  }

  // Update scroll position with bounds checking
  private updateScrollPosition(position: number): void {
    // Calculate min and max scroll positions
    const minScroll = -(this.totalContentWidth - this.containerWidth);
    const maxScroll = 0;
    
    // Bound the position
    let boundedPosition = Math.max(minScroll, Math.min(maxScroll, position));
    
    // Add resistance when dragging past bounds
    if (position < minScroll) {
      const overDrag = minScroll - position;
      boundedPosition = minScroll - (overDrag / 3);
    } else if (position > maxScroll) {
      const overDrag = position - maxScroll;
      boundedPosition = maxScroll + (overDrag / 3);
    }
    
    // Update scroll position in service state
    this.interactiveService.updateScrollPosition(boundedPosition, this.containerWidth, this.totalContentWidth);
  }

  // Snap to nearest verse with animation
  private snapToNearestVerse(): void {
    if (!this.versesContainer || this.verses.length === 0) return;
    
    // Calculate verse width with spacing
    const verseWidth = this.VERSE_WIDTH;
    
    // Calculate the nearest verse index
    const scrollRatio = Math.abs(this.state.scrollPosition) / verseWidth;
    let nearestVerseIndex = Math.round(scrollRatio);
    
    // Ensure index is within bounds
    nearestVerseIndex = Math.max(0, Math.min(nearestVerseIndex, this.verses.length - 1));
    
    // Snap to the verse
    this.snapToVerse(nearestVerseIndex);
  }

  // Snap to a specific verse
  private snapToVerse(index: number): void {
    if (this.isSnapScrolling || !this.versesContainer) return;
    
    // Enable snap scrolling animation flag
    this.isSnapScrolling = true;
    
    // Calculate target position based on verse width
    const targetPosition = -(index * this.VERSE_WIDTH);
    
    // Update state with new position and verse index
    this.interactiveService.snapToVerse(index);
    
    // Disable snap scrolling after animation
    setTimeout(() => {
      this.isSnapScrolling = false;
      this.cdr.detectChanges();
    }, this.SNAP_ANIMATION_DURATION);
  }

  // Scroll to the next verse
  scrollToNextVerse(): void {
    const currentIndex = this.state.currentVerseIndex;
    if (currentIndex < this.verses.length - 1) {
      this.snapToVerse(currentIndex + 1);
    }
  }
  
  // Scroll to the previous verse
  scrollToPreviousVerse(): void {
    const currentIndex = this.state.currentVerseIndex;
    if (currentIndex > 0) {
      this.snapToVerse(currentIndex - 1);
    }
  }
  
  // Check if we can scroll left (for indicators)
  canScrollLeft(): boolean {
    return this.state.currentVerseIndex > 0;
  }
  
  // Check if we can scroll right (for indicators)
  canScrollRight(): boolean {
    return this.state.currentVerseIndex < this.verses.length - 1;
  }

  // Word Processing Methods (Enhanced)
  splitVerseIntoWords(text: string): string[] {
    if (!text) return [];
    return text.split(/\s+/).filter(word => word.length > 0);
  }

  hasHighlight(verse: TajweedVerse, word: string, wordIndex: number): boolean {
    if (!verse.highlights) return false;

    const wordStart = this.getWordStartIndex(verse.text, wordIndex);
    const wordEnd = wordStart + word.length;

    return verse.highlights.some(h =>
      (h.start >= wordStart && h.start < wordEnd) ||
      (h.end > wordStart && h.end <= wordEnd) ||
      (wordStart >= h.start && wordEnd <= h.end)
    );
  }

  getWordColor(verse: TajweedVerse, word: string, wordIndex: number): string {
    if (!verse.highlights) return '';

    const wordStart = this.getWordStartIndex(verse.text, wordIndex);
    
    // Find all highlights that contain this word
    const matchingHighlights = verse.highlights.filter(h => 
      (h.start <= wordStart && h.end >= wordStart + word.length) ||
      (wordStart <= h.start && wordStart + word.length >= h.end)
    );
    
    // Return the color of the first matching highlight
    return matchingHighlights.length > 0 ? matchingHighlights[0].color : '';
  }

  private getWordStartIndex(text: string, wordIndex: number): number {
    if (!text) return 0;
    
    const words = text.split(/\s+/);
    let startIndex = 0;
    
    for (let i = 0; i < wordIndex && i < words.length; i++) {
      startIndex += words[i].length + 1; // +1 for the space
    }
    
    return startIndex;
  }

  // Enhanced state check functions
  isWordSpoken(verseIndex: number, wordIndex: number): boolean {
    if (!this.state.recognizedWords) return false;
    
    // Get global word index
    const globalIndex = this.getGlobalWordIndex(verseIndex, wordIndex);
    return this.state.recognizedWords.has(globalIndex);
  }

  isCurrentWord(verseIndex: number, wordIndex: number): boolean {
    if (this.state.currentWordIndex === undefined) return false;
    
    // Get global word index
    const globalIndex = this.getGlobalWordIndex(verseIndex, wordIndex);
    return this.state.currentWordIndex === globalIndex;
  }

  private getGlobalWordIndex(verseIndex: number, wordIndex: number): number {
    let globalIndex = wordIndex;
    
    // Add the word counts of all previous verses
    for (let i = 0; i < verseIndex && i < this.verses.length; i++) {
      const verseText = this.verses[i]?.text || '';
      globalIndex += this.splitVerseIntoWords(verseText).length;
    }
    
    return globalIndex;
  }

  // State check functions
  isVerseActive(index: number): boolean {
    return this.state.currentVerseIndex === index;
  }

  isVerseCompleted(index: number): boolean {
    if (!this.state.answers) return false;
    return this.state.answers.get(index.toString()) === true;
  }

  getConnectorProgress(verseIndex: number): number {
    if (this.isVerseCompleted(verseIndex)) return 100;
    if (!this.isVerseActive(verseIndex)) return 0;
    
    // If active verse, show progress based on recognized words
    const verseText = this.verses[verseIndex]?.text || '';
    const words = this.splitVerseIntoWords(verseText);
    let recognizedCount = 0;
    
    // Count recognized words
    for (let i = 0; i < words.length; i++) {
      if (this.isWordSpoken(verseIndex, i)) {
        recognizedCount++;
      }
    }
    
    // Calculate progress percentage
    return words.length > 0 ? (recognizedCount / words.length) * 100 : 0;
  }

  // Get unique tajweed rules for legend
  getUniqueRules(verse: TajweedVerse): { rule: string; color: string; }[] {
    if (!verse.highlights) return [];

    // Create a map to deduplicate rules
    const rulesMap = new Map<string, { rule: string; color: string; }>();
    
    // Add each rule to the map
    verse.highlights.forEach(h => {
      if (!rulesMap.has(h.rule)) {
        rulesMap.set(h.rule, { rule: h.rule, color: h.color });
      }
    });
    
    // Convert map to array
    return Array.from(rulesMap.values());
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
        // Check and request permissions if needed
        if (Capacitor.isNativePlatform()) {
          const hasPermission = await this.platformService.initializeMicrophone();
          if (!hasPermission) {
            this.interactiveService.showFeedback('تحتاج إلى السماح باستخدام الميكروفون');
            return;
          }
        }
        
        // Start recording
        await this.interactiveService.startRecording();
        await this.platformService.vibrateSuccess();
      }
    } catch (error) {
      console.error('Recording error:', error);
      await this.platformService.vibrateError();
      
      // Show appropriate feedback
      this.interactiveService.showFeedback(
        this.state.isRecording ?
          'عذراً، حدث خطأ في التسجيل' :
          'عذراً، لا يمكن بدء التسجيل'
      );
    }
  }

  // Feedback check
  isSuccessFeedback(feedback: string): boolean {
    return feedback.includes('أحسنت') || 
           feedback.includes('ممتاز') || 
           feedback.includes('رائع');
  }
  
  ngOnDestroy(): void {
    // Clean up all subscriptions
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.destroy$.unsubscribe();
    
    // Reset service state
    this.interactiveService.resetState();
    
    // Disconnect resize observer
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
      this.resizeObserver = null;
    }
  }
}