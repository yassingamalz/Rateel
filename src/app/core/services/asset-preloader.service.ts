
// src/app/core/services/asset-preloader.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, from } from 'rxjs';
import { ContentCacheService } from './content-cache.service';
import { OfflineStorageService } from './offline-storage.service';

@Injectable({
  providedIn: 'root'
})
export class AssetPreloaderService {
  private preloadQueue: string[] = [];
  private isPreloading$ = new BehaviorSubject<boolean>(false);
  private progress$ = new BehaviorSubject<number>(0);

  constructor(
    private contentCache: ContentCacheService,
    private offlineStorage: OfflineStorageService
  ) {}

  queueAssets(assets: string[]): void {
    this.preloadQueue.push(...assets.filter(url => !this.preloadQueue.includes(url)));
  }

  async startPreloading(): Promise<void> {
    if (this.isPreloading$.value || this.preloadQueue.length === 0) {
      return;
    }

    this.isPreloading$.next(true);
    this.progress$.next(0);

    const total = this.preloadQueue.length;
    let completed = 0;

    try {
      await Promise.all(this.preloadQueue.map(async url => {
        try {
          const response = await fetch(url);
          const blob = await response.blob();
          await this.offlineStorage.storeData('assets', {
            url,
            data: blob,
            timestamp: Date.now()
          });
          completed++;
          this.progress$.next((completed / total) * 100);
        } catch (error) {
          console.error(`Failed to preload asset: ${url}`, error);
        }
      }));
    } finally {
      this.preloadQueue = [];
      this.isPreloading$.next(false);
    }
  }

  getPreloadingStatus(): Observable<boolean> {
    return this.isPreloading$.asObservable();
  }

  getProgress(): Observable<number> {
    return this.progress$.asObservable();
  }

  clearPreloadQueue(): void {
    this.preloadQueue = [];
    this.progress$.next(0);
  }
}