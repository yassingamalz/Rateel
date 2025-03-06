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
  HostListener,
  ViewEncapsulation
} from '@angular/core';
import { trigger, state, style, transition, animate, keyframes, query, stagger } from '@angular/animations';
import { InteractiveLessonService } from './interactive-lesson.service';
import { TajweedVerse, InteractionState } from './interactive-lesson.types';
import { Subscription, fromEvent, timer } from 'rxjs';
import { debounceTime, takeUntil } from 'rxjs/operators';
import { Capacitor } from '@capacitor/core';
import { PlatformService } from '../../../core/services/platform.service';
import { ThemeService } from '../../../shared/services/theme.service';

@Component({
  selector: 'app-interactive-lesson',
  standalone: false,
  templateUrl: './interactive-lesson.component.html',
  styleUrls: ['./interactive-lesson.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  encapsulation: ViewEncapsulation.None,
  animations: [
    trigger('feedbackAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateY(-30px)' }),
        animate('300ms cubic-bezier(0.4, 0, 0.2, 1)', style({ opacity: 1, transform: 'translateY(0)' }))
      ]),
      transition(':leave', [
        animate('250ms cubic-bezier(0.4, 0, 0.2, 1)', style({ opacity: 0, transform: 'translateY(-30px)' }))
      ])
    ])
  ]
})
export class InteractiveLessonComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('versesContainer') versesContainer!: ElementRef<HTMLElement>;
  @ViewChild('versesTrack') versesTrack?: ElementRef<HTMLElement>;

  @Input() set verses(value: TajweedVerse[]) {
    console.log('[InteractiveLessonComponent] Verses received in component:', value);
    // Ensure value is an array
    if (value && Array.isArray(value) && value.length > 0) {
      this._verses = value;
      if (this.interactiveService) {
        console.log('[InteractiveLessonComponent] Setting verses in service:', value);
        this.interactiveService.setVerses(value);
      }
    } else {
      console.warn('[InteractiveLessonComponent] Invalid verses input, must be an array:', value);
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

  // UI state variables
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

  // Theme property
  currentTheme: 'light' | 'dark' = 'light';

  // Animation timers
  private readonly SNAP_ANIMATION_DURATION = 500; // ms
  private readonly DEBOUNCE_TIME = 150; // ms for resize and other events

  // Constants for inertia
  private readonly INERTIA_FACTOR = 0.92;
  private readonly MIN_DRAG_VELOCITY = 0.5;
  private readonly MAX_INERTIA_DURATION = 1000; // ms

  // Helpers for mobile detection
  private isMobilePortrait = window.innerWidth < 768;
  private isMobileLandscape = window.innerHeight < 500;

  private subscriptions: Subscription[] = [];
  private destroy$ = new Subscription();
  private VERSE_WIDTH = 500; // Base width of verse card
  private readonly AUTO_SCROLL_THRESHOLD = 0.8; // 80% of words recognized triggers scroll
  private readonly INITIAL_PADDING = 0.15;

  constructor(
    private interactiveService: InteractiveLessonService,
    private platformService: PlatformService,
    private cdr: ChangeDetectorRef,
    private ngZone: NgZone,
    private themeService: ThemeService
  ) { }

  @HostListener('window:resize')
  onResize() {
    console.log('[InteractiveLessonComponent] Window resize detected');
    this.ngZone.runOutsideAngular(() => {
      timer(this.DEBOUNCE_TIME).subscribe(() => {
        this.initializeContainerDimensions();
        this.snapToVerse(this.state.currentVerseIndex);
        this.cdr.detectChanges();
      });
    });
  }

  async ngOnInit() {
    console.log('[InteractiveLessonComponent] Initializing component');
    // Initialize UI state based on device
    this.updateDeviceState();

    // Subscribe to theme changes
    this.subscriptions.push(
      this.themeService.theme$.subscribe(theme => {
        this.currentTheme = theme;
        console.log(`[InteractiveLessonComponent] Theme updated to: ${theme}`);
        this.cdr.markForCheck();
      })
    );

    if (this.verses.length > 0) {
      // Set verses in service
      this.interactiveService.setVerses(this.verses);

      // Initialize with proper state management
      this.subscriptions.push(
        this.interactiveService.getState().subscribe({
          next: (state) => {
            // Track previous verse index to detect changes
            const prevVerseIndex = this.state.currentVerseIndex;

            // Log significant state changes
            if (state.currentVerseIndex !== prevVerseIndex) {
              console.log(`[InteractiveLessonComponent] Verse index changed: ${state.currentVerseIndex}`);
            }

            if (state.progress !== this.state.progress) {
              console.log(`[InteractiveLessonComponent] Progress updated: ${state.progress}%`);
            }

            if (state.isRecording !== this.state.isRecording) {
              console.log(`[InteractiveLessonComponent] Recording state changed: ${state.isRecording}`);
            }

            // Update state first
            this.state = { ...state };

            // After state update, snap to new verse if index changed
            if (state.currentVerseIndex !== prevVerseIndex) {
              console.log(`[InteractiveLessonComponent] Snapping to updated verse: ${state.currentVerseIndex}`);
              this.snapToVerse(state.currentVerseIndex);
            }

            // Update progress
            this.onProgress.emit(state.progress);

            // Check for completion
            if (state.isCompleted && !this.isCompleted) {
              console.log('[InteractiveLessonComponent] Lesson completed, triggering completion handler');
              this.handleCompletion();
            }

            // Auto scroll if enabled and recording
            if (this.autoScrollEnabled && state.isRecording &&
              state.currentWordIndex !== undefined && this.verses.length > 1) {
              const verseWords = this.splitVerseIntoWords(this.verses[state.currentVerseIndex].text);
              const progress = (state.currentWordIndex % verseWords.length) / verseWords.length;

              if (progress > this.AUTO_SCROLL_THRESHOLD) {
                console.log('[InteractiveLessonComponent] Auto-scrolling to next verse based on word progress');
                this.scrollToNextVerse();
              }
            }

            this.cdr.markForCheck();
          },
          error: (error) => console.error('[InteractiveLessonComponent] State subscription error:', error)
        })
      );
    }

    // Setup resize observer
    this.setupResizeObserver();
  }

  ngAfterViewInit(): void {
    // Initialize dimensions immediately to avoid flicker
    this.initializeContainerDimensions();
    this.cacheVerseElements();

    // Initialize scroll position with a slight delay to ensure DOM is fully rendered
    setTimeout(() => {
      console.log('[InteractiveLessonComponent] Initializing verse position...');
      // Ensure we have valid container dimensions
      this.initializeContainerDimensions();
      // Snap to initial verse
      const initialVerseIndex = this.state.currentVerseIndex || 0;
      this.snapToVerse(initialVerseIndex);

      // Force change detection
      this.cdr.detectChanges();
    }, 300);
  }

  // Used to toggle theme without affecting the global theme
  toggleTheme(): void {
    const newTheme = this.currentTheme === 'light' ? 'dark' : 'light';
    console.log(`[InteractiveLessonComponent] Toggling theme to: ${newTheme}`);
    this.themeService.setTheme(newTheme);
  }

  // Theme class getter for conditional styling
  get themeClass(): string {
    return `theme-${this.currentTheme}`;
  }

  private handleCompletion(): void {
    if (this.isNavigating) return;

    console.log('[InteractiveLessonComponent] Handling lesson completion');
    this.isNavigating = true;

    // Stop recording if active before completing the lesson
    if (this.state.isRecording) {
      console.log('[InteractiveLessonComponent] Stopping recording during completion');
      this.interactiveService.stopRecording().catch(error => {
        console.error('[InteractiveLessonComponent] Error stopping recording during completion:', error);
      });
    }

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
      console.log(`[InteractiveLessonComponent] Cached ${this.verseElements.length} verse elements`);
    }
  }

  private updateDeviceState(): void {
    this.isMobilePortrait = window.innerWidth < 768;
    this.isMobileLandscape = window.innerHeight < 500;
    console.log(`[InteractiveLessonComponent] Device state updated - Mobile Portrait: ${this.isMobilePortrait}, Mobile Landscape: ${this.isMobileLandscape}`);
  }

  private setupResizeObserver(): void {
    // Clean up any existing observer
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }

    // Create new observer
    this.resizeObserver = new ResizeObserver(() => {
      this.ngZone.run(() => {
        console.log('[InteractiveLessonComponent] Resize observer triggered');
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
      console.log('[InteractiveLessonComponent] Resize observer attached to verses container');
    }
  }

  private initializeContainerDimensions(): void {
    if (!this.versesContainer || !this.verses.length) return;

    const container = this.versesContainer.nativeElement;
    this.containerWidth = container.clientWidth;

    // Calculate total content width directly from DOM
    this.totalContentWidth = this.calculateTotalContentWidth();

    console.log(`[InteractiveLessonComponent] Container width: ${this.containerWidth}px`);
    console.log(`[InteractiveLessonComponent] Total content width: ${this.totalContentWidth}px for ${this.verses.length} verses`);
  }

  // Mouse Event Handlers (Enhanced)
  onMouseDown(event: MouseEvent): void {
    if (this.isSnapScrolling || this.isNavigating) return;

    console.log(`[InteractiveLessonComponent] Mouse down at X: ${event.pageX}`);
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

    // Calculate movement
    const deltaX = event.pageX - this.startX;

    // Use positive transform values with positive deltaX
    const newPosition = this.startScrollPosition + deltaX;

    // Log significant movements
    if (Math.abs(deltaX) > 20) {
      console.log(`[InteractiveLessonComponent] Drag: delta=${deltaX}px, newPos=${newPosition.toFixed(1)}`);
    }

    // Update scroll position
    this.updateScrollPosition(newPosition);
  }

  onMouseUp(): void {
    if (!this.isDragging) return;

    console.log(`[InteractiveLessonComponent] Mouse up, drag velocity: ${this.dragVelocity}`);
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

    console.log(`[InteractiveLessonComponent] Touch start at X: ${event.touches[0].pageX}`);
    this.isDragging = true;
    this.startX = event.touches[0].pageX;
    this.startScrollPosition = this.state.scrollPosition;
    this.lastDragTimestamp = Date.now();
    this.lastDragDirection = 0;
    this.dragVelocity = 0;
  }

  onTouchMove(event: TouchEvent): void {
    if (!this.isDragging) return;

    // Calculate movement
    const deltaX = event.touches[0].pageX - this.startX;

    // Use positive transform values with positive deltaX
    const newPosition = this.startScrollPosition + deltaX;

    // Log significant movements
    if (Math.abs(deltaX) > 20) {
      console.log(`[InteractiveLessonComponent] Touch: delta=${deltaX}px, newPos=${newPosition.toFixed(1)}`);
    }

    // Update scroll position
    this.updateScrollPosition(newPosition);
  }

  onTouchEnd(): void {
    if (!this.isDragging) return;

    console.log(`[InteractiveLessonComponent] Touch end, drag velocity: ${this.dragVelocity}`);
    this.isDragging = false;

    // Apply inertia if drag velocity is significant
    if (Math.abs(this.dragVelocity) > this.MIN_DRAG_VELOCITY) {
      this.applyInertia();
    } else {
      // Snap to nearest verse
      this.snapToNearestVerse();
    }
  }

  private updateScrollPosition(position: number): void {
    if (!this.versesContainer || !this.containerWidth) return;

    // Get container dimensions
    const containerWidth = this.versesContainer.nativeElement.clientWidth;

    // Get track element
    const trackElement = this.versesContainer.nativeElement.querySelector('.verses-track');
    if (!trackElement) return;

    // Calculate maximum scroll based on actual content width
    const maxScroll = Math.max(0, trackElement.scrollWidth - containerWidth);

    // Bound the position within valid range
    let boundedPosition = Math.max(0, Math.min(maxScroll, position));

    // Add resistance when dragging past bounds
    if (position < 0) {
      boundedPosition = position / 3; // Resistance when pulling past start
    } else if (position > maxScroll) {
      boundedPosition = maxScroll + (position - maxScroll) / 3; // Resistance when pulling past end
    }

    // Update state
    this.state = {
      ...this.state,
      scrollPosition: boundedPosition
    };

    // Apply transformation directly to DOM
    if (trackElement instanceof HTMLElement) {
      // For RTL layout, we use positive translateX values
      trackElement.style.transform = `translateX(${boundedPosition}px)`;
    }

    // Update UI
    this.cdr.detectChanges();
  }

  // Helper function to properly calculate total content width
  private calculateTotalContentWidth(): number {
    if (!this.versesContainer) return 0;

    const verseElements = this.versesContainer.nativeElement.querySelectorAll('.verse-card');
    const connectorElements = this.versesContainer.nativeElement.querySelectorAll('.connector-line');

    let totalWidth = 0;

    // Calculate width from verse elements with margins
    Array.from(verseElements).forEach((element) => {
      const htmlElement = element as HTMLElement;
      totalWidth += htmlElement.offsetWidth;
      const style = window.getComputedStyle(htmlElement);
      totalWidth += parseFloat(style.marginLeft) || 0;
      totalWidth += parseFloat(style.marginRight) || 0;
    });

    // Add connector widths with margins
    Array.from(connectorElements).forEach((element) => {
      const htmlElement = element as HTMLElement;
      totalWidth += htmlElement.offsetWidth;
      const style = window.getComputedStyle(htmlElement);
      totalWidth += parseFloat(style.marginLeft) || 0;
      totalWidth += parseFloat(style.marginRight) || 0;
    });

    return totalWidth;
  }

  // Apply inertia effect after dragging
  private applyInertia(): void {
    const initialVelocity = this.dragVelocity;
    const startTime = Date.now();
    const startPosition = this.state.scrollPosition;
    let lastTimestamp = startTime;

    // Use requestAnimationFrame for smooth inertia
    const animateInertia = () => {
      if (this.isSnapScrolling) return; // Don't continue if snap animation started

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
      const movementFactor = elapsedTime * dampedVelocity / 5;
      const newPosition = startPosition + movementFactor;

      console.log(`[InteractiveLessonComponent] Inertia: pos=${newPosition.toFixed(1)}, vel=${dampedVelocity.toFixed(3)}`);

      // Update position
      this.updateScrollPosition(newPosition);
      lastTimestamp = now;

      // Continue animation
      requestAnimationFrame(animateInertia);
    };

    // Start animation
    this.ngZone.runOutsideAngular(() => {
      requestAnimationFrame(animateInertia);
    });
  }

  // Snap to nearest verse with animation
  private snapToNearestVerse(): void {
    if (!this.versesContainer || this.verses.length === 0) return;

    const containerWidth = this.versesContainer.nativeElement.clientWidth;
    const containerCenter = containerWidth / 2;
    const currentScrollPos = this.state.scrollPosition;

    // Get all verse elements
    const verseElements = this.versesContainer.nativeElement.querySelectorAll('.verse-card');

    // Find the verse whose center is closest to the container center
    let nearestIndex = 0;
    let minDistance = Number.MAX_VALUE;

    for (let i = 0; i < verseElements.length; i++) {
      const verse = verseElements[i] as HTMLElement;
      if (!verse) continue;

      // Calculate verse center position
      let versePosition = 0;

      // Sum up positions of all verses before this one
      for (let j = 0; j < i; j++) {
        const prevVerse = verseElements[j] as HTMLElement;
        if (prevVerse) {
          versePosition += prevVerse.offsetWidth;
          const style = window.getComputedStyle(prevVerse);
          versePosition += parseFloat(style.marginRight) || 0;

          const connector = prevVerse.nextElementSibling;
          if (connector && connector.classList.contains('connector-line')) {
            versePosition += connector.clientWidth;
            const connectorStyle = window.getComputedStyle(connector);
            versePosition += parseFloat(connectorStyle.marginRight) || 0;
            versePosition += parseFloat(connectorStyle.marginLeft) || 0;
          }
        }
      }

      // Add left margin of current verse
      const currentStyle = window.getComputedStyle(verse);
      versePosition += parseFloat(currentStyle.marginLeft) || 0;

      // Add half verse width to get to center
      versePosition += verse.offsetWidth / 2;

      // Calculate distance from verse center to where it should be
      const verseCenter = versePosition;
      const targetCenter = currentScrollPos + containerCenter;
      const distance = Math.abs(verseCenter - targetCenter);

      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    // Snap to nearest verse
    console.log(`[InteractiveLessonComponent] Snapping to nearest verse: ${nearestIndex}`);
    this.snapToVerse(nearestIndex);
  }

  // Snap to a specific verse within the current lesson
  private snapToVerse(index: number): void {
    if (!this.versesContainer || index < 0 || index >= this.verses.length) return;
  
    this.isSnapScrolling = true;
    
    // Get all verse elements 
    const verseElements = this.versesContainer.nativeElement.querySelectorAll('.verse-card');
    if (!verseElements.length) {
      this.isSnapScrolling = false;
      return;
    }
  
    // Get container dimensions
    const containerWidth = this.versesContainer.nativeElement.clientWidth;
    const containerCenter = containerWidth / 2 ;
    
    // Calculate the position to center the current verse
    let scrollPosition = 0;
    
    // Calculate position by measuring actual element positions
    for (let i = 0; i < index; i++) {
      const element = verseElements[i] as HTMLElement;
      if (element) {
        // For each verse before our target, add its width + any connector
        scrollPosition += element.offsetWidth;
        
        // Add any margins/padding between verses (including connectors)
        const style = window.getComputedStyle(element);
        scrollPosition += parseFloat(style.marginRight) || 0;
        
        // If there's a connector after this verse, include its width
        const connector = element.nextElementSibling;
        if (connector && connector.classList.contains('connector-line')) {
          scrollPosition += connector.clientWidth;
          
          // Also add any margins on the connector
          const connectorStyle = window.getComputedStyle(connector);
          scrollPosition += parseFloat(connectorStyle.marginRight) || 0;
          scrollPosition += parseFloat(connectorStyle.marginLeft) || 0;
        }
      }
    }
    
    // Get the current verse element
    const currentVerse = verseElements[index] as HTMLElement;
    if (currentVerse) {
      // Add left margin of current verse
      const currentStyle = window.getComputedStyle(currentVerse);
      scrollPosition += parseFloat(currentStyle.marginLeft) || 0;
      
      // *** CENTERING ADJUSTMENT AREA - MODIFY HERE TO TEST CENTERING ***
      const centeringAdjustment = 100; // Change this value to adjust verse position (positive = more right, negative = more left)
      
      // Center adjustment: subtract half container width, add half verse width
      scrollPosition -= containerCenter; 
      scrollPosition += currentVerse.offsetWidth / 2;
      
      // Apply custom centering adjustment
      scrollPosition += centeringAdjustment;
    }
    
    // Ensure position is not negative
    scrollPosition = Math.max(0, scrollPosition);
    
    // Calculate max scroll position to prevent overscroll
    let maxScroll = 0;
    const trackElement = this.versesContainer.nativeElement.querySelector('.verses-track');
    if (trackElement) {
      maxScroll = Math.max(0, trackElement.scrollWidth - containerWidth);
      // Bound the position
      scrollPosition = Math.min(scrollPosition, maxScroll);
    }
    
    console.log(`[InteractiveLessonComponent] Snapping to verse ${index} with transform: translateX(${scrollPosition}px)`);
    
    // Update state
    this.state = {
      ...this.state,
      scrollPosition: scrollPosition,
      currentVerseIndex: index
    };
  
    // Apply transform to DOM (with RTL adjustment)
    if (trackElement instanceof HTMLElement) {
      // For RTL layout, we use positive translateX values
      trackElement.style.transform = `translateX(${scrollPosition}px)`;
      console.log(`[InteractiveLessonComponent] Applied transform: ${trackElement.style.transform}`);
    }
  
    // Update service state if needed
    if (this.state.currentVerseIndex !== index) {
      this.interactiveService.snapToVerse(index);
    }
    
    // Reset snap scrolling flag after animation
    setTimeout(() => {
      this.isSnapScrolling = false;
    }, this.SNAP_ANIMATION_DURATION);
  }
  

  // Scroll to the next verse
  scrollToNextVerse(): void {
    if (this.isSnapScrolling || this.isNavigating) return;

    // In RTL, "next" verse is actually higher index (scrolling left in the UI)
    if (this.state.currentVerseIndex < this.verses.length - 1) {
      this.isSnapScrolling = true;
      const nextIndex = this.state.currentVerseIndex + 1;

      console.log(`[InteractiveLessonComponent] Scrolling to next verse: ${nextIndex}`);
      this.snapToVerse(nextIndex);

      // Reset snap scrolling flag after animation completes
      setTimeout(() => {
        this.isSnapScrolling = false;
      }, this.SNAP_ANIMATION_DURATION);
    }
  }

  scrollToPreviousVerse(): void {
    if (this.isSnapScrolling || this.isNavigating) return;

    // In RTL, "previous" verse is actually lower index (scrolling right in the UI)
    if (this.state.currentVerseIndex > 0) {
      this.isSnapScrolling = true;
      const prevIndex = this.state.currentVerseIndex - 1;

      console.log(`[InteractiveLessonComponent] Scrolling to previous verse: ${prevIndex}`);
      this.snapToVerse(prevIndex);

      // Reset snap scrolling flag after animation completes
      setTimeout(() => {
        this.isSnapScrolling = false;
      }, this.SNAP_ANIMATION_DURATION);
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
  async toggleRecording(event?: Event): Promise<void> {
    // Stop event propagation to prevent triggering other interactions
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }

    console.log('[InteractiveLessonComponent] Toggle recording called');

    if (!this.hasStartedLesson) {
      this.hasStartedLesson = true;
    }

    try {
      if (this.state.isRecording) {
        console.log('[InteractiveLessonComponent] Stopping recording');
        await this.interactiveService.stopRecording();
        await this.platformService.vibrateSuccess();
      } else {
        console.log('[InteractiveLessonComponent] Starting recording');
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
      console.error('[InteractiveLessonComponent] Recording error:', error);
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
    console.log('[InteractiveLessonComponent] Component destroying');
    // Clean up all subscriptions
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.destroy$.unsubscribe();

    // First make sure recording is stopped if active
    if (this.state.isRecording) {
      this.interactiveService.stopRecording().catch(error => {
        console.error('[InteractiveLessonComponent] Error stopping recording during destroy:', error);
      });
    }

    // Call destroy instead of just resetState to properly clean up resources
    this.interactiveService.destroy();

    // Disconnect resize observer
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
      this.resizeObserver = null;
    }
  }
}