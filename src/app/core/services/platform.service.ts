import { Injectable } from '@angular/core';
import { Capacitor } from '@capacitor/core';
import { VoiceRecorder, RecordingData, GenericResponse } from 'capacitor-voice-recorder';
import { Haptics, ImpactStyle, NotificationType } from '@capacitor/haptics';
import { Dialog } from '@capacitor/dialog';
import { BehaviorSubject, Observable } from 'rxjs';
import { App } from '@capacitor/app';
import { StatusBar, Style } from '@capacitor/status-bar';
import { ScreenOrientation } from '@capacitor/screen-orientation';
import { SplashScreen } from '@capacitor/splash-screen';

@Injectable({
  providedIn: 'root'
})
export class PlatformService {
  private recorderInitialized = false;
  private permissionStatus = new BehaviorSubject<boolean>(false);
  private isRecording = new BehaviorSubject<boolean>(false);
  private orientationLocked = false;

  constructor() {
    this.setupBackButtonHandler();
  }

  get isNative(): boolean {
    return Capacitor.isNativePlatform();
  }

  getPermissionStatus(): Observable<boolean> {
    return this.permissionStatus.asObservable();
  }

  getRecordingStatus(): Observable<boolean> {
    return this.isRecording.asObservable();
  }

  // Platform Initialization
  async initializePlatform(): Promise<void> {
    if (!this.isNative) return;

    try {
      await this.setupScreenOrientation();
      await this.setupStatusBar();
      await this.initializeMicrophone();
      await this.hideSplashScreen();
    } catch (error) {
      console.error('Platform initialization error:', error);
      await this.showErrorDialog('خطأ في تهيئة التطبيق');
    }
  }

  private async setupScreenOrientation(): Promise<void> {
    try {
      await ScreenOrientation.lock({ orientation: 'landscape' });
      this.orientationLocked = true;
    } catch (error) {
      console.error('Screen orientation error:', error);
    }
  }

  private async setupStatusBar(): Promise<void> {
    try {
      await StatusBar.setStyle({ style: Style.Dark });
      await StatusBar.setBackgroundColor({ color: '#1B4332' });
      if (Capacitor.getPlatform() === 'android') {
        await StatusBar.hide();
      }
    } catch (error) {
      console.error('Status bar setup error:', error);
    }
  }

  private async hideSplashScreen(): Promise<void> {
    try {
      await SplashScreen.hide({
        fadeOutDuration: 500
      });
    } catch (error) {
      console.error('Splash screen hide error:', error);
    }
  }

  // Microphone Handling
  async initializeMicrophone(): Promise<boolean> {
    if (!this.isNative) return true;

    try {
      console.log('Checking microphone permissions...');
      const hasPermission = await VoiceRecorder.hasAudioRecordingPermission();
      
      if (hasPermission.value) {
        console.log('Microphone permission already granted');
        this.updatePermissionStatus(true);
        return true;
      }

      const userConfirmed = await this.showPermissionDialog();
      if (!userConfirmed) {
        this.updatePermissionStatus(false);
        return false;
      }

      const permission = await VoiceRecorder.requestAudioRecordingPermission();
      this.updatePermissionStatus(permission.value);
      
      if (!permission.value) {
        await this.showPermissionDeniedDialog();
      }

      return permission.value;

    } catch (error) {
      console.error('Microphone initialization error:', error);
      await this.showErrorDialog('خطأ في تهيئة الميكروفون');
      return false;
    }
  }

  async startRecording(): Promise<void> {
    if (!this.isNative) return;

    try {
      const hasPermission = await this.checkAndRequestPermission();
      if (!hasPermission) {
        await this.vibrateError();
        throw new Error('Microphone permission denied');
      }

      await VoiceRecorder.startRecording();
      this.isRecording.next(true);
      await this.vibrateSuccess();
    } catch (error) {
      console.error('Start recording error:', error);
      await this.vibrateError();
      throw error;
    }
  }

  async stopRecording(): Promise<RecordingData> {
    if (!this.isNative) {
      return this.createEmptyRecording();
    }

    try {
      const recording = await VoiceRecorder.stopRecording();
      this.isRecording.next(false);
      await this.vibrateSuccess();
      return recording;
    } catch (error) {
      console.error('Stop recording error:', error);
      await this.vibrateError();
      throw error;
    }
  }

  // Haptic Feedback
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

  // Dialog Helpers
  private async showPermissionDialog(): Promise<boolean> {
    const { value } = await Dialog.confirm({
      title: 'الإذن مطلوب',
      message: 'نحتاج إلى إذن الميكروفون للتحقق من تلاوتك. هل تسمح لنا باستخدام الميكروفون؟',
      okButtonTitle: 'نعم',
      cancelButtonTitle: 'لا'
    });
    return value;
  }

  private async showPermissionDeniedDialog(): Promise<void> {
    await Dialog.alert({
      title: 'تنبيه',
      message: 'لم يتم منح إذن الميكروفون. يمكنك تفعيله من إعدادات التطبيق',
      buttonTitle: 'حسناً'
    });
  }

  private async showErrorDialog(message: string): Promise<void> {
    await Dialog.alert({
      title: 'خطأ',
      message,
      buttonTitle: 'حسناً'
    });
  }

  // Helper Methods
  private async checkAndRequestPermission(): Promise<boolean> {
    const hasPermission = await VoiceRecorder.hasAudioRecordingPermission();
    if (!hasPermission.value) {
      return await this.initializeMicrophone();
    }
    return true;
  }

  private updatePermissionStatus(status: boolean): void {
    this.permissionStatus.next(status);
    this.recorderInitialized = status;
  }

  private createEmptyRecording(): RecordingData {
    return {
      value: {
        recordDataBase64: '',
        msDuration: 0,
        mimeType: 'audio/wav'
      }
    };
  }

  private setupBackButtonHandler(): void {
    if (!this.isNative) return;

    App.addListener('backButton', () => {
      // Customize back button behavior here
      // For example, show an exit confirmation dialog
      this.showExitConfirmation();
    });
  }

  private async showExitConfirmation(): Promise<void> {
    const { value } = await Dialog.confirm({
      title: 'تأكيد الخروج',
      message: 'هل تريد الخروج من التطبيق؟',
      okButtonTitle: 'نعم',
      cancelButtonTitle: 'لا'
    });

    if (value) {
      App.exitApp();
    }
  }

  // Cleanup
  async cleanup(): Promise<void> {
    if (!this.isNative) return;

    try {
      if (this.orientationLocked) {
        await ScreenOrientation.unlock();
      }
      
      if (this.isRecording.value) {
        await this.stopRecording();
      }
      
      // Remove any listeners or perform other cleanup
      App.removeAllListeners();
    } catch (error) {
      console.error('Cleanup error:', error);
    }
  }
}