// interactive-lesson.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { InteractionState, TajweedVerse } from './interactive-lesson.types';
import { Capacitor } from '@capacitor/core';
import { PlatformService } from '../../../core/services/platform.service';

@Injectable({
  providedIn: 'root'
})
export class InteractiveLessonService {
  // Configuration Constants
  private readonly VERSE_WIDTH = 500; // Base width of verse in pixels
  private readonly FEEDBACK_DURATION = 2000; // ms to display feedback messages
  private readonly MOCK_SUCCESS_RATE = 0.85; // Increased success rate for better UX
  private readonly WORD_RECOGNITION_DELAY = 700; // ms delay between word recognitions
  private readonly VERSE_COMPLETION_THRESHOLD = 0.85; // 85% of words need to be recognized to complete verse

  // State Management
  private state = new BehaviorSubject<InteractionState>({
    currentVerseIndex: 0,
    answers: new Map(),
    score: 0,
    isCompleted: false,
    progress: 0,
    scrollPosition: 0,
    feedback: undefined,
    isRecording: false,
    currentAudio: undefined,
    currentWordIndex: 0,
    recognizedWords: new Set<number>()
  });

  // Media recording properties
  private mediaRecorder?: MediaRecorder;
  private audioChunks: Blob[] = [];
  private verses: TajweedVerse[] = [];
  private recognitionTimer?: number;
  private totalWordCount = 0;
  private destroyInProgress = false;

  constructor(private platformService: PlatformService) {
    console.log('[InteractiveLessonService] Service initialized');
  }

  /**
   * Sets the verses for the interactive lesson and initializes state
   */
  setVerses(verses: TajweedVerse[]): void {
    console.log('[InteractiveLessonService] Setting verses:', verses);
    this.verses = verses;
    this.totalWordCount = this.calculateTotalWordCount();
    console.log(`[InteractiveLessonService] Total word count: ${this.totalWordCount}`);

    // Reset state when new verses are set
    this.resetState();
  }

  /**
   * Calculates the total number of words across all verses
   */
  private calculateTotalWordCount(): number {
    return this.verses.reduce((total, verse) => {
      const wordCount = this.splitVerseIntoWords(verse.text).length;
      console.log(`[InteractiveLessonService] Verse has ${wordCount} words: "${verse.text.substring(0, 30)}..."`);
      return total + wordCount;
    }, 0);
  }

  /**
   * Gets the current interaction state as an observable
   */
  getState(): Observable<InteractionState> {
    return this.state.asObservable();
  }

  /**
   * Snaps the view to a specific verse and updates current verse index
   * This should NOT trigger navigation to a new lesson, only update the internal state
   */
  snapToVerse(verseIndex: number): void {
    // Update the internal state with the new verse index
    // But don't try to calculate scroll position here - let the component handle it
    console.log(`[InteractiveLessonService] Updating to verse index: ${verseIndex}`);
    
    this.state.next({
      ...this.state.value,
      currentVerseIndex: verseIndex,
      feedback: undefined
    });
  }

  /**
   * Completes the current verse and advances to the next if available
   */
  async completeCurrentVerse(): Promise<void> {
    const currentState = this.state.value;
    const currentVerseIndex = currentState.currentVerseIndex;

    console.log(`[InteractiveLessonService] Completing verse ${currentVerseIndex}`);

    // Mark the current verse as completed in answers map
    const newAnswers = new Map(currentState.answers);
    newAnswers.set(currentVerseIndex.toString(), true);

    // Calculate progress based on completed verses
    const progress = Math.min(100, Math.round((newAnswers.size / this.verses.length) * 100));
    const isLessonComplete = newAnswers.size >= this.verses.length;

    // Show completion feedback
    await this.showFeedback(isLessonComplete ? 'أحسنت! أكملت الدرس' : 'أحسنت!');

    // Update state with completion info
    this.state.next({
      ...currentState,
      answers: newAnswers,
      progress: progress,
      isCompleted: isLessonComplete
    });

    // Provide haptic feedback
    try {
      await this.platformService.vibrateSuccess();
    } catch (error) {
      console.warn('[InteractiveLessonService] Haptic feedback not available:', error);
    }

    // Move to next verse if not already completed
    if (!isLessonComplete && currentVerseIndex < this.verses.length - 1) {
      const nextVerseIndex = currentVerseIndex + 1;
      console.log(`[InteractiveLessonService] Moving to next verse ${nextVerseIndex}`);

      // Allow feedback to display before changing verse
      setTimeout(() => {
        if (!this.destroyInProgress) {
          // Update the verse index - let component handle scroll
          this.snapToVerse(nextVerseIndex);

          // Reset recognized words for the new verse
          // This ensures a clean state for the next verse
          const newRecognizedWords = new Set(currentState.recognizedWords);
          
          // Update state with reset for new verse
          this.state.next({
            ...this.state.value,
            currentWordIndex: this.getGlobalWordIndex(nextVerseIndex, 0),
            recognizedWords: newRecognizedWords
          });

          // If still recording, continue word recognition on the new verse
          if (this.state.value.isRecording) {
            console.log(`[InteractiveLessonService] Starting word recognition for verse ${nextVerseIndex}`);
            this.startWordRecognition(nextVerseIndex);
          }
        }
      }, this.FEEDBACK_DURATION);
    } else if (isLessonComplete) {
      console.log('[InteractiveLessonService] Lesson completed!');
    }
  }

  /**
   * Shows feedback message for a specified duration
   */
  async showFeedback(message: string): Promise<void> {
    console.log(`[InteractiveLessonService] Showing feedback: "${message}"`);
    // Update state with feedback message
    this.state.next({
      ...this.state.value,
      feedback: message
    });

    // Clear feedback after duration
    setTimeout(() => {
      // Only clear if this is still the current feedback message
      if (this.state.value.feedback === message && !this.destroyInProgress) {
        console.log('[InteractiveLessonService] Clearing feedback');
        this.state.next({
          ...this.state.value,
          feedback: undefined
        });
      }
    }, this.FEEDBACK_DURATION);
  }

  /**
   * Starts the mock word recognition process for the current verse
   */
  private startWordRecognition(verseIndex: number = this.state.value.currentVerseIndex): void {
    if (!this.verses || this.verses.length === 0 || this.destroyInProgress) {
      console.error('[InteractiveLessonService] No verses available for recognition');
      return;
    }

    // Clear any existing recognition process
    if (this.recognitionTimer) {
      clearTimeout(this.recognitionTimer);
    }

    const verse = this.verses[verseIndex];
    if (!verse) {
      console.error(`[InteractiveLessonService] No verse found at index ${verseIndex}`);
      return;
    }

    const words = this.splitVerseIntoWords(verse.text);
    console.log(`[InteractiveLessonService] Starting word recognition for verse ${verseIndex} with ${words.length} words`);

    // Start with first word in verse if not already set
    const startWordIndex = 0;
    const globalWordIndex = this.getGlobalWordIndex(verseIndex, startWordIndex);

    // Update state to show current word
    this.state.next({
      ...this.state.value,
      currentWordIndex: globalWordIndex
    });

    // Start recognition process
    this.recognizeNextWord(verseIndex, startWordIndex);
  }

  /**
   * Recursively recognizes words in the current verse
   */
  private recognizeNextWord(verseIndex: number, localWordIndex: number): void {
    if (!this.state.value.isRecording || this.destroyInProgress) {
      console.log('[InteractiveLessonService] Recognition stopped: No longer recording or being destroyed');
      return;
    }

    const verse = this.verses[verseIndex];
    if (!verse) {
      console.error(`[InteractiveLessonService] No verse found at index ${verseIndex}`);
      return;
    }

    const words = this.splitVerseIntoWords(verse.text);

    // Check if we've processed all words in this verse
    if (localWordIndex >= words.length) {
      console.log(`[InteractiveLessonService] All words processed in verse ${verseIndex}`);
      
      // Complete verse if we've recognized enough words
      const recognizedCount = this.countRecognizedWordsInVerse(verseIndex);
      const completionPercentage = recognizedCount / words.length;
      console.log(`[InteractiveLessonService] Verse completion: ${completionPercentage.toFixed(2)} (${recognizedCount}/${words.length} words)`);

      if (completionPercentage >= this.VERSE_COMPLETION_THRESHOLD) {
        console.log(`[InteractiveLessonService] Verse ${verseIndex} recognition threshold met, completing verse`);
        this.completeCurrentVerse();
      } else {
        // Not enough words recognized, show feedback
        console.log(`[InteractiveLessonService] Not enough words recognized, retry verse ${verseIndex}`);
        this.showFeedback('حاول نطق الكلمات بوضوح أكثر');

        // Reset to start of verse and try again
        setTimeout(() => {
          if (!this.destroyInProgress && this.state.value.isRecording) {
            this.startWordRecognition(verseIndex);
          }
        }, this.WORD_RECOGNITION_DELAY);
      }
      return;
    }

    // Calculate global word index
    const globalWordIndex = this.getGlobalWordIndex(verseIndex, localWordIndex);
    console.log(`[InteractiveLessonService] Processing word ${localWordIndex} (global: ${globalWordIndex}): "${words[localWordIndex]}"`);

    // Update current word index
    this.state.next({
      ...this.state.value,
      currentWordIndex: globalWordIndex
    });

    // Simulate word recognition with success probability
    const isRecognized = Math.random() < this.MOCK_SUCCESS_RATE;

    // Schedule next word processing
    this.recognitionTimer = window.setTimeout(() => {
      if (!this.state.value.isRecording || this.destroyInProgress) return;

      if (isRecognized) {
        console.log(`[InteractiveLessonService] Word "${words[localWordIndex]}" recognized`);
        // Mark word as recognized
        const newRecognizedWords = new Set(this.state.value.recognizedWords);
        newRecognizedWords.add(globalWordIndex);

        // Calculate overall progress
        const totalProgress = Math.min(
          this.state.value.progress,
          Math.round((newRecognizedWords.size / this.totalWordCount) * 100)
        );

        // Update state with recognized word
        this.state.next({
          ...this.state.value,
          recognizedWords: newRecognizedWords,
          progress: Math.max(totalProgress, this.state.value.progress)
        });

        // Process next word
        this.recognizeNextWord(verseIndex, localWordIndex + 1);
      } else {
        console.log(`[InteractiveLessonService] Word "${words[localWordIndex]}" not recognized, retry`);
        // Failed recognition, show feedback
        this.showFeedback('حاول مرة أخرى');

        // Retry same word after delay
        setTimeout(() => {
          if (!this.destroyInProgress && this.state.value.isRecording) {
            this.recognizeNextWord(verseIndex, localWordIndex);
          }
        }, this.WORD_RECOGNITION_DELAY);
      }
    }, this.WORD_RECOGNITION_DELAY);
  }

  /**
   * Count recognized words in a specific verse
   */
  private countRecognizedWordsInVerse(verseIndex: number): number {
    if (!this.verses[verseIndex]) return 0;

    const words = this.splitVerseIntoWords(this.verses[verseIndex].text);
    let count = 0;

    for (let i = 0; i < words.length; i++) {
      const globalIndex = this.getGlobalWordIndex(verseIndex, i);
      if (this.state.value.recognizedWords!.has(globalIndex)) {
        count++;
      }
    }

    return count;
  }

  /**
   * Starts the recording process
   */
  async startRecording(): Promise<void> {
    try {
      // Clear previous recognition if any
      if (this.recognitionTimer) {
        clearTimeout(this.recognitionTimer);
      }

      console.log('[InteractiveLessonService] Starting recording');
      // Start device recording
      if (Capacitor.isNativePlatform()) {
        await this.platformService.startRecording();
      } else {
        // Web implementation
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        this.mediaRecorder = new MediaRecorder(stream);
        this.audioChunks = [];

        this.mediaRecorder.addEventListener('dataavailable', (event) => {
          this.audioChunks.push(event.data);
        });

        this.mediaRecorder.start();
        console.log('[InteractiveLessonService] Web MediaRecorder started');
      }

      // Update recording state
      this.state.next({
        ...this.state.value,
        isRecording: true,
        feedback: undefined
      });

      // Start word recognition process
      this.startWordRecognition();

    } catch (error) {
      console.error('[InteractiveLessonService] Recording error:', error);
      this.showFeedback('عذراً، لا يمكن بدء التسجيل');
      throw error;
    }
  }

  /**
   * Stops the recording process
   */
  async stopRecording(): Promise<string> {
    try {
      console.log('[InteractiveLessonService] Stopping recording');
      // Clear any ongoing recognition
      if (this.recognitionTimer) {
        clearTimeout(this.recognitionTimer);
        this.recognitionTimer = undefined;
      }

      let audioUrl: string;

      // Stop device recording
      if (Capacitor.isNativePlatform()) {
        const recording = await this.platformService.stopRecording();
        audioUrl = `data:${recording.value.mimeType};base64,${recording.value.recordDataBase64}`;
        console.log('[InteractiveLessonService] Native recording stopped');
      } else {
        // Web implementation
        if (!this.mediaRecorder) {
          throw new Error('No recording in progress');
        }

        audioUrl = await new Promise<string>((resolve, reject) => {
          this.mediaRecorder!.addEventListener('stop', () => {
            const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' });
            resolve(URL.createObjectURL(audioBlob));
          });

          this.mediaRecorder!.stop();
          this.mediaRecorder!.stream.getTracks().forEach(track => track.stop());
        });
        console.log('[InteractiveLessonService] Web recording stopped');
      }

      // Update state with recording stopped
      this.state.next({
        ...this.state.value,
        isRecording: false,
        currentAudio: audioUrl
      });

      return audioUrl;
    } catch (error) {
      console.error('[InteractiveLessonService] Error stopping recording:', error);

      // Update state even in case of error
      this.state.next({
        ...this.state.value,
        isRecording: false
      });

      throw error;
    }
  }

  /**
   * Utility method to split verse text into words
   */
  private splitVerseIntoWords(text: string): string[] {
    if (!text) return [];
    return text.trim().split(/\s+/).filter(Boolean);
  }

  /**
   * Converts local word index to global word index
   */
  private getGlobalWordIndex(verseIndex: number, wordInVerse: number): number {
    let totalWords = 0;
    for (let i = 0; i < verseIndex && i < this.verses.length; i++) {
      totalWords += this.splitVerseIntoWords(this.verses[i].text).length;
    }
    return totalWords + wordInVerse;
  }

  /**
   * Resets the state to initial values
   */
  resetState(): void {
    console.log('[InteractiveLessonService] Resetting state');
    // Clear ongoing recognitions
    if (this.recognitionTimer) {
      clearTimeout(this.recognitionTimer);
      this.recognitionTimer = undefined;
    }

    // Release current audio URL if exists
    if (this.state.value.currentAudio) {
      URL.revokeObjectURL(this.state.value.currentAudio);
    }

    // Reset to initial state
    this.state.next({
      currentVerseIndex: 0,
      answers: new Map(),
      score: 0,
      isCompleted: false,
      progress: 0,
      scrollPosition: 0,
      feedback: undefined,
      isRecording: false,
      currentAudio: undefined,
      currentWordIndex: 0,
      recognizedWords: new Set()
    });
  }

  /**
   * Clean up resources when service is destroyed
   */
  destroy(): void {
    console.log('[InteractiveLessonService] Destroying service');
    this.destroyInProgress = true;

    // Clear any ongoing processes
    if (this.recognitionTimer) {
      clearTimeout(this.recognitionTimer);
      this.recognitionTimer = undefined;
    }

    // Stop recording if in progress
    if (this.state.value.isRecording) {
      if (Capacitor.isNativePlatform()) {
        this.platformService.stopRecording().catch(e =>
          console.error('[InteractiveLessonService] Error stopping recording during destroy:', e)
        );
      } else if (this.mediaRecorder && this.mediaRecorder.state !== 'inactive') {
        this.mediaRecorder.stop();
        this.mediaRecorder.stream.getTracks().forEach(track => track.stop());
        console.log('[InteractiveLessonService] Web recording stopped during destroy');
      }
    }

    // Release audio resources
    if (this.state.value.currentAudio) {
      URL.revokeObjectURL(this.state.value.currentAudio);
    }

    // Clear references
    this.verses = [];
    this.audioChunks = [];
    this.mediaRecorder = undefined;
  }
}