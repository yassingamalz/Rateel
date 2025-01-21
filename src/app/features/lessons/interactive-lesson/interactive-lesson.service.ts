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
  private readonly MOCK_SUCCESS_RATE = 0.8; // Increase success rate
  private readonly MOCK_WORD_DELAY = 800;   // Slightly longer delay for visibility
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

  private mediaRecorder?: MediaRecorder;
  private audioChunks: Blob[] = [];
  private verses: TajweedVerse[] = [];

  constructor(private platformService: PlatformService) { }


  setVerses(verses: TajweedVerse[]): void {
    console.log('Setting verses:', verses);
    this.verses = verses;

    // Reset state when new verses are set
    this.resetState();
  }

  private startMockWordRecognition() {
    if (!this.verses || this.verses.length === 0) {
      console.error('No verses available for recognition');
      return;
    }

    console.log('Starting recognition with verses:', this.verses);
    const currentVerse = this.verses[this.state.value.currentVerseIndex];
    const words = this.splitVerseIntoWords(currentVerse.text);
    let currentWordIndex = 0;

    const recognizeWord = () => {
      if (!this.state.value.isRecording) return;

      const isCorrect = Math.random() < this.MOCK_SUCCESS_RATE;
      console.log('Word recognition attempt:', {
        word: words[currentWordIndex],
        isCorrect,
        currentWordIndex
      });

      if (isCorrect) {
        // Update recognized words
        const newRecognizedWords = new Set(this.state.value.recognizedWords);
        newRecognizedWords.add(currentWordIndex);

        // Update state
        this.state.next({
          ...this.state.value,
          currentWordIndex,
          recognizedWords: newRecognizedWords,
          progress: (newRecognizedWords.size / words.length) * 100
        });

        currentWordIndex++;

        // Schedule next word or complete verse
        if (currentWordIndex < words.length) {
          setTimeout(() => recognizeWord(), this.MOCK_WORD_DELAY);
        } else {
          this.completeCurrentVerse(this.verses.length);
        }
      } else {
        // Retry word
        this.showFeedback('حاول مرة أخرى');
        setTimeout(() => recognizeWord(), this.MOCK_WORD_DELAY);
      }
    };

    // Start recognition process
    recognizeWord();
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
      currentAudio: undefined,
      currentWordIndex: 0,
      recognizedWords: new Set()
    });
  }

  getState(): Observable<InteractionState> {
    return this.state.asObservable();
  }


  async completeCurrentVerse(totalVerses: number): Promise<void> {
    const currentState = this.state.value;
    const currentVerse = currentState.currentVerseIndex;

    const newAnswers = new Map(currentState.answers);
    newAnswers.set(currentVerse.toString(), true);
    const progress = (newAnswers.size / totalVerses) * 100;

    // First update with completion feedback
    this.state.next({
      ...currentState,
      answers: newAnswers,
      progress,
      feedback: 'أحسنت!'
    });

    await new Promise(resolve => setTimeout(resolve, this.FEEDBACK_DELAY));

    if (currentVerse < totalVerses - 1) {
      const nextVerseIndex = currentVerse + 1;

      // Calculate new scroll position for next verse - positive for RTL
      const newScrollPosition = nextVerseIndex * this.VERSE_WIDTH;

      // Update state with new verse and scroll position
      this.state.next({
        ...this.state.value,
        currentVerseIndex: nextVerseIndex,
        scrollPosition: newScrollPosition,
        feedback: undefined,
        currentWordIndex: 0,
        recognizedWords: new Set()
      });

      setTimeout(() => {
        if (this.state.value.isRecording) {
          this.startMockWordRecognition();
        }
      }, this.MOCK_WORD_DELAY);

    } else {
      this.state.next({
        ...this.state.value,
        isCompleted: true,
        feedback: 'أحسنت! أكملت الدرس'
      });
    }
  }

  // Also update snapToVerse method
  snapToVerse(verseIndex: number): void {
    // Positive for RTL direction
    const newPosition = verseIndex * this.VERSE_WIDTH;

    this.state.next({
      ...this.state.value,
      scrollPosition: newPosition,
      currentVerseIndex: verseIndex,
      feedback: undefined
    });
  }

  // And updateScrollPosition method
  updateScrollPosition(position: number, containerWidth: number, totalContentWidth: number): void {
    const minScroll = 0;
    const maxScroll = totalContentWidth - containerWidth;

    // Invert for RTL
    const boundedPosition = Math.max(minScroll, Math.min(maxScroll, position));
    const nearestVerseIndex = Math.round(boundedPosition / this.VERSE_WIDTH);

    this.state.next({
      ...this.state.value,
      scrollPosition: boundedPosition,
      currentVerseIndex: nearestVerseIndex,
      feedback: undefined
    });
  }

  // interactive-lesson.service.ts
  async startRecording(): Promise<void> {
    try {
      if (!this.verses || this.verses.length === 0) {
        console.error('No verses available');
        return;
      }

      // Start device recording
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

      // Update recording state first
      this.state.next({
        ...this.state.value,
        isRecording: true,
        feedback: undefined
      });


      // Start mock word recognition after state is updated

      await this.startMockWordRecognition();

    } catch (error) {
      console.error('Recording error:', error);
      this.showFeedback('عذراً، لا يمكن بدء التسجيل');
      throw error;
    }
  }

  private splitVerseIntoWords(text: string): string[] {
    return text.trim().split(/\s+/).filter(Boolean);
  }

  private getGlobalWordIndex(verseIndex: number, wordInVerse: number): number {
    let totalWords = 0;
    for (let i = 0; i < verseIndex; i++) {
      totalWords += this.splitVerseIntoWords(this.verses[i].text).length;
    }
    return totalWords + wordInVerse;
  }

  private getTotalWords(): number {
    return this.verses.reduce((total, verse) =>
      total + this.splitVerseIntoWords(verse.text).length, 0);
  }
  async stopRecording(): Promise<string> {
    try {
      let audioUrl: string;

      if (Capacitor.isNativePlatform()) {
        const recording = await this.platformService.stopRecording();
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

  async checkPermissions(): Promise<boolean> {
    if (Capacitor.isNativePlatform()) {
      return await this.platformService.initializeMicrophone();
    }
    return true;
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
}