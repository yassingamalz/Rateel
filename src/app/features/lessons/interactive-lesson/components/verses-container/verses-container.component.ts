import {
  Component,
  Input,
  Output,
  ViewChild,
  ElementRef,
  EventEmitter,
  OnInit,
  OnChanges,
  OnDestroy,
  AfterViewInit,
  SimpleChanges,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  NgZone
} from '@angular/core';
import { TajweedVerse } from '../../interactive-lesson.types';
import { timer, Subscription } from 'rxjs';

@Component({
  selector: 'app-verses-container',
  standalone: false,
  templateUrl: './verses-container.component.html',
  styleUrls: ['./verses-container.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class VersesContainerComponent implements OnInit, OnChanges, AfterViewInit, OnDestroy {
  @ViewChild('versesContainer') versesContainer!: ElementRef<HTMLElement>;
  @ViewChild('versesTrack') versesTrack?: ElementRef<HTMLElement>;

  @Input() verses: TajweedVerse[] = [];
  @Input() currentVerseIndex = 0;
  @Input() currentWordIndex?: number;
  @Input() recognizedWords: Set<number> = new Set<number>();

  @Output() verseChange = new EventEmitter<number>();
  
  // UI state variables
  isDragging = false;
  isSnapScrolling = false;
  startX = 0;
  startScrollPosition = 0;
  scrollPosition = 0;
  containerWidth = 0;
  totalContentWidth = 0;
  lastDragTimestamp = 0;
  lastDragDirection = 0;
  dragVelocity = 0;
  verseElements: HTMLElement[] = [];
  resizeObserver: ResizeObserver | null = null;

  // Animation timers
  private readonly SNAP_ANIMATION_DURATION = 500; // ms
  private readonly DEBOUNCE_TIME = 150; // ms for resize events

  // Constants for inertia
  private readonly INERTIA_FACTOR = 0.92;
  private readonly MIN_DRAG_VELOCITY = 0.5;
  private readonly MAX_INERTIA_DURATION = 1000; // ms

  private subscriptions: Subscription[] = [];

  constructor(
    private cdr: ChangeDetectorRef,
    private ngZone: NgZone
  ) {}

  ngOnInit(): void {
    this.setupResizeObserver();
  }

  ngOnChanges(changes: SimpleChanges): void {
    // React to current verse index changes
    if (changes['currentVerseIndex'] && !this.isDragging && !this.isSnapScrolling) {
      this.snapToVerse(this.currentVerseIndex);
    }
  }

  ngAfterViewInit(): void {
    // Initialize dimensions immediately to avoid flicker
    this.initializeContainerDimensions();
    this.cacheVerseElements();

    // Initialize scroll position with a slight delay to ensure DOM is fully rendered
    setTimeout(() => {
      // Ensure we have valid container dimensions
      this.initializeContainerDimensions();
      // Snap to initial verse
      this.snapToVerse(this.currentVerseIndex);

      this.cdr.detectChanges();
    }, 300);
  }

  ngOnDestroy(): void {
    // Clean up subscriptions
    this.subscriptions.forEach(sub => sub.unsubscribe());

    // Disconnect resize observer
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
      this.resizeObserver = null;
    }
  }

  // Mouse Event Handlers
  onMouseDown(event: MouseEvent): void {
    if (this.isSnapScrolling) return;

    this.isDragging = true;
    this.startX = event.pageX;
    this.startScrollPosition = this.scrollPosition;
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

    // Update scroll position
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

  // Touch Event Handlers
  onTouchStart(event: TouchEvent): void {
    if (this.isSnapScrolling) return;

    this.isDragging = true;
    this.startX = event.touches[0].pageX;
    this.startScrollPosition = this.scrollPosition;
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

    // Update scroll position
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

  // Navigation Methods
  scrollToNextVerse(): void {
    if (this.isSnapScrolling) return;

    // In RTL, "next" verse is actually higher index (scrolling left in the UI)
    if (this.currentVerseIndex < this.verses.length - 1) {
      this.isSnapScrolling = true;
      const nextIndex = this.currentVerseIndex + 1;

      this.snapToVerse(nextIndex);
      
      // Emit the verse change event
      this.verseChange.emit(nextIndex);

      // Reset snap scrolling flag after animation completes
      setTimeout(() => {
        this.isSnapScrolling = false;
      }, this.SNAP_ANIMATION_DURATION);
    }
  }

  scrollToPreviousVerse(): void {
    if (this.isSnapScrolling) return;

    // In RTL, "previous" verse is actually lower index (scrolling right in the UI)
    if (this.currentVerseIndex > 0) {
      this.isSnapScrolling = true;
      const prevIndex = this.currentVerseIndex - 1;

      this.snapToVerse(prevIndex);
      
      // Emit the verse change event
      this.verseChange.emit(prevIndex);

      // Reset snap scrolling flag after animation completes
      setTimeout(() => {
        this.isSnapScrolling = false;
      }, this.SNAP_ANIMATION_DURATION);
    }
  }

  // Visibility Checks for UI
  canScrollLeft(): boolean {
    return this.currentVerseIndex > 0;
  }

  canScrollRight(): boolean {
    return this.currentVerseIndex < this.verses.length - 1;
  }

  // Helper Methods
  isVerseActive(index: number): boolean {
    return this.currentVerseIndex === index;
  }

  isVerseCompleted(index: number): boolean {
    // We can't directly know if a verse is completed based on the inputs
    // This would need to be determined by the parent component or service
    // For now, let's assume a verse is completed if all its words are recognized
    const verse = this.verses[index];
    if (!verse) return false;
    
    const words = this.splitVerseIntoWords(verse.text);
    let recognizedCount = 0;

    // Count recognized words
    for (let i = 0; i < words.length; i++) {
      if (this.isWordSpoken(index, i)) {
        recognizedCount++;
      }
    }

    // Calculate completion percentage - 85% threshold for completion
    return words.length > 0 ? (recognizedCount / words.length) >= 0.85 : false;
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

  isWordSpoken(verseIndex: number, wordIndex: number): boolean {
    if (!this.recognizedWords) return false;

    // Get global word index
    const globalIndex = this.getGlobalWordIndex(verseIndex, wordIndex);
    return this.recognizedWords.has(globalIndex);
  }

  getGlobalWordIndex(verseIndex: number, wordIndex: number): number {
    let globalIndex = wordIndex;

    // Add the word counts of all previous verses
    for (let i = 0; i < verseIndex && i < this.verses.length; i++) {
      const verseText = this.verses[i]?.text || '';
      globalIndex += this.splitVerseIntoWords(verseText).length;
    }

    return globalIndex;
  }

  splitVerseIntoWords(text: string): string[] {
    if (!text) return [];
    return text.trim().split(/\s+/).filter(Boolean);
  }

  // Private Helper Methods
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
          this.snapToVerse(this.currentVerseIndex);
        }
      });
    });

    // Observe the container after view init
    setTimeout(() => {
      if (this.versesContainer) {
        this.resizeObserver?.observe(this.versesContainer.nativeElement);
      }
    });
  }

  private updateDeviceState(): void {
    // Could implement device-specific state updates here if needed
  }

  private cacheVerseElements(): void {
    if (this.versesContainer) {
      this.verseElements = Array.from(
        this.versesContainer.nativeElement.querySelectorAll('.verse-card')
      );
    }
  }

  private initializeContainerDimensions(): void {
    if (!this.versesContainer || !this.verses.length) return;

    const container = this.versesContainer.nativeElement;
    this.containerWidth = container.clientWidth;

    // Calculate total content width directly from DOM
    this.totalContentWidth = this.calculateTotalContentWidth();
  }

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

    // Update scrollPosition
    this.scrollPosition = boundedPosition;

    // Apply transformation directly to DOM
    if (trackElement instanceof HTMLElement) {
      // For RTL layout, we use positive translateX values
      trackElement.style.transform = `translateX(${boundedPosition}px)`;
    }

    // Update UI
    this.cdr.detectChanges();
  }

  private applyInertia(): void {
    const initialVelocity = this.dragVelocity;
    const startTime = Date.now();
    const startPosition = this.scrollPosition;
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

  private snapToNearestVerse(): void {
    if (!this.versesContainer || this.verses.length === 0) return;

    const containerWidth = this.versesContainer.nativeElement.clientWidth;
    const containerCenter = containerWidth / 2;
    const currentScrollPos = this.scrollPosition;

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
    this.snapToVerse(nearestIndex);
    
    // Emit the verse change event
    if (this.currentVerseIndex !== nearestIndex) {
      this.verseChange.emit(nearestIndex);
    }
  }

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
    const containerCenter = containerWidth / 2;
    
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
      
      // Center adjustment: subtract half container width, add half verse width
      scrollPosition -= containerCenter; 
      scrollPosition += currentVerse.offsetWidth / 2;
      
      // Apply minor centering adjustment if needed
      scrollPosition += 100; // This can be tuned for better positioning
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
    
    // Update scrollPosition state
    this.scrollPosition = scrollPosition;
  
    // Apply transform to DOM (with RTL adjustment)
    if (trackElement instanceof HTMLElement) {
      // For RTL layout, we use positive translateX values
      trackElement.style.transform = `translateX(${scrollPosition}px)`;
    }
    
    // Reset snap scrolling flag after animation
    setTimeout(() => {
      this.isSnapScrolling = false;
    }, this.SNAP_ANIMATION_DURATION);
    
    // Update UI
    this.cdr.detectChanges();
  }
}