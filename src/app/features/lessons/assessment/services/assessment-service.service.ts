// Modified assessment-service.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, Subject } from 'rxjs';
import { AssessmentContent, AssessmentQuestion, QuestionType } from '../../assessment-lesson/assessment-lesson.types';
import { PlatformService } from '../../../../core/services/platform.service';

export interface AssessmentState {
  currentQuestionIndex: number;
  answers: Map<string, string | string[]>;
  selectedOptions: Map<string, string[]>;
  score: number;
  isCompleted: boolean;
  progress: number;
  showExplanation: boolean;
  currentQuestion?: AssessmentQuestion;
  lastAnsweredQuestion?: string;
  timeRemaining?: number;
  mode: 'assessment' | 'review';
}

export interface AnswerSubmittedEvent {
  questionId: string;
  result: 'correct' | 'incorrect';
  isLastQuestion: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class AssessmentService {
  private content?: AssessmentContent;
  private answerTimestamps: { [questionId: string]: number } = {};
  private currentStreak = 0;
  private totalPoints = 0;
  private pointsPerQuestion = 10;
  private feedbackDismissed = true;
  private showCompletionAnimationSubject = new BehaviorSubject<boolean>(false);
  private selectedQuestionIndexSubject = new BehaviorSubject<number | null>(null);

  // New properties for tracking attempts
  private isFirstAttempt = true;
  private readonly STORAGE_KEY_PREFIX = 'tajweed_assessment_completed_';

  // New subject for immediate answer feedback
  private answerSubmittedSubject = new Subject<AnswerSubmittedEvent>();

  // State management
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

  // Text answers storage
  private textAnswers: { [questionId: string]: string } = {};

  constructor(private platformService: PlatformService) { }

  getState(): Observable<AssessmentState> {
    return this.state.asObservable();
  }

  getCurrentState(): AssessmentState {
    return this.state.value;
  }

  getCurrentQuestion(): AssessmentQuestion | undefined {
    if (!this.content) return undefined;

    const currentState = this.state.value;
    return this.content.questions[currentState.currentQuestionIndex];
  }

  getCurrentStreak(): number {
    return this.currentStreak;
  }

  getTotalPoints(): number {
    return this.totalPoints;
  }

  isFeedbackDismissed(): boolean {
    return this.feedbackDismissed;
  }

  // Observable streams for component subscriptions
  setShowCompletionAnimation(show: boolean): void {
    this.showCompletionAnimationSubject.next(show);
  }

  setSelectedQuestionIndex(index: number | null): void {
    this.selectedQuestionIndexSubject.next(index);
  }

  showsCompletionAnimation(): boolean {
    return this.showCompletionAnimationSubject.value;
  }

  getSelectedQuestionIndex(): number | null {
    return this.selectedQuestionIndexSubject.value;
  }

  getCompletionAnimationState(): Observable<boolean> {
    return this.showCompletionAnimationSubject.asObservable();
  }

  getSelectedQuestionIndexState(): Observable<number | null> {
    return this.selectedQuestionIndexSubject.asObservable();
  }

  // New method to get answer submitted events
  getAnswerSubmittedEvents(): Observable<AnswerSubmittedEvent> {
    return this.answerSubmittedSubject.asObservable();
  }

  getTextAnswers(): { [questionId: string]: string } {
    return this.textAnswers;
  }

  getTextAnswer(questionId: string): string {
    return this.textAnswers[questionId] || '';
  }

  setTextAnswer(questionId: string, answer: string): void {
    // Store text answer and log it for debugging
    this.textAnswers[questionId] = answer;
    console.log(`[AssessmentService] Text answer set for ${questionId}: "${answer}", length: ${answer.length}`);

    // Notify state subscribers about the change
    const currentState = this.state.value;
    this.state.next({ ...currentState });
  }


  getContent(): AssessmentContent | undefined {
    return this.content;
  }

  parseContent(content: string): AssessmentContent {
    try {
      console.log('[AssessmentService] Parsing content...');
      // Parse the content JSON string to object
      const parsedContent: AssessmentContent = typeof content === 'string'
        ? JSON.parse(content)
        : content;

      // Validate the content structure
      if (!Array.isArray(parsedContent.questions)) {
        console.error('[AssessmentService] Invalid content structure: questions array missing');
        return {
          title: 'Error loading content',
          questions: []
        };
      }

      return parsedContent;
    } catch (error) {
      console.error('[AssessmentService] Error parsing content:', error);
      return {
        title: 'Error loading content',
        questions: []
      };
    }
  }

  initializeAssessment(content: AssessmentContent): void {
    this.content = content;
    this.resetState();
    this.checkIfFirstAttempt();
  }

  // New method to check if this is the first assessment attempt
  private checkIfFirstAttempt(): void {
    if (!this.content) return;

    try {
      // Use title as a unique identifier if id not available
      const assessmentId = (this.content.id || this.content.title || 'unknown');
      const storageKey = `${this.STORAGE_KEY_PREFIX}${assessmentId}`;

      const storedValue = localStorage.getItem(storageKey);
      this.isFirstAttempt = !storedValue;

      console.log(`[AssessmentService] Assessment "${assessmentId}" is ${this.isFirstAttempt ? 'a first attempt' : 'a repeat attempt'}`);
    } catch (error) {
      console.error('[AssessmentService] Error checking if first attempt:', error);
      this.isFirstAttempt = true; // Default to first attempt on error
    }
  }

  // New method to mark an assessment as completed
  private markAssessmentCompleted(): void {
    if (!this.content) return;

    try {
      const assessmentId = (this.content.id || this.content.title || 'unknown');
      const storageKey = `${this.STORAGE_KEY_PREFIX}${assessmentId}`;

      localStorage.setItem(storageKey, Date.now().toString());
      this.isFirstAttempt = false;

      console.log(`[AssessmentService] Marked assessment "${assessmentId}" as completed`);
    } catch (error) {
      console.error('[AssessmentService] Error marking assessment as completed:', error);
    }
  }

  // New public method to check if this is the first attempt
  isFirstAttemptCheck(): boolean {
    return this.isFirstAttempt;
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

    this.textAnswers = {};
    this.currentStreak = 0;
    this.totalPoints = 0;
    this.feedbackDismissed = true;
    this.showCompletionAnimationSubject.next(false);
    this.selectedQuestionIndexSubject.next(null);
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

    // Save to textAnswers object
    this.textAnswers[questionId] = answer;

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
        answers.set(questionId, this.textAnswers[questionId] || '');
      }
    }

    // Record timestamp for tracking answer speed
    this.answerTimestamps[questionId] = Date.now();

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

    // Only update streak and add points on first attempt
    if (this.isFirstAttempt) {
      // Update streak and points
      const result = this.getQuestionResult(questionId);
      if (result === 'correct') {
        this.currentStreak++;
        this.totalPoints += this.getQuestionPoints();

        // Provide success haptic feedback
        this.platformService.vibrateSuccess().catch(() => { });
      } else {
        this.currentStreak = 0;

        // Provide error haptic feedback
        this.platformService.vibrateWarning().catch(() => { });
      }
    }

    // Show feedback immediately for first attempts only
    this.feedbackDismissed = !this.isFirstAttempt;

    // Check if this is the last question
    const isLastQuestion = currentState.currentQuestionIndex === this.content.questions.length - 1;

    // Emit the answer submitted event immediately
    const result = this.getQuestionResult(questionId);
    this.answerSubmittedSubject.next({
      questionId,
      result: result === 'correct' ? 'correct' : 'incorrect',
      isLastQuestion
    });
  }

  dismissFeedback(): void {
    this.feedbackDismissed = true;
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

    // If this is the first attempt, mark as completed for future reference
    if (this.isFirstAttempt) {
      this.markAssessmentCompleted();

      // Show completion animation for first attempts
      // This is important - trigger the completion animation
      setTimeout(() => {
        this.setShowCompletionAnimation(true);
      }, 500); // Brief delay to ensure state transition occurs first
    }
  }

  restartAssessment(): void {
    if (!this.content) return;

    // Keep track that this is not the first attempt anymore
    this.isFirstAttempt = false;

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

    // Reset other state
    this.textAnswers = {};
    this.currentStreak = 0;
    this.totalPoints = 0;
    this.feedbackDismissed = true; // Always dismissed for repeat attempts
  }

  setCompleted(): void {
    const currentState = this.state.value;

    this.state.next({
      ...currentState,
      isCompleted: true,
      progress: 100
    });

    // If this is the first attempt, mark as completed
    if (this.isFirstAttempt) {
      this.markAssessmentCompleted();
    }
  }

  // Utility methods
  isAnswered(questionId: string): boolean {
    return this.state.value.answers.has(questionId) || false;
  }

  isOptionSelected(questionId: string, optionId: string): boolean {
    const selectedOptions = this.state.value.selectedOptions.get(questionId) || [];
    return selectedOptions.includes(optionId);
  }

  isCorrectOption(question: AssessmentQuestion, optionId: string): boolean {
    if (!question.options) return false;

    const option = question.options.find(opt => opt.id === optionId);
    return !!option?.isCorrect;
  }

  isIncorrectSelectedOption(questionId: string, optionId: string): boolean {
    if (!this.isOptionSelected(questionId, optionId)) return false;

    const question = this.content?.questions.find(q => q.id === questionId);
    if (!question) return false;

    return !this.isCorrectOption(question, optionId);
  }

  getQuestionResult(questionId: string): 'correct' | 'incorrect' | 'unanswered' {
    if (!this.state.value.answers.has(questionId)) return 'unanswered';

    const question = this.content?.questions.find(q => q.id === questionId);
    if (!question) return 'unanswered';

    const userAnswer = this.state.value.answers.get(questionId);

    if (question.type === QuestionType.MULTIPLE_CHOICE) {
      // For multiple choice, check if selected options match correct options
      const correctOptionIds = question.options
        ?.filter(opt => opt.isCorrect)
        .map(opt => opt.id) || [];

      const selectedOptions = this.state.value.selectedOptions.get(questionId) || [];

      // Check if arrays have the same contents (order doesn't matter)
      const isCorrect =
        correctOptionIds.length === selectedOptions.length &&
        correctOptionIds.every(id => selectedOptions.includes(id));

      return isCorrect ? 'correct' : 'incorrect';
    } else if (question.type === QuestionType.SINGLE_CHOICE ||
      question.type === QuestionType.TRUE_FALSE) {
      // For single choice, direct comparison with correct answer
      return userAnswer === question.correctAnswer ? 'correct' : 'incorrect';
    } else if (question.type === QuestionType.TEXT_INPUT) {
      // For text input, compare with possible correct answers (case insensitive)
      const correctAnswers = Array.isArray(question.correctAnswer)
        ? question.correctAnswer
        : [question.correctAnswer || ''];

      const normalizedUserAnswer = String(userAnswer).toLowerCase().trim();
      const isCorrect = correctAnswers.some(ans =>
        String(ans).toLowerCase().trim() === normalizedUserAnswer
      );

      return isCorrect ? 'correct' : 'incorrect';
    }

    return 'unanswered';
  }

  getCorrectAnswerText(question?: AssessmentQuestion): string {
    if (!question) return '';

    if (question.type === QuestionType.SINGLE_CHOICE || question.type === QuestionType.MULTIPLE_CHOICE) {
      const correctOptions = question.options?.filter(opt => opt.isCorrect) || [];
      return correctOptions.map(opt => opt.text).join(', ');
    } else if (question.type === QuestionType.TRUE_FALSE) {
      return question.correctAnswer === 'true' ? 'صحيح' : 'خطأ';
    } else {
      return Array.isArray(question.correctAnswer)
        ? question.correctAnswer.join(', ')
        : question.correctAnswer || '';
    }
  }

  getUserAnswerText(questionId: string): string {
    if (!this.state.value.answers.has(questionId)) return '';

    const question = this.content?.questions.find(q => q.id === questionId);
    if (!question) return '';

    const userAnswer = this.state.value.answers.get(questionId);

    if (question.type === QuestionType.SINGLE_CHOICE || question.type === QuestionType.MULTIPLE_CHOICE) {
      const selectedOptions = this.state.value.selectedOptions.get(questionId) || [];
      const selectedTexts = selectedOptions.map(optId =>
        question.options?.find(opt => opt.id === optId)?.text || ''
      );
      return selectedTexts.join(', ');
    } else if (question.type === QuestionType.TRUE_FALSE) {
      return userAnswer === 'true' ? 'صحيح' : 'خطأ';
    } else {
      return String(userAnswer || '');
    }
  }

  private calculateScore(answers: Map<string, string | string[]>): number {
    if (!this.content) return 0;

    const totalQuestions = this.content.questions.length;
    if (totalQuestions === 0) return 0;

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
        const correctAnswerArray = Array.isArray(question.correctAnswer)
          ? question.correctAnswer
          : [question.correctAnswer || ''];

        const normalizedUserAnswer = String(userAnswer).toLowerCase().trim();
        const isCorrect = correctAnswerArray.some(ans =>
          String(ans).toLowerCase().trim() === normalizedUserAnswer
        );

        if (isCorrect) {
          correctAnswers++;
        }
      }
    });

    return Math.round((correctAnswers / totalQuestions) * 100);
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

  getQuestionPoints(): number {
    // Base points per question
    let points = this.pointsPerQuestion;

    // Bonus for streak
    if (this.currentStreak > 1) {
      points += Math.min(this.currentStreak * 2, 10); // Max +10 bonus for streak
    }

    return points;
  }

  getCorrectAnswersCount(): number {
    if (!this.content) return 0;

    return this.content.questions.filter(question =>
      this.getQuestionResult(question.id) === 'correct'
    ).length;
  }

  getIncorrectAnswersCount(): number {
    if (!this.content) return 0;

    return this.content.questions.filter(question =>
      this.getQuestionResult(question.id) === 'incorrect'
    ).length;
  }

  canSubmitAnswer(questionId: string): boolean {
    const selectedOptions = this.state.value.selectedOptions.get(questionId) || [];

    if (!this.content) return false;

    const question = this.content.questions.find(q => q.id === questionId);
    if (!question) return false;

    let result = false;

    switch (question.type) {
      case QuestionType.SINGLE_CHOICE:
      case QuestionType.MULTIPLE_CHOICE:
        result = selectedOptions.length > 0;
        break;
      case QuestionType.TRUE_FALSE:
        result = selectedOptions.length === 1;
        break;
      case QuestionType.TEXT_INPUT:
        // Specifically check if there's any text, ensuring we trim whitespace
        const hasText = !!(this.textAnswers[questionId]?.trim());
        result = hasText;
        break;
      default:
        result = false;
    }

    console.log(`[AssessmentService] canSubmitAnswer for ${questionId} (${question.type}): ${result}`,
      question.type === QuestionType.TEXT_INPUT ? `Text: "${this.textAnswers[questionId] || ''}"` : '');

    return result;
  }

  getRecommendations(): string[] {
    const recommendations: string[] = [];

    if (!this.content) return recommendations;

    // Get incorrectly answered questions
    const incorrectQuestions = this.content.questions.filter(q =>
      this.getQuestionResult(q.id) === 'incorrect'
    );

    if (incorrectQuestions.length === 0) {
      recommendations.push('أحسنت! لقد أجبت على جميع الأسئلة بشكل صحيح.');
      return recommendations;
    }

    // Basic recommendations
    if (incorrectQuestions.length > 0) {
      recommendations.push('مراجعة المواضيع المتعلقة بالأسئلة التي أخطأت فيها.');
    }

    // Add some specific recommendations based on question type
    const hasTrueFalse = incorrectQuestions.some(q => q.type === QuestionType.TRUE_FALSE);
    if (hasTrueFalse) {
      recommendations.push('التركيز على فهم المفاهيم الأساسية لتحسين أدائك في أسئلة الصواب والخطأ.');
    }

    const hasMultipleChoice = incorrectQuestions.some(q => q.type === QuestionType.MULTIPLE_CHOICE);
    if (hasMultipleChoice) {
      recommendations.push('تدرب على تحليل أسئلة الاختيار من متعدد بتمعن للتمييز بين الإجابات الصحيحة والخاطئة.');
    }

    return recommendations;
  }
}