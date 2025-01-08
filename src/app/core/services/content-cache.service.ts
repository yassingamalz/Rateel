// src/app/core/services/content-cache.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, from, of } from 'rxjs';
import { map, catchError, tap } from 'rxjs/operators';
import { CacheConfig } from '../interfaces/cache-config';
import { CachedContent } from '../interfaces/cached-content.interface';

@Injectable({
  providedIn: 'root'
})
export class ContentCacheService {
  private readonly CACHE_CONFIG: CacheConfig = {
    version: '1.0',
    maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    maxItems: 1000,
    priorityLevels: {
      CRITICAL: 1,
      HIGH: 2,
      MEDIUM: 3,
      LOW: 4
    }
  };

  private cache = new Map<string, CachedContent<any>>();
  private cacheSize$ = new BehaviorSubject<number>(0);

  constructor() {
    this.initializeCache();
  }

  private async initializeCache(): Promise<void> {
    try {
      const storedCache = localStorage.getItem('appCache');
      if (storedCache) {
        const parsedCache = JSON.parse(storedCache);
        this.cache = new Map(Object.entries(parsedCache));
        this.updateCacheSize();
      }
    } catch (error) {
      console.error('Cache initialization failed:', error);
    }
  }

  private updateCacheSize(): void {
    this.cacheSize$.next(this.cache.size);
  }

  setItem<T>(key: string, data: T, priority: number = this.CACHE_CONFIG.priorityLevels.MEDIUM): void {
    const timestamp = Date.now();
    const cachedContent: CachedContent<T> = {
      data,
      timestamp,
      expiresAt: timestamp + this.CACHE_CONFIG.maxAge,
      priority,
      version: this.CACHE_CONFIG.version
    };

    if (this.cache.size >= this.CACHE_CONFIG.maxItems) {
      this.evictLeastImportant();
    }

    this.cache.set(key, cachedContent);
    this.persistCache();
    this.updateCacheSize();
  }

  getItem<T>(key: string): Observable<T | null> {
    const cached = this.cache.get(key);
    
    if (!cached) {
      return of(null);
    }

    if (Date.now() > cached.expiresAt) {
      this.cache.delete(key);
      this.persistCache();
      this.updateCacheSize();
      return of(null);
    }

    return of(cached.data as T);
  }

  private evictLeastImportant(): void {
    let leastImportantKey: string | null = null;
    let lowestPriority = Infinity;
    let oldestTimestamp = Infinity;

    this.cache.forEach((content, key) => {
      if (content.priority > lowestPriority || 
         (content.priority === lowestPriority && content.timestamp < oldestTimestamp)) {
        lowestPriority = content.priority;
        oldestTimestamp = content.timestamp;
        leastImportantKey = key;
      }
    });

    if (leastImportantKey) {
      this.cache.delete(leastImportantKey);
    }
  }

  private persistCache(): void {
    try {
      const cacheObject = Object.fromEntries(this.cache);
      localStorage.setItem('appCache', JSON.stringify(cacheObject));
    } catch (error) {
      console.error('Cache persistence failed:', error);
    }
  }

  getCacheSize(): Observable<number> {
    return this.cacheSize$.asObservable();
  }

  clearCache(): void {
    this.cache.clear();
    localStorage.removeItem('appCache');
    this.updateCacheSize();
  }
}
