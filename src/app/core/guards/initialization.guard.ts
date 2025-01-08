// src/app/core/guards/initialization.guard.ts
import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { ContentCacheService } from '../services/content-cache.service';
import { Observable, of } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class InitializationGuard implements CanActivate {
  constructor(
    private contentCache: ContentCacheService,
    private router: Router
  ) {}

  canActivate(): Observable<boolean> {
    return this.contentCache.getCacheSize().pipe(
      map(size => {
        if (size === 0) {
          this.router.navigate(['/initialization']);
          return false;
        }
        return true;
      })
    );
  }
}