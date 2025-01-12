import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.novavista.rattil',
  appName: 'Rattil',
  webDir: 'dist/tajweed-app/browser',
  server: {
    androidScheme: 'https',
    cleartext: true,
    allowNavigation: ['*']
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 3000,
      launchAutoHide: true,
      backgroundColor: '#1B4332',
      androidSplashResourceName: 'splash',
      androidScaleType: 'CENTER_CROP',
      showSpinner: false,
    },
    ScreenOrientation: {
      defaultOrientation: 'landscape'
    },
    StatusBar: {
      style: 'DARK',
      backgroundColor: '#1B4332',
      overlaysWebView: true,
      hide: true
    },
    VoiceRecorder: {
      quality: 'max',
      webAudioMimeType: 'audio/wav',
      includeBase64: true
    },
    Permissions: {
      permissions: [
        'android.permission.RECORD_AUDIO',
        'android.permission.MODIFY_AUDIO_SETTINGS'
      ]
    },
    App: {
      webViewSettings: {
        androidScheme: 'https',
        allowFileAccess: true,
        mixedContent: 'always'
      }
    },
    Browser: {
      prefersFullscreen: 'always'
    }
  },
  android: {
    webContentsDebuggingEnabled: true,
    allowMixedContent: true,
    captureInput: true,
    initialFocus: true,
    useLegacyBridge: false,
    backgroundColor: '#1B4332'
  }
};

export default config;