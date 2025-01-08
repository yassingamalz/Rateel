// src/app/core/initialization/initialization.component.ts
import { Component, OnInit, ChangeDetectionStrategy, ChangeDetectorRef } from '@angular/core';
import { Router } from '@angular/router';
import { ContentCacheService } from '../services/content-cache.service';
import { OfflineStorageService } from '../services/offline-storage.service';
import { AssetPreloaderService } from '../services/asset-preloader.service';
import { SyncManagerService } from '../services/sync-manager.service';
import { BehaviorSubject, firstValueFrom } from 'rxjs';

@Component({
  selector: 'app-initialization',
  standalone: false,
  templateUrl: './initialization.component.html',
  styleUrls: ['./initialization.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class InitializationComponent implements OnInit {
  progress$ = new BehaviorSubject<number>(0);
  currentTask$ = new BehaviorSubject<string>('Initializing...');
  isError = false;
  errorMessage = '';

  private readonly CRITICAL_ASSETS = [
    // Add your critical asset URLs here
  ];

  constructor(
    private router: Router,
    private contentCache: ContentCacheService,
    private offlineStorage: OfflineStorageService,
    private assetPreloader: AssetPreloaderService,
    private syncManager: SyncManagerService,
    private cdr: ChangeDetectorRef
  ) { }

  async ngOnInit(): Promise<void> {
    try {
      await this.initializeApp();
      await this.router.navigate(['/courses']);
    } catch (error) {
      this.handleError(error);
    }
  }

  private async initializeApp(): Promise<void> {
    // Initialize core services
    this.updateProgress('Initializing core services...', 10);
    await this.initializeCoreServices();

    // Preload critical assets
    this.updateProgress('Loading essential content...', 30);
    await this.preloadCriticalAssets();

    // Sync offline changes if online
    if (navigator.onLine) {
      this.updateProgress('Syncing offline changes...', 60);
      await this.syncManager.sync();
    }

    // Final initialization steps
    this.updateProgress('Finalizing setup...', 90);
    await this.finalizeSetup();

    this.updateProgress('Ready!', 100);
  }

  private async initializeCoreServices(): Promise<void> {
    // Additional initialization logic
    await Promise.all([
      firstValueFrom(this.contentCache.getCacheSize()),
      // Add other initialization promises
    ]);
  }

  private async preloadCriticalAssets(): Promise<void> {
    this.assetPreloader.queueAssets(this.CRITICAL_ASSETS);
    await this.assetPreloader.startPreloading();
  }

  private async finalizeSetup(): Promise<void> {
    // Any final setup tasks
    await new Promise(resolve => setTimeout(resolve, 500));
  }

  private updateProgress(task: string, progress: number): void {
    this.currentTask$.next(task);
    this.progress$.next(progress);
    this.cdr.detectChanges();
  }

  private handleError(error: any): void {
    console.error('Initialization error:', error);
    this.isError = true;
    this.errorMessage = 'Failed to initialize app. Please try again.';
    this.cdr.detectChanges();
  }

  retry(): void {
    this.isError = false;
    this.errorMessage = '';
    this.progress$.next(0);
    this.ngOnInit();
  }
}