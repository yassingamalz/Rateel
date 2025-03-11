// src/app/shared/components/modal-host/modal-host.component.ts
import { Component, OnInit, OnDestroy, ViewContainerRef, ViewChild, ElementRef, ChangeDetectorRef } from '@angular/core';

@Component({
  selector: 'app-modal-host',
  standalone: false,
  template: `
    <div class="modal-host-container">
      <ng-container #modalHost></ng-container>
    </div>
  `,
  styles: [`
    .modal-host-container {
      position: fixed;
      pointer-events: none;
      z-index: 999999;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
    }
  `]
})
export class ModalHostComponent implements OnInit, OnDestroy {
  @ViewChild('modalHost', { read: ViewContainerRef, static: true }) modalHost!: ViewContainerRef;

  constructor(
    private elementRef: ElementRef,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    // Make sure this component is attached to the body
    this.moveToBody();
  }

  ngOnDestroy(): void {
    // Clean up if needed
  }

  private moveToBody(): void {
    // Move this component to the document body 
    if (document.body && this.elementRef.nativeElement.parentElement !== document.body) {
      document.body.appendChild(this.elementRef.nativeElement);
    }
  }

  // Method to force change detection when modals are added dynamically
  markForCheck(): void {
    this.cdr.markForCheck();
  }
}