// src/app/features/lessons/audio-player/audio-player.types.ts
import { EventEmitter } from '@angular/core';

export interface AudioState {
  isPlaying: boolean;
  currentTime: number;
  duration: number;
  progress: number;
  isCompleted: boolean;
  volume: number;
  isRecording: boolean;
}

export interface AudioProgress {
  currentTime: number;
  duration: number;
  progress: number;
}

export interface AudioPlayerProps {
  audioUrl?: string;
  isCompleted?: boolean;
  showRecorder?: boolean;
  onProgress: EventEmitter<number>;
  onComplete: EventEmitter<void>;
}

export interface RecordingSession {
  blob: Blob;
  url: string;
  duration: number;
}