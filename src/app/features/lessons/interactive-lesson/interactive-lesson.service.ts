// src/app/features/lessons/interactive-lesson/interactive-lesson.service.ts
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

  constructor(private platformService: PlatformService) {}

  /**
   * Sets the verses for the interactive lesson and initializes state
   */
  setVerses(verses: TajweedVerse[]): void {
    console.log('[InteractiveLessonService] Setting verses:', verses.length);
    this.verses = verses;
    this.totalWordCount = this.calculateTotalWordCount();
    
    // Reset state when new verses are set
    this.resetState();
  }

  /**
   * Calculates the total number of words across all verses
   */
  private calculateTotalWordCount(): number {
    return this.verses.reduce((total, verse) => 
      total + this.splitVerseIntoWords(verse.text).length, 0);
  }

  /**
   * Gets the current interaction state as an observable
   */
  getState(): Observable<InteractionState> {
    return this.state.asObservable();
  }

  /**
   * Updates the scroll position with bounds checking
   */
  updateScrollPosition(position: number, containerWidth: number, totalContentWidth: number): void {
    // Calculate the bounds with RTL orientation
    const minScroll = -(totalContentWidth - containerWidth);
    const maxScroll = 0;
    
    // Bound position within valid range
    const boundedPosition = Math.max(minScroll, Math.min(maxScroll, position));
    
    // Calculate the nearest verse index based on scroll position
    const nearestVerseIndex = Math.round(Math.abs(boundedPosition) / this.VERSE_WIDTH);
    const validVerseIndex = Math.min(Math.max(0, nearestVerseIndex), this.verses.length - 1);
    
    // Update state with new position and verse index
    this.state.next({
      ...this.state.value,
      scrollPosition: boundedPosition,
      currentVerseIndex: validVerseIndex
    });
  }

  /**
   * Snaps the view to a specific verse
   */
  snapToVerse(verseIndex: number): void {
    // Calculate scroll position based on verse index (for RTL)
    const newPosition = -(verseIndex * this.VERSE_WIDTH);
    
    // Update state with new position and verse index
    this.state.next({
      ...this.state.value,
      scrollPosition: newPosition,
      currentVerseIndex: verseIndex,
      // When changing verses, reset the current word index
      currentWordIndex: this.getGlobalWordIndex(verseIndex, 0)
    });
  }

  /**
   * Completes the current verse and advances to the next if available
   */
  async completeCurrentVerse(): Promise<void> {
    const currentState = this.state.value;
    const currentVerseIndex = currentState.currentVerseIndex;
    
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
      
      // Allow feedback to display before changing verse
      setTimeout(() => {
        if (!this.destroyInProgress) {
          this.snapToVerse(nextVerseIndex);
          
          // If still recording, continue word recognition on the new verse
          if (this.state.value.isRecording) {
            this.startWordRecognition(nextVerseIndex);
          }
        }
      }, this.FEEDBACK_DURATION);
    }
  }

  /**
   * Shows feedback message for a specified duration
   */
  async showFeedback(message: string): Promise<void> {
    // Update state with feedback message
    this.state.next({
      ...this.state.value,
      feedback: message
    });

    // Clear feedback after duration
    setTimeout(() => {
      // Only clear if this is still the current feedback message
      if (this.state.value.feedback === message && !this.destroyInProgress) {
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
    if (!verse) return;
    
    const words = this.splitVerseIntoWords(verse.text);
    
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
    if (!this.state.value.isRecording || this.destroyInProgress) return;
    
    const verse = this.verses[verseIndex];
    if (!verse) return;
    
    const words = this.splitVerseIntoWords(verse.text);
    
    // Check if we've processed all words in this verse
    if (localWordIndex >= words.length) {
      // Complete verse if we've recognized enough words
      const recognizedCount = this.countRecognizedWordsInVerse(verseIndex);
      const completionPercentage = recognizedCount / words.length;
      
      if (completionPercentage >= this.VERSE_COMPLETION_THRESHOLD) {
        this.completeCurrentVerse();
      } else {
        // Not enough words recognized, show feedback
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