import type { CapacitorConfig } from '@capacitor/cli';

const config = {
  appId: 'com.novavista.tajweed',
  appName: 'tajweed-app',
  webDir: 'dist/tajweed-app/browser',
  plugins: {
    SplashScreen: {
      launchShowDuration: 3000,
      launchAutoHide: true,
      backgroundColor: '#1B4332',
      androidSplashResourceName: 'splash',
      androidScaleType: 'CENTER_CROP'
    },
    ScreenOrientation: {
      defaultOrientation: 'landscape'
    },
    StatusBar: {
      style: 'DARK',
      backgroundColor: '#1B4332'
    }
  }
} as CapacitorConfig;

export default config;