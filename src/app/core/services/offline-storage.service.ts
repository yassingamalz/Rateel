
// src/app/core/services/offline-storage.service.ts
import { Injectable } from '@angular/core';
import { Observable, from, of } from 'rxjs';
import { map, catchError } from 'rxjs/operators';
import { StorageMeta } from '../interfaces/storage-meta.interface';

@Injectable({
  providedIn: 'root'
})
export class OfflineStorageService {
  private readonly DB_NAME = 'tajweedAppDB';
  private readonly DB_VERSION = 1;
  private db!: IDBDatabase;

  constructor() {
    this.initializeDB();
  }

  private initializeDB(): Promise<void> {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.DB_NAME, this.DB_VERSION);

      request.onerror = () => reject(request.error);

      request.onsuccess = () => {
        this.db = request.result;
        resolve();
      };

      request.onupgradeneeded = (event) => {
        const db = (event.target as IDBOpenDBRequest).result;

        // Create object stores
        if (!db.objectStoreNames.contains('courses')) {
          db.createObjectStore('courses', { keyPath: 'id' });
        }
        if (!db.objectStoreNames.contains('units')) {
          db.createObjectStore('units', { keyPath: 'id' });
        }
        if (!db.objectStoreNames.contains('lessons')) {
          db.createObjectStore('lessons', { keyPath: 'id' });
        }
        if (!db.objectStoreNames.contains('assets')) {
          db.createObjectStore('assets', { keyPath: 'url' });
        }
        if (!db.objectStoreNames.contains('meta')) {
          const metaStore = db.createObjectStore('meta', { keyPath: 'courseId' });
          metaStore.createIndex('lastAccessed', 'lastAccessed');
          metaStore.createIndex('priority', 'priority');
        }
      };
    });
  }

  async storeData<T>(storeName: string, data: T): Promise<void> {
    return new Promise((resolve, reject) => {
      const transaction = this.db.transaction(storeName, 'readwrite');
      const store = transaction.objectStore(storeName);
      const request = store.put(data);

      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }

  getData<T>(storeName: string, key: string): Observable<T | null> {
    return from(new Promise<T | null>((resolve, reject) => {
      const transaction = this.db.transaction(storeName, 'readonly');
      const store = transaction.objectStore(storeName);
      const request = store.get(key);

      request.onsuccess = () => resolve(request.result || null);
      request.onerror = () => reject(request.error);
    })).pipe(
      catchError(error => {
        console.error(`Error retrieving data from ${storeName}:`, error);
        return of(null);
      })
    );
  }

  async storeMeta(meta: StorageMeta): Promise<void> {
    return this.storeData('meta', meta);
  }

  getMeta(courseId: string): Observable<StorageMeta | null> {
    return this.getData<StorageMeta>('meta', courseId);
  }

  async removeData(storeName: string, key: string): Promise<void> {
    return new Promise((resolve, reject) => {
      const transaction = this.db.transaction(storeName, 'readwrite');
      const store = transaction.objectStore(storeName);
      const request = store.delete(key);

      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }

  async clearStorage(): Promise<void> {
    const stores = ['courses', 'units', 'lessons', 'assets', 'meta'];
    
    return Promise.all(stores.map(storeName => 
      new Promise<void>((resolve, reject) => {
        const transaction = this.db.transaction(storeName, 'readwrite');
        const store = transaction.objectStore(storeName);
        const request = store.clear();

        request.onsuccess = () => resolve();
        request.onerror = () => reject(request.error);
      })
    )).then(() => void 0);
  }
}


