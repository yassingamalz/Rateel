// audio-player.component.ts
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
import { AudioPlayerService } from './audio-player.service';
import { AudioPlayerProps, AudioState, RecordingSession } from './audio-player.types';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-audio-player',
  standalone: false,
  templateUrl: './audio-player.component.html',
  styleUrls: ['./audio-player.component.scss'],
  providers: [AudioPlayerService]
})
export class AudioPlayerComponent implements AudioPlayerProps, OnInit, OnDestroy {
  @Input() audioUrl?: string;
  @Input() isCompleted?: boolean;
  @Input() showRecorder = false;
  @Output() onProgress = new EventEmitter<number>();
  @Output() onComplete = new EventEmitter<void>();
  @Output() onRecordingComplete = new EventEmitter<RecordingSession>();

  @ViewChild('audioElement') audioElement?: ElementRef<HTMLAudioElement>;

  state!: AudioState;
  recordedAudioUrl?: string;
  private subscriptions: Subscription[] = [];

  constructor(private audioService: AudioPlayerService) { }

  ngOnInit(): void {
    this.subscriptions.push(
      this.audioService.getState().subscribe(state => {
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
    this.audioService.resetState();
    if (this.recordedAudioUrl) {
      URL.revokeObjectURL(this.recordedAudioUrl);
    }
  }

  onTimeUpdate(event: Event): void {
    const audio = event.target as HTMLAudioElement;
    const currentTime = audio.currentTime;
    const duration = audio.duration;
    const progress = (currentTime / duration) * 100;

    this.audioService.updateProgress({
      currentTime,
      duration,
      progress
    });
  }

  onAudioEnded(): void {
    this.audioService.markAsCompleted();
  }

  togglePlay(): void {
    const audio = this.audioElement?.nativeElement;
    if (!audio) return;

    if (audio.paused) {
      audio.play();
      this.audioService.setPlaying(true);
    } else {
      audio.pause();
      this.audioService.setPlaying(false);
    }
  }

  restartAudio(): void {
    const audio = this.audioElement?.nativeElement;
    if (!audio) return;

    audio.currentTime = 0;
    audio.play();
    this.audioService.setPlaying(true);
  }

  onVolumeChange(event: Event): void {
    const audio = this.audioElement?.nativeElement;
    if (!audio) return;

    const input = event.target as HTMLInputElement;
    const volume = Number(input.value) / 100;
    audio.volume = volume;
    this.audioService.setVolume(volume);
  }

  async toggleRecording(): Promise<void> {
    if (this.state.isRecording) {
      try {
        const recording = await this.audioService.stopRecording();
        this.recordedAudioUrl = recording.url;
        this.onRecordingComplete.emit(recording);
      } catch (error) {
        console.error('Error stopping recording:', error);
      }
    } else {
      try {
        await this.audioService.startRecording();
      } catch (error) {
        console.error('Error starting recording:', error);
      }
    }
  }

  seekTo(event: MouseEvent): void {
    const audio = this.audioElement?.nativeElement;
    if (!audio) return;

    const progressBar = event.currentTarget as HTMLElement;
    const rect = progressBar.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const percentage = (x / rect.width) * 100;

    audio.currentTime = (percentage / 100) * audio.duration;
  }

  formatTime(seconds: number): string {
    return this.audioService.formatTime(seconds);
  }
}