import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { AppModule } from './app/app.module';
import { preloadStyles } from './preload-styles';

platformBrowserDynamic().bootstrapModule(AppModule, {
  ngZoneEventCoalescing: true,
})
  .catch(err => console.error(err));

  preloadStyles();

platformBrowserDynamic().bootstrapModule(AppModule)
  .catch(err => console.error(err));