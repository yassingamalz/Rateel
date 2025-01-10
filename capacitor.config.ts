import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.novavista.tajweed',
  appName: 'tajweed-app',
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
      showSpinner: false
    },
    ScreenOrientation: {
      defaultOrientation: 'landscape'
    },
    StatusBar: {
      style: 'DARK',
      backgroundColor: '#1B4332',
      overlaysWebView: true
    },
    App: {
      webViewSettings: {
        androidScheme: 'https',
        allowFileAccess: true,
        mixedContent: true,
        setLayoutInDisplayCutoutMode: true
      }
    }
  },
  android: {
    webContentsDebuggingEnabled: true,
    allowMixedContent: true,
    captureInput: true,
    initialFocus: true,
    useLegacyBridge: false
  }
};

export default config;