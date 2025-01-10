// interactive-lesson.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { InteractionState, TajweedVerse } from './interactive-lesson.types';

@Injectable({
  providedIn: 'root'
})
export class InteractiveLessonService {
  private readonly VERSE_WIDTH = 500; // Match with SCSS card width
  private readonly FEEDBACK_DELAY = 1000; // Time to show feedback before moving
  
  private state = new BehaviorSubject<InteractionState>({
    currentVerseIndex: 0,
    answers: new Map(),
    score: 0,
    isCompleted: false,
    progress: 0,
    scrollPosition: 0,
    feedback: undefined,
    isRecording: false,
    currentAudio: undefined
  });

  private mediaRecorder?: MediaRecorder;
  private audioChunks: Blob[] = [];

  getState(): Observable<InteractionState> {
    return this.state.asObservable();
  }

  updateScrollPosition(position: number, containerWidth: number, totalContentWidth: number): void {
    // Flip the min/max for RTL
    const minScroll = 0;
    const maxScroll = totalContentWidth - containerWidth;
    
    const boundedPosition = Math.min(maxScroll, Math.max(minScroll, position));
    const nearestVerseIndex = Math.round(boundedPosition / this.VERSE_WIDTH);
    
    this.state.next({
      ...this.state.value,
      scrollPosition: boundedPosition,
      currentVerseIndex: nearestVerseIndex,
      feedback: undefined
    });
  }
  
  snapToVerse(verseIndex: number): void {
    // Update position calculation for RTL
    const newPosition = verseIndex * this.VERSE_WIDTH;
    
    this.state.next({
      ...this.state.value,
      scrollPosition: newPosition,
      currentVerseIndex: verseIndex,
      feedback: undefined
    });
  }
  // Recording Functions
  async startRecording(): Promise<void> {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      this.mediaRecorder = new MediaRecorder(stream);
      this.audioChunks = [];

      this.mediaRecorder.addEventListener('dataavailable', (event) => {
        this.audioChunks.push(event.data);
      });

      this.mediaRecorder.start();
      this.state.next({
        ...this.state.value,
        isRecording: true,
        feedback: undefined
      });
    } catch (error) {
      this.showFeedback('عذراً، لا يمكن بدء التسجيل');
      throw error;
    }
  }

  async stopRecording(): Promise<string> {
    return new Promise((resolve, reject) => {
      if (!this.mediaRecorder) {
        reject(new Error('No recording in progress'));
        return;
      }

      this.mediaRecorder.addEventListener('stop', () => {
        const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' });
        const audioUrl = URL.createObjectURL(audioBlob);
        
        this.state.next({
          ...this.state.value,
          isRecording: false,
          currentAudio: audioUrl
        });

        resolve(audioUrl);
      });

      this.mediaRecorder.stop();
      this.mediaRecorder.stream.getTracks().forEach(track => track.stop());
    });
  }

  // Verse management with auto-scrolling
  async completeCurrentVerse(totalVerses: number): Promise<void> {
    const currentState = this.state.value;
    const currentVerse = currentState.currentVerseIndex;
    
    // Update answers and calculate progress
    const newAnswers = new Map(currentState.answers);
    newAnswers.set(currentVerse.toString(), true);
    const progress = (newAnswers.size / totalVerses) * 100;

    // Show success feedback
    this.state.next({
      ...currentState,
      answers: newAnswers,
      progress,
      feedback: 'أحسنت!'
    });

    // Wait for feedback animation
    await new Promise(resolve => setTimeout(resolve, this.FEEDBACK_DELAY));

    // Move to next verse if available
    if (currentVerse < totalVerses - 1) {
      const nextVerseIndex = currentVerse + 1;
      this.snapToVerse(nextVerseIndex);
    } else {
      // Complete the lesson
      this.state.next({
        ...this.state.value,
        isCompleted: true,
        feedback: 'أحسنت! أكملت الدرس'
      });
    }
  }

  showFeedback(message: string): void {
    this.state.next({
      ...this.state.value,
      feedback: message
    });

    // Auto-clear feedback after delay
    setTimeout(() => {
      if (this.state.value.feedback === message) {
        this.state.next({
          ...this.state.value,
          feedback: undefined
        });
      }
    }, this.FEEDBACK_DELAY);
  }

  resetState(): void {
    if (this.state.value.currentAudio) {
      URL.revokeObjectURL(this.state.value.currentAudio);
    }

    this.state.next({
      currentVerseIndex: 0,
      answers: new Map(),
      score: 0,
      isCompleted: false,
      progress: 0,
      scrollPosition: 0,
      feedback: undefined,
      isRecording: false,
      currentAudio: undefined
    });
  }
}