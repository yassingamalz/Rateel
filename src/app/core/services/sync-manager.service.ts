// src/app/core/services/sync-manager.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, interval } from 'rxjs';
import { filter, switchMap, catchError, tap } from 'rxjs/operators';
import { SyncStatus } from '../interfaces/sync-status';

@Injectable({
  providedIn: 'root'
})
export class SyncManagerService {
  private readonly SYNC_INTERVAL = 5 * 60 * 1000; // 5 minutes
  private status$ = new BehaviorSubject<SyncStatus>({
    lastSync: new Date(),
    isSyncing: false,
    pendingChanges: 0,
    offlineChanges: []
  });

  constructor() {
    this.initializeAutoSync();
  }

  private initializeAutoSync(): void {
    interval(this.SYNC_INTERVAL).pipe(
      filter(() => navigator.onLine && this.status$.value.pendingChanges > 0),
      switchMap(() => this.sync())
    ).subscribe();
  }

  async sync(): Promise<void> {
    if (this.status$.value.isSyncing || !navigator.onLine) {
      return;
    }

    this.status$.next({ ...this.status$.value, isSyncing: true });

    try {
      const changes = this.status$.value.offlineChanges;
      
      // Process changes in chronological order
      for (const change of changes.sort((a, b) => a.timestamp - b.timestamp)) {
        await this.processChange(change);
      }

      this.status$.next({
        lastSync: new Date(),
        isSyncing: false,
        pendingChanges: 0,
        offlineChanges: []
      });
    } catch (error) {
      console.error('Sync failed:', error);
      this.status$.next({ ...this.status$.value, isSyncing: false });
    }
  }

  private async processChange(change: SyncStatus['offlineChanges'][0]): Promise<void> {
    // Implementation will depend on your API structure
    // This is a placeholder for the actual sync logic
    console.log('Processing change:', change);
  }

  queueChange(change: SyncStatus['offlineChanges'][0]): void {
    const currentStatus = this.status$.value;
    this.status$.next({
      ...currentStatus,
      pendingChanges: currentStatus.pendingChanges + 1,
      offlineChanges: [...currentStatus.offlineChanges, change]
    });

    if (navigator.onLine) {
      this.sync();
    }
  }

  getSyncStatus(): Observable<SyncStatus> {
    return this.status$.asObservable();
  }

  clearPendingChanges(): void {
    this.status$.next({
      ...this.status$.value,
      pendingChanges: 0,
      offlineChanges: []
    });
  }

  forceSync(): Promise<void> {
    return this.sync();
  }
}