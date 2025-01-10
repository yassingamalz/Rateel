import { Directive, ElementRef, Input, NgZone, Renderer2, OnInit, OnDestroy } from '@angular/core';
import { animate, AnimationBuilder, style, keyframes } from '@angular/animations';
import { PlatformService } from '../../core/services/platform.service';

@Directive({
  selector: '[borderFillEffect]',
  standalone: true
})
export class BorderFillDirective implements OnInit, OnDestroy {
  @Input() set triggerEffect(value: boolean) {
    if (value) {
      this.startAnimation();
    }
  }

  private borderElement: HTMLElement | null = null;
  private readonly borderColor = '#DAA520';
  private readonly glowColor = '#FFE355';
  private readonly borderRadius = '1.25rem';
  
  private audioContext: AudioContext | null = null;
  private audioBuffer: AudioBuffer | null = null;
  private isAudioInitialized = false;

  constructor(
    private el: ElementRef,
    private renderer: Renderer2,
    private builder: AnimationBuilder,
    private ngZone: NgZone,
    private platformService: PlatformService
  ) {
    this.setupBorder();
    this.initializeAudio().then(() => {
      this.isAudioInitialized = true;
    });
  }

  ngOnInit() {}

  ngOnDestroy() {
    if (this.audioContext) {
      this.audioContext.close();
    }
  }

  private setupBorder() {
    this.borderElement = this.renderer.createElement('div');
    this.renderer.addClass(this.borderElement, 'border-effect');
    
    this.renderer.setStyle(this.el.nativeElement, 'position', 'relative');
    this.renderer.setStyle(this.borderElement, 'position', 'absolute');
    this.renderer.setStyle(this.borderElement, 'inset', '-1px');
    this.renderer.setStyle(this.borderElement, 'border-radius', this.borderRadius);
    this.renderer.setStyle(this.borderElement, 'border', '5px solid transparent');
    this.renderer.setStyle(this.borderElement, 'pointer-events', 'none');
    this.renderer.setStyle(this.borderElement, 'opacity', '0');
    
    this.renderer.appendChild(this.el.nativeElement, this.borderElement);
  }

  private async initializeAudio() {
    try {
      this.audioContext = new AudioContext();
      const response = await fetch('/sounds/fill-sound.mp3');
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
      
      const arrayBuffer = await response.arrayBuffer();
      this.audioBuffer = await this.audioContext.decodeAudioData(arrayBuffer);

      if (this.audioContext.state === 'suspended') {
        await this.audioContext.resume();
      }
    } catch (error) {
      console.error('Failed to initialize Web Audio:', error);
    }
  }

  private async vibrate() {
    // Four distinct vibrations to match the four sides of the border animation
    // Each vibration is timed to match the animation keyframes (0%, 25%, 50%, 75%)
    if (this.platformService.isNative) {
      // Sequence the haptics with slight delays to match animation
      setTimeout(() => this.platformService.vibrateSuccess(), 0);    // Top border
      setTimeout(() => this.platformService.vibrateSuccess(), 375);  // Right border
      setTimeout(() => this.platformService.vibrateSuccess(), 750);  // Bottom border
      setTimeout(() => this.platformService.vibrateSuccess(), 1125); // Left border
    } else if ('vibrate' in navigator) {
      // For web: [vibrate, pause] pattern matching the border fill
      // Each number represents milliseconds
      navigator.vibrate([
        75,  // Top vibration
        125, // Pause
        75,  // Right vibration
        125, // Pause
        75,  // Bottom vibration
        125, // Pause
        75,  // Left vibration
        125  // Final pause
      ]);
    }
  }

  private async playWebAudio() {
    if (!this.isAudioInitialized) {
      await new Promise(resolve => {
        const checkInit = () => {
          if (this.isAudioInitialized) {
            resolve(true);
          } else {
            setTimeout(checkInit, 50);
          }
        };
        checkInit();
      });
    }

    if (!this.audioBuffer || !this.audioContext) return;
    
    try {
      const source = this.audioContext.createBufferSource();
      source.buffer = this.audioBuffer;
      source.connect(this.audioContext.destination);
      source.start(0);
    } catch (error) {
      console.error('Web Audio playback failed:', error);
    }
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
      player.play();
      this.playWebAudio();
      this.vibrate();

      player.onDone(() => {
        if (this.borderElement) {
          this.renderer.setStyle(this.borderElement, 'opacity', '0');
          this.renderer.setStyle(this.borderElement, 'border-color', 'transparent');
        }
      });
    });
  }
}