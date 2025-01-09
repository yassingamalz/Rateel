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

  private subscriptions: Subscription[] = [];

  constructor(private videoService: VideoPlayerService) { }

  ngOnInit(): void {
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

  handleSkip(): void {
    this.videoService.updateProgress({
      currentTime: this.videoElement?.nativeElement.duration || 0,
      duration: this.videoElement?.nativeElement.duration || 0,
      progress: 100
    });

    this.handleCompletion();
  }

  private handleCompletion(): void {
    this.videoService.markAsCompleted();
    this.onComplete.emit();
  }
}