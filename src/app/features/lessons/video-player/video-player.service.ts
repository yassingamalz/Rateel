// src/app/features/lessons/video-player/video-player.service.ts
import { Injectable } from '@angular/core';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { BehaviorSubject, Observable } from 'rxjs';
import { VideoState, VideoProgress } from './video-player.types';

@Injectable({
  providedIn: 'root'
})
export class VideoPlayerService {
  private readonly YOUTUBE_REGEX = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;

  private state = new BehaviorSubject<VideoState>({
    isPlaying: false,
    currentTime: 0,
    duration: 0,
    progress: 0,
    isCompleted: false
  });

  constructor(private sanitizer: DomSanitizer) { }

  getState(): Observable<VideoState> {
    return this.state.asObservable();
  }

  isYouTubeUrl(url?: string): boolean {
    if (!url) return false;
    return this.YOUTUBE_REGEX.test(url);
  }

  getYouTubeEmbedUrl(url: string): SafeResourceUrl {
    const match = url.match(this.YOUTUBE_REGEX);
    const videoId = match && match[2].length === 11 ? match[2] : null;

    if (!videoId) {
      throw new Error('Invalid YouTube URL');
    }

    // Add parameters:
    // - enablejsapi=1: Enables the JavaScript API
    // - rel=0: Don't show related videos at the end
    // - modestbranding=1: Minimal YouTube branding
    // - playsinline=1: Play inline on mobile devices
    // - controls=1: Show video controls
    const embedUrl = `https://www.youtube.com/embed/${videoId}?enablejsapi=1&rel=0&modestbranding=1&playsinline=1&controls=1`;
    return this.sanitizer.bypassSecurityTrustResourceUrl(embedUrl);
  }

  updateProgress(progress: VideoProgress): void {
    const { currentTime, duration, progress: progressPercent } = progress;
    
    // Calculate completion status
    const isCompleted = progressPercent >= 100;
    
    this.state.next({
      ...this.state.value,
      currentTime,
      duration,
      progress: progressPercent,
      isCompleted
    });
  }

  setPlaying(isPlaying: boolean): void {
    this.state.next({
      ...this.state.value,
      isPlaying
    });
  }

  markAsCompleted(): void {
    // Only update if not already completed
    if (!this.state.value.isCompleted) {
      this.state.next({
        ...this.state.value,
        isCompleted: true,
        progress: 100
      });
    }
  }

  resetState(): void {
    this.state.next({
      isPlaying: false,
      currentTime: 0,
      duration: 0,
      progress: 0,
      isCompleted: false
    });
  }

  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = Math.floor(seconds % 60);
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
  }
}