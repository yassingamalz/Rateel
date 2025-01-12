import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { InteractionState, TajweedVerse } from './interactive-lesson.types';
import { Capacitor } from '@capacitor/core';
import { PlatformService } from '../../../core/services/platform.service';

@Injectable({
  providedIn: 'root'
})
export class InteractiveLessonService {
  private readonly VERSE_WIDTH = 500;
  private readonly FEEDBACK_DELAY = 1000;

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

  constructor(private platformService: PlatformService) { }

  getState(): Observable<InteractionState> {
    return this.state.asObservable();
  }

  // Recording Functions
  async startRecording(): Promise<void> {
    try {
      if (Capacitor.isNativePlatform()) {
        await this.platformService.startRecording();
      } else {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        this.mediaRecorder = new MediaRecorder(stream);
        this.audioChunks = [];

        this.mediaRecorder.addEventListener('dataavailable', (event) => {
          this.audioChunks.push(event.data);
        });

        this.mediaRecorder.start();
      }

      this.state.next({
        ...this.state.value,
        isRecording: true,
        feedback: undefined
      });
    } catch (error) {
      console.error('Recording error:', error);
      this.showFeedback('عذراً، لا يمكن بدء التسجيل');
      throw error;
    }
  }

  async stopRecording(): Promise<string> {
    try {
      let audioUrl: string;

      if (Capacitor.isNativePlatform()) {
        const recording = await this.platformService.stopRecording();
        // Create a data URL from the base64 string
        audioUrl = `data:${recording.value.mimeType};base64,${recording.value.recordDataBase64}`;
      } else {
        if (!this.mediaRecorder) {
          throw new Error('No recording in progress');
        }

        audioUrl = await new Promise((resolve, reject) => {
          this.mediaRecorder!.addEventListener('stop', () => {
            const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' });
            resolve(URL.createObjectURL(audioBlob));
          });

          this.mediaRecorder!.stop();
          this.mediaRecorder!.stream.getTracks().forEach(track => track.stop());
        });
      }

      this.state.next({
        ...this.state.value,
        isRecording: false,
        currentAudio: audioUrl
      });

      return audioUrl;
    } catch (error) {
      console.error('Error stopping recording:', error);
      throw error;
    }
  }

  updateScrollPosition(position: number, containerWidth: number, totalContentWidth: number): void {
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
    const newPosition = verseIndex * this.VERSE_WIDTH;

    this.state.next({
      ...this.state.value,
      scrollPosition: newPosition,
      currentVerseIndex: verseIndex,
      feedback: undefined
    });
  }

  async checkPermissions(): Promise<boolean> {
    if (Capacitor.isNativePlatform()) {
      return await this.platformService.initializeMicrophone();
    }
    return true;
  }

  async completeCurrentVerse(totalVerses: number): Promise<void> {
    const currentState = this.state.value;
    const currentVerse = currentState.currentVerseIndex;

    const newAnswers = new Map(currentState.answers);
    newAnswers.set(currentVerse.toString(), true);
    const progress = (newAnswers.size / totalVerses) * 100;

    this.state.next({
      ...currentState,
      answers: newAnswers,
      progress,
      feedback: 'أحسنت!'
    });

    await new Promise(resolve => setTimeout(resolve, this.FEEDBACK_DELAY));

    if (currentVerse < totalVerses - 1) {
      const nextVerseIndex = currentVerse + 1;
      this.snapToVerse(nextVerseIndex);
    } else {
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
      if (!Capacitor.isNativePlatform()) {
        URL.revokeObjectURL(this.state.value.currentAudio);
      }
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