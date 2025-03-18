import { CapacitorConfig } from '@capacitor/cli';

// Create the config object with minimal changes
const configObj = {
  appId: 'com.novavista.rattil',
  appName: 'Rattil',
  webDir: 'dist/rattil/browser',
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
        mixedContent: 'always',
        // This is the essential fix for Android font scaling
        textZoom: '100'
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
    backgroundColor: '#1B4332',
    overrideUserAgent: 'Mozilla/5.0 RattilApp'
  }
};

// Use type assertion to tell TypeScript this conforms to CapacitorConfig
const config = configObj as CapacitorConfig;

export default config;