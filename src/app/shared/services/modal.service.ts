// src/app/shared/services/modal.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';

export interface ModalConfig {
  id: string;
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'fullscreen';
  position?: 'center' | 'top' | 'bottom';
  closeOnBackdropClick?: boolean;
  closeOnEscape?: boolean;
  showCloseButton?: boolean;
  customClass?: string;
  data?: any;
}

export interface ModalState extends ModalConfig {
  isOpen: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class ModalService {
  private modalsState = new BehaviorSubject<ModalState[]>([]);

  constructor() { }

  getModalsState(): Observable<ModalState[]> {
    return this.modalsState.asObservable();
  }

  getModalState(id: string): Observable<ModalState | undefined> {
    return new Observable<ModalState | undefined>(observer => {
      const subscription = this.modalsState.subscribe(modals => {
        const modal = modals.find(m => m.id === id);
        observer.next(modal);
      });

      return () => subscription.unsubscribe();
    });
  }

  isModalOpen(id: string): boolean {
    return !!this.modalsState.value.find(m => m.id === id && m.isOpen);
  }

  getAllOpenModals(): ModalState[] {
    return this.modalsState.value.filter(m => m.isOpen);
  }

  open(config: ModalConfig): void {
    const currentModals = this.modalsState.value;
    const existingModal = currentModals.find(m => m.id === config.id);

    if (existingModal) {
      // Update existing modal
      this.modalsState.next(
        currentModals.map(m =>
          m.id === config.id
            ? { ...m, ...config, isOpen: true }
            : m
        )
      );
    } else {
      // Add new modal
      this.modalsState.next([
        ...currentModals,
        {
          ...config,
          isOpen: true,
          size: config.size || 'md',
          position: config.position || 'center',
          closeOnBackdropClick: config.closeOnBackdropClick !== false,
          closeOnEscape: config.closeOnEscape !== false,
          showCloseButton: config.showCloseButton !== false,
          customClass: config.customClass || ''
        }
      ]);
    }
  }

  close(id: string): void {
    const currentModals = this.modalsState.value;
    this.modalsState.next(
      currentModals.map(m =>
        m.id === id ? { ...m, isOpen: false } : m
      )
    );
  }

  closeAll(): void {
    const currentModals = this.modalsState.value;
    this.modalsState.next(
      currentModals.map(m => ({ ...m, isOpen: false }))
    );
  }

  updateData(id: string, data: any): void {
    const currentModals = this.modalsState.value;
    this.modalsState.next(
      currentModals.map(m =>
        m.id === id ? { ...m, data } : m
      )
    );
  }

  // Clean up closed modals to prevent memory leaks
  removeClosedModals(): void {
    const currentModals = this.modalsState.value;
    this.modalsState.next(currentModals.filter(m => m.isOpen));
  }
}