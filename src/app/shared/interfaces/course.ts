
export interface Course {
    id: string;
    title: string;
    description: string;
    icon?: string;
    progress?: number;
    isLocked?: boolean;
    isCompleted?: boolean; 
    imageSrc?: string;
    badge?: {
      type: 'achievement' | 'progress';
      value: string | number;
    };
  }
  