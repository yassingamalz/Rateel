// border-fill.directive.ts
import { Directive, ElementRef, Input, NgZone, Renderer2 } from '@angular/core';
import { animate, AnimationBuilder, style, keyframes } from '@angular/animations';

@Directive({
  selector: '[borderFillEffect]',
  standalone: true
})
export class BorderFillDirective {
  @Input() set triggerEffect(value: boolean) {
    if (value) {
      this.startAnimation();
    }
  }

  private borderElement: HTMLElement | null = null;
  // Using your exact theme colors
  private readonly borderColor = '#DAA520'; // accent.base
  private readonly glowColor = '#FFE355';   // accent.glow
  private readonly borderRadius = '1.25rem'; // border-radius.lg (20px)

  constructor(
    private el: ElementRef,
    private renderer: Renderer2,
    private builder: AnimationBuilder,
    private ngZone: NgZone
  ) {
    this.setupBorder();
  }

  private setupBorder() {
    this.borderElement = this.renderer.createElement('div');
    this.renderer.addClass(this.borderElement, 'border-effect');
    
    this.renderer.setStyle(this.el.nativeElement, 'position', 'relative');
    this.renderer.setStyle(this.borderElement, 'position', 'absolute');
    this.renderer.setStyle(this.borderElement, 'inset', '-1px');
    this.renderer.setStyle(this.borderElement, 'border-radius', this.borderRadius);
    this.renderer.setStyle(this.borderElement, 'border', '2px solid transparent');
    this.renderer.setStyle(this.borderElement, 'pointer-events', 'none');
    this.renderer.setStyle(this.borderElement, 'opacity', '0');
    
    this.renderer.appendChild(this.el.nativeElement, this.borderElement);
  }

  private startAnimation() {
    if (!this.borderElement) return;
    
    this.ngZone.runOutsideAngular(() => {
      this.renderer.setStyle(this.borderElement, 'opacity', '1');
      
      const animation = this.builder.build([
        animate('1.5s cubic-bezier(0.4, 0, 0.2, 1)', keyframes([
          style({ 
            borderTopColor: this.borderColor,
            borderRightColor: 'transparent',
            borderBottomColor: 'transparent',
            borderLeftColor: 'transparent',
            filter: `drop-shadow(0 0 6px ${this.glowColor})`,
            offset: 0 
          }),
          style({ 
            borderTopColor: this.borderColor,
            borderRightColor: this.borderColor,
            borderBottomColor: 'transparent',
            borderLeftColor: 'transparent',
            filter: `drop-shadow(0 0 6px ${this.glowColor})`,
            offset: 0.25 
          }),
          style({ 
            borderTopColor: this.borderColor,
            borderRightColor: this.borderColor,
            borderBottomColor: this.borderColor,
            borderLeftColor: 'transparent',
            filter: `drop-shadow(0 0 6px ${this.glowColor})`,
            offset: 0.5 
          }),
          style({ 
            borderTopColor: this.borderColor,
            borderRightColor: this.borderColor,
            borderBottomColor: this.borderColor,
            borderLeftColor: this.borderColor,
            filter: `drop-shadow(0 0 6px ${this.glowColor})`,
            offset: 0.75 
          }),
          style({ 
            opacity: 0,
            offset: 1 
          })
        ]))
      ]);

      const player = animation.create(this.borderElement);
      const audio = new Audio('assets/sounds/fill-sound.mp3');
      
      player.play();
      audio.play();

      // Clean up after animation
      player.onDone(() => {
        if (this.borderElement) {
          this.renderer.setStyle(this.borderElement, 'opacity', '0');
          this.renderer.setStyle(this.borderElement, 'border-color', 'transparent');
        }
      });
    });
  }
}