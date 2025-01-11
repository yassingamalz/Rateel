import { Component, OnInit } from '@angular/core';
import { Capacitor } from '@capacitor/core';
import { ScreenOrientation } from '@capacitor/screen-orientation';
import { StatusBar, Style } from '@capacitor/status-bar';
import { SplashScreen } from '@capacitor/splash-screen';
import { App } from '@capacitor/app';
import { PlatformService } from './core/services/platform.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  standalone: false,
  styleUrl: './app.component.scss'
})
export class AppComponent implements OnInit {
  title = 'tajweed-app';

  constructor(private platformService: PlatformService) { }

  async ngOnInit() {
    this.logDeviceInfo();

    if (Capacitor.isNativePlatform()) {
      this.optimizeRendering();
      await this.setupMobileEnvironment();
    }
  } 

  private optimizeRendering() {
    // Explicit rendering optimization for black backgrounds
    const body = document.body;
    body.style.setProperty('transform', 'translateZ(0)');
    body.style.setProperty('backface-visibility', 'hidden');
    body.style.setProperty('perspective', '1000px');
  }

  private logDeviceInfo() {
    console.log('Device Diagnostics:', {
      platform: Capacitor.getPlatform(),
      isNative: Capacitor.isNativePlatform(),
      screenDetails: {
        width: window.screen.width,
        height: window.screen.height,
        availWidth: window.screen.availWidth,
        availHeight: window.screen.availHeight,
        devicePixelRatio: window.devicePixelRatio
      }
    });
  }
  async setupMobileEnvironment() {
    try {
      // Lock to landscape first to prevent flashing
      await ScreenOrientation.lock({
        orientation: 'landscape'
      });

      // Set full screen and handle safe areas
      if (Capacitor.getPlatform() === 'android') {
        await StatusBar.hide();

        App.addListener('backButton', () => {
          // Handle back button if needed
        });
      }

      // Additional status bar configuration
      await StatusBar.setOverlaysWebView({ overlay: true });
      await StatusBar.setStyle({ style: Style.Dark });
      await StatusBar.setBackgroundColor({ color: '#1B4332' });

      // Initialize platform capabilities
      await this.platformService.initializeMicrophone();

      // Hide splash screen after setup
      await SplashScreen.hide({
        fadeOutDuration: 500
      });

    } catch (error) {
      console.error('Mobile environment setup failed', error);
    }
  }
}