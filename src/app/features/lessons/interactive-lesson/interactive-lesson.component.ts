// interactive-lesson.component.ts
import {
  Component,
  Input,
  Output,
  EventEmitter,
  OnInit,
  OnDestroy,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  NgZone
} from '@angular/core';
import { InteractiveLessonService } from './interactive-lesson.service';
import { TajweedVerse, InteractionState } from './interactive-lesson.types';
import { Subscription } from 'rxjs';
import { Capacitor } from '@capacitor/core';
import { PlatformService } from '../../../core/services/platform.service';
import { ThemeService } from '../../../shared/services/theme.service';

@Component({
  selector: 'app-interactive-lesson',
  standalone: false,
  templateUrl: './interactive-lesson.component.html',
  styleUrls: ['./interactive-lesson.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class InteractiveLessonComponent implements OnInit, OnDestroy {
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
  hasStartedLesson = false;
  isNavigating = false;

  // Theme property
  currentTheme: string = 'theme-dark';

  private subscriptions: Subscription[] = [];
  private destroy$ = new Subscription();

  constructor(
    private interactiveService: InteractiveLessonService,
    private platformService: PlatformService,
    private cdr: ChangeDetectorRef,
    private ngZone: NgZone,
    private themeService: ThemeService
  ) { }

  ngOnInit(): void {
    // Initialize UI and device state
    this.updateDeviceState();

    // Subscribe to theme changes
    this.subscriptions.push(
      this.themeService.theme$.subscribe(theme => {
        this.currentTheme = `theme-${theme}`;
        console.log(`[InteractiveLessonComponent] Theme updated to: ${this.currentTheme}`);
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

            // Update state
            this.state = { ...state };

            // Update progress
            this.onProgress.emit(state.progress);

            // Check for completion
            if (state.isCompleted && !this.isCompleted) {
              console.log('[InteractiveLessonComponent] Lesson completed, triggering completion handler');
              this.handleCompletion();
            }

            this.cdr.markForCheck();
          },
          error: (error) => console.error('[InteractiveLessonComponent] State subscription error:', error)
        })
      );
    }
  }

  // Handle verse change from the verses-container component
  onVerseChange(verseIndex: number): void {
    console.log(`[InteractiveLessonComponent] Verse changed to: ${verseIndex}`);
    if (verseIndex !== this.state.currentVerseIndex) {
      this.interactiveService.snapToVerse(verseIndex);
    }
  }

  // Used to toggle theme
  toggleTheme(): void {
    const newTheme = this.currentTheme === 'theme-light' ? 'dark' : 'light';
    console.log(`[InteractiveLessonComponent] Toggling theme to: ${newTheme}`);
    this.themeService.setTheme(newTheme);
  }

  // Handle completion event
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

  private updateDeviceState(): void {
    // Check device state - typically would set flags for 
    // mobile/desktop, orientation, etc.
    console.log(`[InteractiveLessonComponent] Device platform: ${Capacitor.getPlatform()}`);
  }

  // Recording Controls
  async toggleRecording(): Promise<void> {
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
  }
}