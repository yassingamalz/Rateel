import { Component, OnInit } from '@angular/core';
import { Capacitor } from '@capacitor/core';
import { ScreenOrientation } from '@capacitor/screen-orientation';
import { StatusBar, Style } from '@capacitor/status-bar';
import { SplashScreen } from '@capacitor/splash-screen';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  standalone: false,
  styleUrl: './app.component.scss'
})
export class AppComponent implements OnInit {
  title = 'tajweed-app';

  async ngOnInit() {
    if (Capacitor.isNativePlatform()) {
      await this.setupMobileEnvironment();
    }
  }

  async setupMobileEnvironment() {
    try {
      // Lock to landscape
      await ScreenOrientation.lock({
        orientation: 'landscape'
      });

      // Set status bar
      await StatusBar.setStyle({ style: Style.Dark });
      await StatusBar.setBackgroundColor({ color: '#1B4332' });

      // Hide splash screen after setup
      await SplashScreen.hide();
    } catch (error) {
      console.error('Mobile environment setup failed', error);
    }
  }
}