    
  // src/app/core/interfaces/storage-meta.interface.ts
  export interface StorageMeta {
    courseId: string;
    unitIds: string[];
    lessonIds: string[];
    assets: {
      url: string;
      type: 'image' | 'audio' | 'video';
      size: number;
    }[];
    lastAccessed: number;
    priority: number;
  }