import { Directive, ElementRef, Input, NgZone, Renderer2, OnInit, OnDestroy } from '@angular/core';
import { animate, AnimationBuilder, style } from '@angular/animations';
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
    if (this.platformService.isNative) {
      setTimeout(() => this.platformService.vibrateSuccess(), 0);   
      setTimeout(() => this.platformService.vibrateSuccess(), 375); 
      setTimeout(() => this.platformService.vibrateSuccess(), 750); 
      setTimeout(() => this.platformService.vibrateSuccess(), 1125);
    } else if ('vibrate' in navigator) {
      navigator.vibrate([75, 125, 75, 125, 75, 125, 75, 125]);
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
    this.ngZone.runOutsideAngular(() => {
      // Add animation-active class to trigger component-specific animations
      this.renderer.addClass(this.el.nativeElement, 'border-fill-animation-active');
      
      // Handle audio and haptic feedback
      this.playWebAudio();
      this.vibrate();

      // Remove animation class after completion
      setTimeout(() => {
        this.renderer.removeClass(this.el.nativeElement, 'border-fill-animation-active');
      }, 1500); // Match animation duration
    });
  }
}