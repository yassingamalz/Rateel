// border-fill.directive.ts
import { Directive, ElementRef, Input, NgZone, Renderer2 } from '@angular/core';
import { animate, AnimationBuilder, style } from '@angular/animations';

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

  constructor(
    private el: ElementRef,
    private renderer: Renderer2,
    private builder: AnimationBuilder,
    private ngZone: NgZone
  ) {
    this.setupBorder();
  }

  private setupBorder() {
    const borderElement = this.renderer.createElement('div');
    this.renderer.addClass(borderElement, 'border-effect');
    this.renderer.setStyle(this.el.nativeElement, 'position', 'relative');
    this.renderer.setStyle(borderElement, 'position', 'absolute');
    this.renderer.setStyle(borderElement, 'inset', '0');
    this.renderer.setStyle(borderElement, 'border', '2px solid #FFD700');
    this.renderer.setStyle(borderElement, 'box-shadow', '0 0 10px #FFD700');
    this.renderer.setStyle(borderElement, 'pointer-events', 'none');
    this.renderer.setStyle(borderElement, 'clip-path', 'polygon(0 0, 0 0, 0 0)');
    
    this.renderer.appendChild(this.el.nativeElement, borderElement);
  }

  private startAnimation() {
    this.ngZone.runOutsideAngular(() => {
      const borderElement = this.el.nativeElement.querySelector('.border-effect');
      const animation = this.builder.build([
        style({ clipPath: 'polygon(0 0, 0 0, 0 0)' }),
        animate('1s cubic-bezier(0.4, 0, 0.2, 1)', 
          style({ clipPath: 'polygon(0 0, 100% 0, 100% 100%, 0 100%)' })
        )
      ]);

      const player = animation.create(borderElement);
      player.play();

      // Play sound
      const audio = new Audio('assets/sounds/fill-sound.mp3');
      audio.play();
    });
  }
}