// video-player.component.ts
import {
  Component,
  Input,
  Output,
  EventEmitter,
  ViewChild,
  ElementRef,
  OnInit,
  OnDestroy,
  ChangeDetectorRef
} from '@angular/core';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { Subscription } from 'rxjs';
import { VideoPlayerService } from './video-player.service';
import { VideoPlayerProps, VideoState } from './video-player.types';
import { PlatformService } from '../../../core/services/platform.service';

@Component({
  selector: 'app-video-player',
  standalone: false,
  templateUrl: './video-player.component.html',
  styleUrls: ['./video-player.component.scss'],
  providers: [VideoPlayerService]
})
export class VideoPlayerComponent implements VideoPlayerProps, OnInit, OnDestroy {
  @Input() videoUrl?: string;
  @Input() isCompleted?: boolean;
  @Output() onProgress = new EventEmitter<number>();
  @Output() onComplete = new EventEmitter<void>();

  @ViewChild('videoElement') videoElement?: ElementRef<HTMLVideoElement>;

  state!: VideoState;
  isYoutubeVideo = false;
  safeYoutubeUrl?: SafeResourceUrl;

  private subscriptions: Subscription[] = [];
  private skipRequested = false;
  private isCompleting = false;

  constructor(
    private videoService: VideoPlayerService,
    private sanitizer: DomSanitizer,
    private cdr: ChangeDetectorRef,
    private platformService: PlatformService
  ) { }

  ngOnInit(): void {
    // Check if it's a YouTube video and prepare URL
    if (this.videoUrl) {
      this.isYoutubeVideo = this.videoService.isYouTubeUrl(this.videoUrl);
      if (this.isYoutubeVideo) {
        this.safeYoutubeUrl = this.videoService.getYouTubeEmbedUrl(this.videoUrl);
      }
    }

    // Initialize state with completed status if lesson was already completed
    if (this.isCompleted) {
      this.videoService.updateProgress({
        currentTime: 100,
        duration: 100,
        progress: 100
      });
    }

    // Subscribe to video state changes
    this.subscriptions.push(
      this.videoService.getState().subscribe(state => {
        // Update local state
        this.state = state;
        
        // Emit progress updates
        this.onProgress.emit(state.progress);

        // Handle completion
        if (state.isCompleted && !this.isCompleted && !this.isCompleting) {
          this.handleCompletion();
        }
        
        this.cdr.detectChanges();
      })
    );
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.videoService.resetState();
  }

  onTimeUpdate(event: Event): void {
    if (this.skipRequested || this.isCompleted) return;
    
    const video = event.target as HTMLVideoElement;
    const currentTime = video.currentTime;
    const duration = video.duration;
    const progress = (currentTime / duration) * 100;

    this.videoService.updateProgress({
      currentTime,
      duration,
      progress
    });
  }

  onVideoEnded(): void {
    if (this.skipRequested || this.isCompleted) return;
    
    this.videoService.updateProgress({
      currentTime: this.videoElement?.nativeElement.duration || 0,
      duration: this.videoElement?.nativeElement.duration || 0,
      progress: 100
    });

    this.handleCompletion();
  }

  private async handleCompletion(): Promise<void> {
    if (this.isCompleting) return;
    this.isCompleting = true;

    // Update video state
    this.videoService.markAsCompleted();

    // Provide haptic feedback on mobile
    try {
      await this.platformService.vibrateSuccess();
    } catch (error) {
      console.warn('Haptic feedback not available', error);
    }

    // Emit completion event after a delay for animation
    setTimeout(() => {
      this.onComplete.emit();
      this.isCompleting = false;
      this.skipRequested = false;
    }, 1500); // Match border fill animation duration
  }

  handleSkip(): void {
    console.log("Skip button clicked, isCompleted:", this.isCompleted);
    
    // Always emit completion event immediately for any click
    this.onComplete.emit();
    
    // Add haptic feedback
    this.platformService.vibrateSuccess().catch(() => {
      // Ignore errors if vibration is not available
    });
    
    // If not already completed, also mark as completed
    if (!this.isCompleted) {
      this.videoService.updateProgress({
        currentTime: this.videoElement?.nativeElement?.duration || 100,
        duration: this.videoElement?.nativeElement?.duration || 100,
        progress: 100
      });
    }
  }
}