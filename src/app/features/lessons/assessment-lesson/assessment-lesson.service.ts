// src/app/features/lessons/assessment-lesson/assessment-lesson.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { AssessmentState, AssessmentContent, QuestionType } from './assessment-lesson.types';

@Injectable()
export class AssessmentLessonService {
  private state = new BehaviorSubject<AssessmentState>({
    currentQuestionIndex: 0,
    answers: new Map<string, string | string[]>(),
    selectedOptions: new Map<string, string[]>(),
    score: 0,
    isCompleted: false,
    progress: 0,
    showExplanation: false,
    mode: 'assessment'
  });

  private content?: AssessmentContent;

  constructor() {}

  getState(): Observable<AssessmentState> {
    return this.state.asObservable();
  }

  parseContent(content: string): AssessmentContent {
    try {
      console.log('[AssessmentLessonService] Parsing content...');
      // Parse the content JSON string to object
      const parsedContent: AssessmentContent = typeof content === 'string' 
        ? JSON.parse(content) 
        : content;
      
      // Validate the content structure
      if (!Array.isArray(parsedContent.questions)) {
        console.error('[AssessmentLessonService] Invalid content structure: questions array missing');
        return {
          title: 'Error loading content',
          questions: []
        };
      }

      return parsedContent;
    } catch (error) {
      console.error('[AssessmentLessonService] Error parsing content:', error);
      return {
        title: 'Error loading content',
        questions: []
      };
    }
  }

  initializeAssessment(content: AssessmentContent): void {
    this.content = content;
    this.resetState();
  }

  resetState(): void {
    this.state.next({
      currentQuestionIndex: 0,
      answers: new Map<string, string | string[]>(),
      selectedOptions: new Map<string, string[]>(),
      score: 0,
      isCompleted: false,
      progress: 0,
      showExplanation: false,
      mode: 'assessment'
    });
  }

  selectOption(questionId: string, optionId: string): void {
    const currentState = this.state.value;
    
    // For single choice questions, replace any existing selection
    const selectedOptions = new Map(currentState.selectedOptions);
    selectedOptions.set(questionId, [optionId]);
    
    this.state.next({
      ...currentState,
      selectedOptions
    });
  }

  selectMultipleOption(questionId: string, optionId: string, checked: boolean): void {
    const currentState = this.state.value;
    
    // Get current selections for this question
    const currentSelections = currentState.selectedOptions.get(questionId) || [];
    
    // Update selections based on checked state
    let newSelections: string[];
    if (checked) {
      // Add to selections if not already present
      newSelections = [...currentSelections, optionId];
    } else {
      // Remove from selections if present
      newSelections = currentSelections.filter(id => id !== optionId);
    }
    
    // Update state with new selections
    const selectedOptions = new Map(currentState.selectedOptions);
    selectedOptions.set(questionId, newSelections);
    
    this.state.next({
      ...currentState,
      selectedOptions
    });
  }

  submitTrueFalseAnswer(questionId: string, value: boolean): void {
    const currentState = this.state.value;
    
    // Set selected option for the true/false question
    const selectedOptions = new Map(currentState.selectedOptions);
    selectedOptions.set(questionId, [value.toString()]);
    
    this.state.next({
      ...currentState,
      selectedOptions
    });
  }

  submitTextAnswer(questionId: string, answer: string): void {
    const currentState = this.state.value;
    
    // Save text input answer
    const answers = new Map(currentState.answers);
    answers.set(questionId, answer);
    
    // Update progress on real-time text input
    this.updateProgress(answers);
    
    this.state.next({
      ...currentState,
      answers
    });
  }

  submitAnswer(questionId: string): void {
    if (!this.content) return;
    
    const currentState = this.state.value;
    const answers = new Map(currentState.answers);
    const question = this.content.questions.find(q => q.id === questionId);
    
    if (!question) return;
    
    // Get selected options for this question
    const selectedOptions = currentState.selectedOptions.get(questionId) || [];
    
    // Handle different question types
    if (question.type === QuestionType.SINGLE_CHOICE && selectedOptions.length > 0) {
      // For single choice, store the selected option ID
      answers.set(questionId, selectedOptions[0]);
    } else if (question.type === QuestionType.MULTIPLE_CHOICE && selectedOptions.length > 0) {
      // For multiple choice, store array of selected option IDs
      answers.set(questionId, selectedOptions);
    } else if (question.type === QuestionType.TRUE_FALSE && selectedOptions.length > 0) {
      // For true/false, store the boolean value as string
      answers.set(questionId, selectedOptions[0]);
    } else if (question.type === QuestionType.TEXT_INPUT) {
      // For text input, answer is already stored by submitTextAnswer
      // But if somehow it's not there, add a default
      if (!answers.has(questionId)) {
        answers.set(questionId, '');
      }
    }
    
    // Update progress
    this.updateProgress(answers);
    
    // Calculate score
    const score = this.calculateScore(answers);
    
    // Show explanation automatically
    this.state.next({
      ...currentState,
      answers,
      lastAnsweredQuestion: questionId,
      score,
      showExplanation: true
    });
  }

  toggleExplanation(show: boolean): void {
    const currentState = this.state.value;
    
    this.state.next({
      ...currentState,
      showExplanation: show
    });
  }

  goToNextQuestion(): void {
    if (!this.content) return;
    
    const currentState = this.state.value;
    
    // If already at the last question, don't proceed
    if (currentState.currentQuestionIndex >= this.content.questions.length - 1) return;
    
    // Move to next question and hide explanation
    this.state.next({
      ...currentState,
      currentQuestionIndex: currentState.currentQuestionIndex + 1,
      showExplanation: false
    });
  }

  goToPreviousQuestion(): void {
    const currentState = this.state.value;
    
    // If already at the first question, don't go back
    if (currentState.currentQuestionIndex <= 0) return;
    
    // Move to previous question and hide explanation
    this.state.next({
      ...currentState,
      currentQuestionIndex: currentState.currentQuestionIndex - 1,
      showExplanation: false
    });
  }

  goToQuestion(index: number): void {
    if (!this.content) return;
    
    // Ensure index is within valid range
    if (index < 0 || index >= this.content.questions.length) return;
    
    const currentState = this.state.value;
    
    // Move to specified question and hide explanation
    this.state.next({
      ...currentState,
      currentQuestionIndex: index,
      showExplanation: false
    });
  }

  finishAssessment(): void {
    const currentState = this.state.value;
    
    // Calculate final score and set completion
    const score = this.calculateScore(currentState.answers);
    const isCompleted = true;
    
    // Switch to review mode
    this.state.next({
      ...currentState,
      score,
      isCompleted,
      progress: 100,
      mode: 'review'
    });
  }

  restartAssessment(): void {
    if (!this.content) return;
    
    // Reset the state but keep the content
    this.state.next({
      currentQuestionIndex: 0,
      answers: new Map<string, string | string[]>(),
      selectedOptions: new Map<string, string[]>(),
      score: 0,
      isCompleted: false,
      progress: 0,
      showExplanation: false,
      mode: 'assessment'
    });
  }

  setCompleted(): void {
    const currentState = this.state.value;
    
    this.state.next({
      ...currentState,
      isCompleted: true,
      progress: 100
    });
  }

  private updateProgress(answers: Map<string, string | string[]>): void {
    if (!this.content) return;
    
    const progress = (answers.size / this.content.questions.length) * 100;
    
    const currentState = this.state.value;
    
    this.state.next({
      ...currentState,
      progress
    });
  }

  private calculateScore(answers: Map<string, string | string[]>): number {
    if (!this.content) return 0;
    
    let correctAnswers = 0;
    
    this.content.questions.forEach(question => {
      const userAnswer = answers.get(question.id);
      if (!userAnswer) return;
      
      // Check if answer is correct based on question type
      if (question.type === QuestionType.SINGLE_CHOICE || 
          question.type === QuestionType.TRUE_FALSE) {
        if (userAnswer === question.correctAnswer) {
          correctAnswers++;
        }
      } else if (question.type === QuestionType.MULTIPLE_CHOICE) {
        // For multiple choice, all selected options must match correct options
        if (Array.isArray(userAnswer) && Array.isArray(question.correctAnswer)) {
          const isCorrect = 
            userAnswer.length === question.correctAnswer.length &&
            userAnswer.every(id => question.correctAnswer?.includes(id));
          
          if (isCorrect) {
            correctAnswers++;
          }
        }
      } else if (question.type === QuestionType.TEXT_INPUT) {
        // For text input, compare with possible correct answers (case insensitive)
        const correctAnswers = Array.isArray(question.correctAnswer) 
          ? question.correctAnswer 
          : [question.correctAnswer || ''];
        
        const normalizedUserAnswer = String(userAnswer).toLowerCase().trim();
        const isCorrect = correctAnswers.some(ans => 
          String(ans).toLowerCase().trim() === normalizedUserAnswer
        );
        
        if (isCorrect) {
        }
      }
    });
    
    return Math.round((correctAnswers / this.content.questions.length) * 100);
  }
}