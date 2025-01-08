  // src/app/core/interfaces/cached-content.interface.ts
  export interface CachedContent<T> {
    data: T;
    timestamp: number;
    expiresAt: number;
    priority: number;
    version: string;
  }