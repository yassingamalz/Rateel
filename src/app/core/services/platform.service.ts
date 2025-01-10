import { Injectable } from '@angular/core';
import { Capacitor } from '@capacitor/core';
import { VoiceRecorder } from 'capacitor-voice-recorder';
import { Haptics, ImpactStyle, NotificationType } from '@capacitor/haptics';

// Define the interface based on what the plugin actually returns
interface RecordingResult {
  value: string;
  duration: number;
  type: string;
}

@Injectable({
  providedIn: 'root'
})
export class PlatformService {
  private recorderInitialized = false;
  private hapticsInitialized = false;

  get isNative(): boolean {
    return Capacitor.isNativePlatform();
  }

  async initializeMicrophone(): Promise<void> {
    if (this.isNative && !this.recorderInitialized) {
      const permissionStatus = await VoiceRecorder.hasAudioRecordingPermission();
      if (!permissionStatus.value) {
        await VoiceRecorder.requestAudioRecordingPermission();
      }
      this.recorderInitialized = true;
    }
  }

  async startRecording(): Promise<void> {
    if (this.isNative) {
      await VoiceRecorder.startRecording();
    } else {
      // Web recording will be handled by the service
      return;
    }
  }

  async stopRecording(): Promise<{ value: string }> {
    if (this.isNative) {
      const recording = await VoiceRecorder.stopRecording();
      // Let's log the actual structure to see what we get
      console.log('Recording result:', recording);
      return { value: JSON.stringify(recording) };
    }
    // Web recording will be handled by the service
    return { value: '' };
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