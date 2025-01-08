// src/app/features/lessons/video-player/video-player.component.ts
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
import { Subscription } from 'rxjs';
import { VideoPlayerService } from './video-player.service';
import { VideoPlayerProps, VideoState } from './video-player.types';

@Component({
  selector: 'app-video-player',
  standalone: false,
  templateUrl: './video-player.component.html',
  styleUrls: ['./video-player.component.scss'],
  providers: [VideoPlayerService] // Scoped to this component
})
export class VideoPlayerComponent implements VideoPlayerProps, OnInit, OnDestroy {
  @Input() videoUrl?: string;
  @Input() isCompleted?: boolean;
  @Output() onProgress = new EventEmitter<number>();
  @Output() onComplete = new EventEmitter<void>();

  @ViewChild('videoElement') videoElement?: ElementRef<HTMLVideoElement>;

  isYouTubeVideo = false;
  safeVideoUrl?: any;
  state!: VideoState;

  private subscriptions: Subscription[] = [];

  constructor(private videoService: VideoPlayerService) { }

  ngOnInit(): void {
    if (this.videoUrl) {
      this.isYouTubeVideo = this.videoService.isYouTubeUrl(this.videoUrl);
      if (this.isYouTubeVideo) {
        this.safeVideoUrl = this.videoService.getYouTubeEmbedUrl(this.videoUrl);
      }
    }

    // Subscribe to video state changes
    this.subscriptions.push(
      this.videoService.getState().subscribe(state => {
        this.state = state;
        this.onProgress.emit(state.progress);

        if (state.isCompleted && !this.isCompleted) {
          this.onComplete.emit();
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
    this.videoService.markAsCompleted();
  }

  togglePlay(): void {
    const video = this.videoElement?.nativeElement;
    if (!video) return;

    if (video.paused) {
      video.play();
      this.videoService.setPlaying(true);
    } else {
      video.pause();
      this.videoService.setPlaying(false);
    }
  }

  restartVideo(): void {
    const video = this.videoElement?.nativeElement;
    if (!video) return;

    video.currentTime = 0;
    video.play();
    this.videoService.setPlaying(true);
  }

  formatTime(seconds: number): string {
    return this.videoService.formatTime(seconds);
  }
}