import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { InitializationComponent } from './initialization/initialization.component';
import { SplashScreenComponent } from './splash-screen/splash-screen.component';
import { AssetPreloaderService } from './services/asset-preloader.service';
import { ContentCacheService } from './services/content-cache.service';
import { OfflineStorageService } from './services/offline-storage.service';
import { SyncManagerService } from './services/sync-manager.service';



@NgModule({
  declarations: [
    InitializationComponent,
    SplashScreenComponent,
  ],
  imports: [
    CommonModule
  ],
  providers: [
    ContentCacheService,
    OfflineStorageService,
    AssetPreloaderService,
    SyncManagerService
  ],
  exports: [SplashScreenComponent]
})
export class CoreModule { }
