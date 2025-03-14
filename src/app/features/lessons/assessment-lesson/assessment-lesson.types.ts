// src/app/features/lessons/assessment-lesson/assessment-lesson.types.ts
export interface AssessmentQuestion {
    id: string;
    text: string;
    type: QuestionType;
    options?: AssessmentOption[];
    correctAnswer?: string | string[];
    explanation?: string;
    hint?: string;
    imageUrl?: string;
    audioUrl?: string;
}

export enum QuestionType {
    MULTIPLE_CHOICE = 'multipleChoice',
    SINGLE_CHOICE = 'singleChoice',
    TRUE_FALSE = 'trueFalse',
    TEXT_INPUT = 'textInput',
    MATCHING = 'matching'
}

export interface AssessmentOption {
    id: string;
    text: string;
    isCorrect?: boolean;
}

export interface AssessmentState {
    currentQuestionIndex: number;
    answers: Map<string, string | string[]>;
    score: number;
    isCompleted: boolean;
    progress: number;
    selectedOptions: Map<string, string[]>;
    showExplanation: boolean;
    currentQuestion?: AssessmentQuestion;
    lastAnsweredQuestion?: string;
    timeRemaining?: number;
    mode: 'assessment' | 'review';
}

export interface AssessmentContent {
    id?: string;          // Added optional ID field for better tracking 
    title: string;
    description?: string;
    questions: AssessmentQuestion[];
    timeLimit?: number;
    passingScore?: number;
}