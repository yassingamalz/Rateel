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

  constructor(private platformService: PlatformService) {}

  async ngOnInit() {
    if (Capacitor.isNativePlatform()) {
      await this.setupMobileEnvironment();
    }
  }

  async setupMobileEnvironment() {
    try {
      // Initialize platform capabilities
      await this.platformService.initializeMicrophone();

      // Set full screen and handle safe areas
      if (Capacitor.getPlatform() === 'android') {
        await StatusBar.hide();

        App.addListener('backButton', () => {
          // Handle back button if needed
        });
      }

      // Lock to landscape
      await ScreenOrientation.lock({
        orientation: 'landscape'
      });

      // Additional status bar configuration
      await StatusBar.setOverlaysWebView({ overlay: true });
      await StatusBar.setStyle({ style: Style.Dark });
      await StatusBar.setBackgroundColor({ color: '#1B4332' });

      // Hide splash screen after setup
      await SplashScreen.hide({
        fadeOutDuration: 500
      });

    } catch (error) {
      console.error('Mobile environment setup failed', error);
    }
  }
}