import { Injectable } from '@angular/core';
import { Capacitor } from '@capacitor/core';
import { VoiceRecorder, RecordingData } from 'capacitor-voice-recorder';
import { Haptics, ImpactStyle, NotificationType } from '@capacitor/haptics';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class PlatformService {
  private recorderInitialized = false;
  private permissionStatus = new BehaviorSubject<boolean>(false);

  get isNative(): boolean {
    return Capacitor.isNativePlatform();
  }

  async initializeMicrophone(): Promise<boolean> {
    if (!this.isNative) {
      return true;
    }

    try {
      const hasPermission = await VoiceRecorder.hasAudioRecordingPermission();
      
      if (hasPermission.value) {
        this.permissionStatus.next(true);
        this.recorderInitialized = true;
        return true;
      }

      const permission = await VoiceRecorder.requestAudioRecordingPermission();
      this.permissionStatus.next(permission.value);
      this.recorderInitialized = permission.value;
      
      return permission.value;
    } catch (error) {
      console.error('Error initializing microphone:', error);
      return false;
    }
  }

  async startRecording(): Promise<void> {
    if (!this.isNative) return;

    const hasPermission = await VoiceRecorder.hasAudioRecordingPermission();
    if (!hasPermission.value) {
      const granted = await this.initializeMicrophone();
      if (!granted) {
        throw new Error('Microphone permission denied');
      }
    }

    try {
      await VoiceRecorder.startRecording();
    } catch (error) {
      console.error('Error starting recording:', error);
      throw error;
    }
  }

  async stopRecording(): Promise<RecordingData> {
    if (!this.isNative) {
      return {
        value: {
          recordDataBase64: '',
          msDuration: 0,
          mimeType: 'audio/wav'
        }
      };
    }

    try {
      const recording = await VoiceRecorder.stopRecording();
      return recording;
    } catch (error) {
      console.error('Error stopping recording:', error);
      throw error;
    }
  }

  async vibrateSuccess(): Promise<void> {
    if (this.isNative) {
      await Haptics.impact({ style: ImpactStyle.Light });
    }
  }

  async vibrateError(): Promise<void> {
    if (this.isNative) {
      await Haptics.notification({ type: NotificationType.Error });
    }
  }

  async vibrateWarning(): Promise<void> {
    if (this.isNative) {
      await Haptics.notification({ type: NotificationType.Warning });
    }
  }
}