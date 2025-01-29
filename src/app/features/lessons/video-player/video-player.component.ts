// video-player.component.ts
import {
  Component,
  Input,
  Output,
  EventEmitter,
  ViewChild,
  ElementRef,
  OnInit,
  OnDestroy
} from '@angular/core';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { Subscription } from 'rxjs';
import { VideoPlayerService } from './video-player.service';
import { VideoPlayerProps, VideoState } from './video-player.types';

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
  private isCompleting = false;

  constructor(
    private videoService: VideoPlayerService,
  ) { }

  ngOnInit(): void {
    // Check if it's a YouTube video and prepare URL
    if (this.videoUrl) {
      this.isYoutubeVideo = this.videoService.isYouTubeUrl(this.videoUrl);
      if (this.isYoutubeVideo) {
        this.safeYoutubeUrl = this.videoService.getYouTubeEmbedUrl(this.videoUrl);
      }
    }

    // Subscribe to video state changes
    this.subscriptions.push(
      this.videoService.getState().subscribe(state => {
        this.state = state;
        this.onProgress.emit(state.progress);

        if (state.isCompleted && !this.isCompleted) {
          this.handleCompletion();
        }
      })
    );
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.videoService.resetState();
  }

  onTimeUpdate(event: Event): void {
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
    this.videoService.updateProgress({
      currentTime: this.videoElement?.nativeElement.duration || 0,
      duration: this.videoElement?.nativeElement.duration || 0,
      progress: 100
    });

    this.handleCompletion();
  }


  private handleCompletion(): void {
    if (this.isCompleting) return;
    this.isCompleting = true;

    // Update video state
    this.videoService.markAsCompleted();

    // Increase delay to allow border fill animation
    setTimeout(() => {
      this.onComplete.emit();
      this.isCompleting = false;
    }, 1500); // Match border fill animation duration
  }

  handleSkip(): void {
    if (this.isCompleting) return;

    this.videoService.updateProgress({
      currentTime: this.videoElement?.nativeElement.duration || 0,
      duration: this.videoElement?.nativeElement.duration || 0,
      progress: 100
    });

    this.handleCompletion();
  }

}