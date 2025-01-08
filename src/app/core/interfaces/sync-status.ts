  // src/app/core/interfaces/sync-status.interface.ts
  export interface SyncStatus {
    lastSync: Date;
    isSyncing: boolean;
    pendingChanges: number;
    offlineChanges: {
      courseId: string;
      type: 'progress' | 'completion';
      timestamp: number;
    }[];
  }