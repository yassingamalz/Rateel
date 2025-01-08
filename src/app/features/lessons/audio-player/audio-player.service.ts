// src/app/features/lessons/audio-player/audio-player.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { AudioState, AudioProgress, RecordingSession } from './audio-player.types';

@Injectable({
  providedIn: 'root'
})
export class AudioPlayerService {
  private mediaRecorder?: MediaRecorder;
  private audioChunks: Blob[] = [];
  private recordingStartTime?: number;

  private state = new BehaviorSubject<AudioState>({
    isPlaying: false,
    currentTime: 0,
    duration: 0,
    progress: 0,
    isCompleted: false,
    volume: 1,
    isRecording: false
  });

  getState(): Observable<AudioState> {
    return this.state.asObservable();
  }

  updateProgress(progress: AudioProgress): void {
    const { currentTime, duration, progress: progressPercent } = progress;
    this.state.next({
      ...this.state.value,
      currentTime,
      duration,
      progress: progressPercent,
      isCompleted: progressPercent >= 100
    });
  }

  setPlaying(isPlaying: boolean): void {
    this.state.next({
      ...this.state.value,
      isPlaying
    });
  }

  setVolume(volume: number): void {
    this.state.next({
      ...this.state.value,
      volume: Math.max(0, Math.min(1, volume))
    });
  }

  async startRecording(): Promise<void> {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      this.mediaRecorder = new MediaRecorder(stream);
      this.audioChunks = [];
      this.recordingStartTime = Date.now();

      this.mediaRecorder.addEventListener('dataavailable', (event) => {
        this.audioChunks.push(event.data);
      });

      this.mediaRecorder.start();
      this.state.next({
        ...this.state.value,
        isRecording: true
      });
    } catch (error) {
      console.error('Error accessing microphone:', error);
      throw error;
    }
  }

  stopRecording(): Promise<RecordingSession> {
    return new Promise((resolve, reject) => {
      if (!this.mediaRecorder || !this.recordingStartTime) {
        reject(new Error('Recording not started'));
        return;
      }

      this.mediaRecorder.addEventListener('stop', () => {
        const duration = (Date.now() - this.recordingStartTime!) / 1000;
        const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' });
        const url = URL.createObjectURL(audioBlob);

        this.state.next({
          ...this.state.value,
          isRecording: false
        });

        resolve({ blob: audioBlob, url, duration });
      });

      this.mediaRecorder.stop();
      this.mediaRecorder.stream.getTracks().forEach(track => track.stop());
    });
  }

  resetState(): void {
    if (this.mediaRecorder?.state === 'recording') {
      this.mediaRecorder.stop();
      this.mediaRecorder.stream.getTracks().forEach(track => track.stop());
    }

    this.state.next({
      isPlaying: false,
      currentTime: 0,
      duration: 0,
      progress: 0,
      isCompleted: false,
      volume: 1,
      isRecording: false
    });
  }

  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = Math.floor(seconds % 60);
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
  }

  markAsCompleted(): void {
    this.state.next({
      ...this.state.value,
      isCompleted: true,
      progress: 100
    });
  }
}