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
  title = 'Rattil - رَتِّلِ';

  constructor(private platformService: PlatformService) { }

  async ngOnInit() {
    this.logDeviceInfo();
    this.preventZoomAndScaling();

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

  private preventZoomAndScaling() {
    // Prevent double-tap zoom
    document.addEventListener('touchstart', (event) => {
      if (event.touches.length > 1) {
        event.preventDefault();
      }
    }, { passive: false });

    // Prevent pinch zoom
    document.addEventListener('gesturestart', (event) => {
      event.preventDefault();
    }, { passive: false });

    // Prevent zooming on input focus
    const inputs = document.querySelectorAll('input, textarea');
    inputs.forEach(input => {
      input.addEventListener('focus', () => {
        document.body.style.zoom = '1';
        // Adjust viewport meta tag
        const metaViewport = document.querySelector('meta[name="viewport"]');
        if (metaViewport) {
          metaViewport.setAttribute(
            'content', 
            'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'
          );
        }
      });

      input.addEventListener('blur', () => {
        document.body.style.zoom = '1';
      });
    });

    // Disable text size adjustment
    const styleElement = document.createElement('style');
    styleElement.innerHTML = `
      * {
        -webkit-text-size-adjust: 100%;
        -ms-text-size-adjust: 100%;
        text-size-adjust: 100%;
        touch-action: manipulation;
      }
      html, body {
        font-size: 16px !important;
        text-size-adjust: 100%;
        -webkit-text-size-adjust: 100%;
        touch-action: manipulation;
      }
      input, textarea {
        font-size: 16px !important;
      }
    `;
    document.head.appendChild(styleElement);
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
        devicePixelRatio: window.devicePixelRatio,
        textZoom: this.getTextZoom()
      }
    });
  }

  private getTextZoom(): number {
    // Method to detect text zoom level
    return window.devicePixelRatio || 1;
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

      // Ensure consistent sizing
      this.enforceConsistentSizing();

    } catch (error) {
      console.error('Mobile environment setup failed', error);
    }
  }

  private enforceConsistentSizing() {
    // Additional method to enforce consistent sizing
    const metaViewport = document.querySelector('meta[name="viewport"]');
    if (metaViewport) {
      metaViewport.setAttribute(
        'content', 
        'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover'
      );
    }

    // Dynamically adjust root font size
    document.documentElement.style.setProperty('font-size', '16px');
  }
}