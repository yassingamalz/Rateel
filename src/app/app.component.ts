import { Component, OnInit } from '@angular/core';
import { Capacitor } from '@capacitor/core';
import { ScreenOrientation } from '@capacitor/screen-orientation';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  standalone: false,
  styleUrl: './app.component.scss'
})
export class AppComponent implements OnInit {
  title = 'tajweed-app';

  ngOnInit() {
    if (Capacitor.isNativePlatform()) {
      this.lockToLandscape();
    }
  }

  async lockToLandscape() {
    try {
      await ScreenOrientation.lock({
        orientation: 'landscape'
      });
    } catch (error) {
      console.error('Failed to lock orientation', error);
    }
  }
}