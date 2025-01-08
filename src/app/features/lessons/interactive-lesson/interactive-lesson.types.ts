// src/app/features/lessons/interactive-lesson/interactive-lesson.types.ts
export interface InteractiveQuestion {
    id: string;
    text: string;
    type: 'multiple-choice' | 'true-false' | 'pronunciation';
    options?: string[];
    correctAnswer: string | boolean;
    explanation?: string;
    audioUrl?: string;
  }
  
  export interface InteractionState {
    currentQuestionIndex: number;
    answers: Map<string, string | boolean>;
    score: number;
    isCompleted: boolean;
    progress: number;
    feedback?: string;
    isRecording?: boolean;
    currentAudio?: string;
  }
  
  export interface InteractiveLessonProps {
    questions: InteractiveQuestion[];
    isCompleted?: boolean;
    onProgress: (progress: number) => void;
    onComplete: () => void;
    onAnswer: (questionId: string, answer: string | boolean) => void;
  }
  
  export interface InteractionResult {
    questionId: string;
    userAnswer: string | boolean;
    isCorrect: boolean;
    explanation?: string;
  }