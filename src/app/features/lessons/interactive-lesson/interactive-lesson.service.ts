// src/app/features/lessons/interactive-lesson/interactive-lesson.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { InteractionState, InteractiveQuestion, InteractionResult } from './interactive-lesson.types';

@Injectable({
  providedIn: 'root'
})
export class InteractiveLessonService {
  private state = new BehaviorSubject<InteractionState>({
    currentQuestionIndex: 0,
    answers: new Map(),
    score: 0,
    isCompleted: false,
    progress: 0
  });

  private mediaRecorder?: MediaRecorder;
  private audioChunks: Blob[] = [];

  constructor() {}

  getState(): Observable<InteractionState> {
    return this.state.asObservable();
  }

  submitAnswer(question: InteractiveQuestion, answer: string | boolean): InteractionResult {
    const currentState = this.state.value;
    const isCorrect = answer === question.correctAnswer;
    
    // Update answers map
    currentState.answers.set(question.id, answer);

    // Calculate new score and progress
    const totalQuestions = currentState.answers.size;
    const correctAnswers = Array.from(currentState.answers.entries())
      .filter(([id, ans]) => {
        const q = question; // In real app, you'd find the question by id
        return ans === q.correctAnswer;
      }).length;

    const newState = {
      ...currentState,
      score: (correctAnswers / totalQuestions) * 100,
      progress: (totalQuestions / currentState.answers.size) * 100,
      feedback: isCorrect ? 'أحسنت!' : 'حاول مرة أخرى'
    };

    this.state.next(newState);

    return {
      questionId: question.id,
      userAnswer: answer,
      isCorrect,
      explanation: question.explanation
    };
  }

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
        isRecording: true
      });
    } catch (error) {
      console.error('Error starting recording:', error);
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

  nextQuestion(): void {
    const currentState = this.state.value;
    
    // Clear any existing audio
    if (currentState.currentAudio) {
      URL.revokeObjectURL(currentState.currentAudio);
    }

    this.state.next({
      ...currentState,
      currentQuestionIndex: currentState.currentQuestionIndex + 1,
      currentAudio: undefined,
      feedback: undefined
    });
  }

  previousQuestion(): void {
    const currentState = this.state.value;
    
    if (currentState.currentAudio) {
      URL.revokeObjectURL(currentState.currentAudio);
    }

    this.state.next({
      ...currentState,
      currentQuestionIndex: Math.max(0, currentState.currentQuestionIndex - 1),
      currentAudio: undefined,
      feedback: undefined
    });
  }

  completeLesson(): void {
    this.state.next({
      ...this.state.value,
      isCompleted: true,
      progress: 100
    });
  }

  resetState(): void {
    // Clean up any existing audio URLs
    const currentState = this.state.value;
    if (currentState.currentAudio) {
      URL.revokeObjectURL(currentState.currentAudio);
    }

    this.state.next({
      currentQuestionIndex: 0,
      answers: new Map(),
      score: 0,
      isCompleted: false,
      progress: 0
    });
  }
}