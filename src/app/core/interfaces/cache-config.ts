// src/app/core/interfaces/cache-config.interface.ts
export interface CacheConfig {
    version: string;
    maxAge: number;
    maxItems: number;
    priorityLevels: {
      CRITICAL: 1;
      HIGH: 2;
      MEDIUM: 3;
      LOW: 4;
    };
  }
