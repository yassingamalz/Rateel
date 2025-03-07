// assessment-lesson.component.ts
import {
  Component,
  Input,
  Output,
  EventEmitter,
  OnInit,
  OnDestroy,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  ViewChild,
  ElementRef
} from '@angular/core';
import { AssessmentLessonService } from './assessment-lesson.service';
import { Subscription } from 'rxjs';
import { trigger, state, style, transition, animate } from '@angular/animations';
import { PlatformService } from '../../../core/services/platform.service';
import { AssessmentState, AssessmentContent, AssessmentQuestion, QuestionType } from './assessment-lesson.types';
import { ThemeService } from '../../../shared/services/theme.service';

interface Badge {
  id: string;
  name: string;
  description: string;
  icon: string;
  condition: () => boolean;
}

@Component({
  selector: 'app-assessment-lesson',
  standalone: false,
  templateUrl: './assessment-lesson.component.html',
  styleUrls: ['./assessment-lesson.component.scss'],
  providers: [AssessmentLessonService],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('cardAnimation', [
      transition(':increment', [
        style({ transform: 'translateX(-100%)', opacity: 0 }),
        animate('400ms ease-out', style({ transform: 'translateX(0)', opacity: 1 }))
      ]),
      transition(':decrement', [
        style({ transform: 'translateX(100%)', opacity: 0 }),
        animate('400ms ease-out', style({ transform: 'translateX(0)', opacity: 1 }))
      ])
    ]),
    trigger('slideDown', [
      transition(':enter', [
        style({ opacity: 0, height: 0, overflow: 'hidden' }),
        animate('300ms ease-out', style({ opacity: 1, height: '*', overflow: 'hidden' }))
      ]),
      transition(':leave', [
        style({ overflow: 'hidden' }),
        animate('300ms ease-out', style({ opacity: 0, height: 0, overflow: 'hidden' }))
      ])
    ]),
    trigger('fadeInOut', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('300ms ease-in', style({ opacity: 1 }))
      ]),
      transition(':leave', [
        animate('300ms ease-out', style({ opacity: 0 }))
      ])
    ])
  ]
})
export class AssessmentLessonComponent implements OnInit, OnDestroy {
  @ViewChild('questionContainer') questionContainer!: ElementRef<HTMLElement>;
  
  @Input() content?: string;
  @Input() isCompleted?: boolean;
  @Output() onProgress = new EventEmitter<number>();
  @Output() onComplete = new EventEmitter<void>();

  state!: AssessmentState;
  parsedContent?: AssessmentContent;
  currentQuestion?: AssessmentQuestion;
  QuestionType = QuestionType; // For template access
  
  // Enhanced features
  isDarkMode = false;
  showHint = false;
  feedbackDismissed = true;
  textAnswers: { [questionId: string]: string } = {};
  currentStreak = 0;
  totalPoints = 0;
  pointsPerQuestion = 10;
  showCompletionAnimation = false;
  selectedQuestionIndex: number | null = null;
  
  earnedBadges: any[] = [];
  availableBadges: Badge[] = [
    {
      id: 'perfect-score',
      name: 'العلامة الكاملة',
      description: 'حصلت على جميع الإجابات صحيحة',
      icon: 'badge-perfect',
      condition: () => this.calculateScore() === 100
    },
    {
      id: 'quick-thinker',
      name: 'المجيب السريع',
      description: 'أجبت عن جميع الأسئلة في وقت قياسي',
      icon: 'badge-quick',
      condition: () => this.calculateScore() >= 70 // For now, just use score as a condition
    },
    {
      id: 'streaker',
      name: 'متسلسل الإجابات',
      description: 'أجبت بشكل صحيح على 3 أسئلة متتالية',
      icon: 'badge-streak',
      condition: () => this.currentStreak >= 3
    }
  ];
  
  private subscriptions: Subscription[] = [];
  private isCompleting = false;
  private answerTimestamps: { [questionId: string]: number } = {};

  constructor(
    protected assessmentService: AssessmentLessonService,
    private platformService: PlatformService,
    private cdr: ChangeDetectorRef,
    private themeService?: ThemeService
  ) {}

  ngOnInit(): void {
    console.log('[AssessmentLessonComponent] Initializing with content:', this.content ? 'provided' : 'missing');
    
    if (this.content) {
      try {
        this.parsedContent = this.assessmentService.parseContent(this.content);
        console.log('[AssessmentLessonComponent] Parsed content:', this.parsedContent);
        
        // Initialize assessment with content
        this.assessmentService.initializeAssessment(this.parsedContent);
      } catch (error) {
        console.error('[AssessmentLessonComponent] Error parsing content:', error);
      }
    } else {
      console.warn('[AssessmentLessonComponent] No content provided');
    }

    // Subscribe to state changes
    this.subscriptions.push(
      this.assessmentService.getState().subscribe(state => {
        this.state = state;
        this.onProgress.emit(state.progress);
        
        // Get current question for easy access
        if (this.parsedContent && state.currentQuestionIndex >= 0 && 
            state.currentQuestionIndex < this.parsedContent.questions.length) {
          this.currentQuestion = this.parsedContent.questions[state.currentQuestionIndex];
        }

        if (state.isCompleted && !this.isCompleted && !this.isCompleting) {
          this.handleCompletion();
        }
        
        this.cdr.markForCheck();
      })
    );
    
    // Check if there's a saved theme preference
    if (this.themeService) {
      this.subscriptions.push(
        this.themeService.theme$.subscribe(theme => {
          this.isDarkMode = theme === 'dark';
          this.cdr.markForCheck();
        })
      );
    }
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.assessmentService.resetState();
  }

  private async handleCompletion(): Promise<void> {
    if (this.isCompleting) return;
    this.isCompleting = true;

    // Provide haptic feedback on mobile
    try {
      await this.platformService.vibrateSuccess();
    } catch (error) {
      console.warn('Haptic feedback not available', error);
    }
    
    // Calculate final score and badges
    this.calculateFinalScore();
    this.earnedBadges = this.availableBadges.filter(badge => badge.condition());
    
    // Show completion animation
    this.showCompletionAnimation = true;
    this.cdr.markForCheck();

    // Emit completion event after a delay for animation
    setTimeout(() => {
      this.showCompletionAnimation = false;
      this.onComplete.emit();
      this.isCompleting = false;
      this.cdr.markForCheck();
    }, 3000); // Animation duration
  }

  handleSkip(): void {
    console.log("[AssessmentLessonComponent] Skip button clicked, isCompleted:", this.isCompleted);
    
    // Always emit completion event immediately for any click
    this.onComplete.emit();
    
    // Add haptic feedback
    this.platformService.vibrateSuccess().catch(() => {
      // Ignore errors if vibration is not available
    });
    
    // If not already completed, also mark as completed
    if (!this.isCompleted && this.parsedContent) {
      this.assessmentService.setCompleted();
    }
  }
  
  toggleTheme(): void {
    this.isDarkMode = !this.isDarkMode;
    
    // Update theme service if available
    if (this.themeService) {
      this.themeService.setTheme(this.isDarkMode ? 'dark' : 'light');
    }
  }

  onOptionSelected(questionId: string, optionId: string): void {
    if (this.isAnswered(questionId)) return;
    
    this.answerTimestamps[questionId] = Date.now();
    this.assessmentService.selectOption(questionId, optionId);
  }

  onMultipleOptionSelected(questionId: string, optionId: string, checked: boolean): void {
    if (this.isAnswered(questionId)) return;
    
    this.answerTimestamps[questionId] = Date.now();
    this.assessmentService.selectMultipleOption(questionId, optionId, checked);
  }

  onTextAnswerChange(questionId: string, answer: string): void {
    if (this.isAnswered(questionId)) return;
    
    this.answerTimestamps[questionId] = Date.now();
    this.assessmentService.submitTextAnswer(questionId, answer);
  }

  onTrueFalseSelected(questionId: string, value: boolean): void {
    if (this.isAnswered(questionId)) return;
    
    this.answerTimestamps[questionId] = Date.now();
    this.assessmentService.submitTrueFalseAnswer(questionId, value);
  }

  submitAnswer(): void {
    if (!this.currentQuestion || this.isAnswered(this.currentQuestion.id)) return;
    
    this.feedbackDismissed = false;
    this.assessmentService.submitAnswer(this.currentQuestion.id);
    
    // Update streak and points
    const result = this.getQuestionResult(this.currentQuestion.id);
    if (result === 'correct') {
      this.currentStreak++;
      this.totalPoints += this.getQuestionPoints();
      
      // Provide success haptic feedback
      this.platformService.vibrateSuccess().catch(() => {});
    } else {
      this.currentStreak = 0;
      
      // Provide error haptic feedback
      this.platformService.vibrateError().catch(() => {});
    }
    
    this.cdr.markForCheck();
  }
  
  dismissFeedback(): void {
    this.feedbackDismissed = true;
    this.cdr.markForCheck();
  }

  nextQuestion(): void {
    this.feedbackDismissed = true;
    this.showHint = false;
    this.assessmentService.goToNextQuestion();
    
    // Scroll to top of question container
    setTimeout(() => {
      if (this.questionContainer) {
        this.questionContainer.nativeElement.scrollTop = 0;
      }
    }, 100);
  }

  previousQuestion(): void {
    this.showHint = false;
    this.assessmentService.goToPreviousQuestion();
    
    // Scroll to top of question container
    setTimeout(() => {
      if (this.questionContainer) {
        this.questionContainer.nativeElement.scrollTop = 0;
      }
    }, 100);
  }
  
  goToQuestion(index: number): void {
    if (index === this.state.currentQuestionIndex) return;
    
    this.showHint = false;
    this.assessmentService.goToQuestion(index);
    
    // Scroll to top of question container
    setTimeout(() => {
      if (this.questionContainer) {
        this.questionContainer.nativeElement.scrollTop = 0;
      }
    }, 100);
  }

  toggleHint(): void {
    this.showHint = !this.showHint;
    this.cdr.markForCheck();
  }
  
  showQuestionDetails(index: number): void {
    this.selectedQuestionIndex = index;
    this.cdr.markForCheck();
  }
  
  closeQuestionDetails(): void {
    this.selectedQuestionIndex = null;
    this.cdr.markForCheck();
  }
  
  finishAssessment(): void {
    this.calculateFinalScore();
    this.earnedBadges = this.availableBadges.filter(badge => badge.condition());
    this.assessmentService.finishAssessment();
    this.cdr.markForCheck();
  }

  restartAssessment(): void {
    this.totalPoints = 0;
    this.currentStreak = 0;
    this.earnedBadges = [];
    this.textAnswers = {};
    this.feedbackDismissed = true;
    this.showHint = false;
    this.assessmentService.restartAssessment();
    this.cdr.markForCheck();
  }
  
  // Utility Methods
  isAnswered(questionId: string): boolean {
    return this.state?.answers.has(questionId) || false;
  }
  
  isOptionSelected(questionId: string, optionId: string): boolean {
    const selectedOptions = this.state?.selectedOptions.get(questionId) || [];
    return selectedOptions.includes(optionId);
  }
  
  isCorrectOption(question: AssessmentQuestion, optionId: string): boolean {
    if (!question.options) return false;
    
    const option = question.options.find(opt => opt.id === optionId);
    return !!option?.isCorrect;
  }
  
  isIncorrectSelectedOption(questionId: string, optionId: string): boolean {
    if (!this.isOptionSelected(questionId, optionId)) return false;
    
    const question = this.parsedContent?.questions.find(q => q.id === questionId);
    if (!question) return false;
    
    return !this.isCorrectOption(question, optionId);
  }
  
  getQuestionResult(questionId: string): 'correct' | 'incorrect' | 'unanswered' {
    if (!this.state.answers.has(questionId)) return 'unanswered';
    
    const question = this.parsedContent?.questions.find(q => q.id === questionId);
    if (!question) return 'unanswered';
    
    const userAnswer = this.state.answers.get(questionId);
    
    if (question.type === QuestionType.MULTIPLE_CHOICE) {
      // For multiple choice, check if selected options match correct options
      const correctOptionIds = question.options
        ?.filter(opt => opt.isCorrect)
        .map(opt => opt.id) || [];
      
      const selectedOptions = this.state.selectedOptions.get(questionId) || [];
      
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
    if (!this.state.answers.has(questionId)) return '';
    
    const question = this.parsedContent?.questions.find(q => q.id === questionId);
    if (!question) return '';
    
    const userAnswer = this.state.answers.get(questionId);
    
    if (question.type === QuestionType.SINGLE_CHOICE || question.type === QuestionType.MULTIPLE_CHOICE) {
      const selectedOptions = this.state.selectedOptions.get(questionId) || [];
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
  
  calculateScore(): number {
    if (!this.parsedContent) return 0;
    
    const totalQuestions = this.parsedContent.questions.length;
    if (totalQuestions === 0) return 0;
    
    let correctAnswers = 0;
    
    this.parsedContent.questions.forEach(question => {
      const result = this.getQuestionResult(question.id);
      if (result === 'correct') {
        correctAnswers++;
      }
    });
    
    return Math.round((correctAnswers / totalQuestions) * 100);
  }
  
  getScoreCircleValue(): string {
    const score = this.calculateScore();
    // Circle circumference is 2πr = 2 * π * 45 ≈ 283
    const circumference = 283;
    const value = (score / 100) * circumference;
    return `${value}, ${circumference}`;
  }
  
  getCorrectAnswersCount(): number {
    if (!this.parsedContent) return 0;
    
    return this.parsedContent.questions.filter(question => 
      this.getQuestionResult(question.id) === 'correct'
    ).length;
  }
  
  getIncorrectAnswersCount(): number {
    if (!this.parsedContent) return 0;
    
    return this.parsedContent.questions.filter(question => 
      this.getQuestionResult(question.id) === 'incorrect'
    ).length;
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
  
  calculateFinalScore(): void {
    if (!this.parsedContent) return;
    
    // Calculate total points
    let totalPoints = 0;
    
    this.parsedContent.questions.forEach(question => {
      if (this.getQuestionResult(question.id) === 'correct') {
        // Base points
        let points = this.pointsPerQuestion;
        
        // Time bonus (faster answers get more points)
        const answerTime = this.answerTimestamps[question.id];
        if (answerTime) {
          // Just a placeholder for time bonus logic
          points += 0; // Could add time-based bonus here
        }
        
        totalPoints += points;
      }
    });
    
    this.totalPoints = totalPoints;
  }
  
  canSubmitAnswer(questionId: string): boolean {
    const selectedOptions = this.state.selectedOptions.get(questionId) || [];
    
    if (!this.currentQuestion) return false;
    
    switch (this.currentQuestion.type) {
      case QuestionType.SINGLE_CHOICE:
      case QuestionType.MULTIPLE_CHOICE:
        return selectedOptions.length > 0;
      case QuestionType.TRUE_FALSE:
        return selectedOptions.length === 1;
      case QuestionType.TEXT_INPUT:
        return !!this.textAnswers[questionId]?.trim();
      default:
        return false;
    }
  }
  
  getRecommendations(): string[] {
    const recommendations: string[] = [];
    
    if (!this.parsedContent) return recommendations;
    
    // Get incorrectly answered questions
    const incorrectQuestions = this.parsedContent.questions.filter(q => 
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