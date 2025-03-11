// src/app/shared/components/modal/modal.component.ts
import {
  Component,
  Input,
  Output,
  EventEmitter,
  OnInit,
  OnDestroy,
  HostListener,
  ElementRef,
  ViewChild,
  ChangeDetectionStrategy,
  ChangeDetectorRef
} from '@angular/core';
import { trigger, transition, style, animate } from '@angular/animations';

@Component({
  selector: 'app-modal',
  standalone: false,
  templateUrl: './modal.component.html',
  styleUrls: ['./modal.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('modalAnimation', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('300ms cubic-bezier(0.4, 0.0, 0.2, 1)', style({ opacity: 1 }))
      ]),
      transition(':leave', [
        animate('200ms cubic-bezier(0.4, 0.0, 0.2, 1)', style({ opacity: 0 }))
      ])
    ]),
    trigger('contentAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.8)' }),
        animate('300ms cubic-bezier(0.4, 0.0, 0.2, 1)', style({ opacity: 1, transform: 'scale(1)' }))
      ]),
      transition(':leave', [
        animate('200ms cubic-bezier(0.4, 0.0, 0.2, 1)', style({ opacity: 0, transform: 'scale(0.8)' }))
      ])
    ])
  ]
})
export class ModalComponent implements OnInit, OnDestroy {
  @ViewChild('modalContent') modalContent!: ElementRef;

  @Input() isOpen = false;
  @Input() closeOnBackdropClick = true;
  @Input() closeOnEscape = true;
  @Input() size: 'sm' | 'md' | 'lg' | 'xl' | 'fullscreen' = 'md';
  @Input() position: 'center' | 'top' | 'bottom' = 'center';
  @Input() showCloseButton = true;
  @Input() customClass = '';

  @Output() closed = new EventEmitter<void>();

  constructor(
    private elementRef: ElementRef,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    if (this.isOpen) {
      this.preventBodyScroll();
    }
  }

  ngOnDestroy(): void {
    this.enableBodyScroll();
  }

  @HostListener('document:keydown.escape')
  onEscapePress(): void {
    if (this.isOpen && this.closeOnEscape) {
      this.close();
    }
  }

  onBackdropClick(event: MouseEvent): void {
    if (
      this.closeOnBackdropClick &&
      event.target === this.elementRef.nativeElement.querySelector('.modal-overlay')
    ) {
      this.close();
    }
  }

  close(): void {
    this.isOpen = false;
    this.enableBodyScroll();
    this.closed.emit();
    this.cdr.markForCheck();
  }

  private preventBodyScroll(): void {
    document.body.style.overflow = 'hidden';
    document.body.style.paddingRight = this.getScrollbarWidth() + 'px';
  }

  private enableBodyScroll(): void {
    document.body.style.overflow = '';
    document.body.style.paddingRight = '';
  }

  private getScrollbarWidth(): number {
    // Create a temporary div to measure scrollbar width
    const outer = document.createElement('div');
    outer.style.visibility = 'hidden';
    outer.style.width = '100px';
    (outer.style as any).msOverflowStyle = 'scrollbar';
    document.body.appendChild(outer);

    const widthNoScroll = outer.offsetWidth;
    outer.style.overflow = 'scroll';

    const inner = document.createElement('div');
    inner.style.width = '100%';
    outer.appendChild(inner);

    const widthWithScroll = inner.offsetWidth;
    outer.parentNode!.removeChild(outer);

    return widthNoScroll - widthWithScroll;
  }
}