import { Component, Input, Output, EventEmitter, OnInit, OnDestroy } from '@angular/core';
import { InteractiveLessonService } from './interactive-lesson.service';
import { InteractiveQuestion, InteractionState, InteractiveLessonProps } from './interactive-lesson.types';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-interactive-lesson',
  standalone: false,
  templateUrl: './interactive-lesson.component.html',
  styleUrls: ['./interactive-lesson.component.scss'],
  providers: [InteractiveLessonService]
})
export class InteractiveLessonComponent implements OnInit, OnDestroy {
  @Input() questions: InteractiveQuestion[] = [];
  @Input() isCompleted?: boolean;

  // Replace EventEmitter with function properties
  @Input() onProgress!: (progress: number) => void;
  @Input() onComplete!: () => void;
  @Input() onAnswer!: (questionId: string, answer: string | boolean) => void;

  state!: InteractionState;
  currentQuestion?: InteractiveQuestion;
  private subscriptions: Subscription[] = [];

  constructor(private interactiveService: InteractiveLessonService) { }

  ngOnInit(): void {
    this.subscriptions.push(
      this.interactiveService.getState().subscribe(state => {
        this.state = state;
        this.currentQuestion = this.questions[state.currentQuestionIndex];

        // Call the function instead of emitting
        if (this.onProgress) {
          this.onProgress(state.progress);
        }

        if (state.isCompleted && !this.isCompleted) {
          // Call the function instead of emitting
          if (this.onComplete) {
            this.onComplete();
          }
        }
      })
    );
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.interactiveService.resetState();
  }

  submitAnswer(answer: string | boolean): void {
    if (!this.currentQuestion) return;

    const result = this.interactiveService.submitAnswer(this.currentQuestion, answer);

    // Call the function instead of emitting
    if (this.onAnswer) {
      this.onAnswer(this.currentQuestion.id, answer);
    }

    if (result.isCorrect && this.state.currentQuestionIndex < this.questions.length - 1) {
      setTimeout(() => this.interactiveService.nextQuestion(), 1500);
    } else if (result.isCorrect && this.state.currentQuestionIndex === this.questions.length - 1) {
      this.interactiveService.completeLesson();
    }
  }

  async toggleRecording(): Promise<void> {
    if (this.state.isRecording) {
      try {
        await this.interactiveService.stopRecording();
      } catch (error) {
        console.error('Error stopping recording:', error);
      }
    } else {
      try {
        await this.interactiveService.startRecording();
      } catch (error) {
        console.error('Error starting recording:', error);
      }
    }
  }

  nextQuestion(): void {
    this.interactiveService.nextQuestion();
  }

  previousQuestion(): void {
    this.interactiveService.previousQuestion();
  }

  getAnswerClass(option: string | boolean): string {
    if (!this.currentQuestion) return '';

    const userAnswer = this.state.answers.get(this.currentQuestion.id);
    if (userAnswer === undefined) return '';

    if (option === this.currentQuestion.correctAnswer) {
      return 'correct';
    }

    if (option === userAnswer) {
      return 'incorrect';
    }

    return '';
  }

  isAnswered(): boolean {
    return this.currentQuestion ?
      this.state.answers.has(this.currentQuestion.id) :
      false;
  }

  getProgress(): number {
    return ((this.state.currentQuestionIndex + 1) / this.questions.length) * 100;
  }
}