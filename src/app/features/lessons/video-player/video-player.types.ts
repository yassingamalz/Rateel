// src/app/features/lessons/video-player/video-player.types.ts
import { EventEmitter } from '@angular/core';

export interface VideoState {
  isPlaying: boolean;
  currentTime: number;
  duration: number;
  progress: number;
  isCompleted: boolean;
}

export interface VideoProgress {
  currentTime: number;
  duration: number;
  progress: number;
}

export interface VideoPlayerProps {
  videoUrl?: string;
  isCompleted?: boolean;
  onProgress: EventEmitter<number>;
  onComplete: EventEmitter<void>;
}

export interface YouTubePlayerVars {
  autoplay?: 0 | 1;
  controls?: 0 | 1;
  rel?: 0 | 1;
  fs?: 0 | 1;
  modestbranding?: 1;
}