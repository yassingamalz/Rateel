import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { LoadingComponent } from './components/loading/loading.component';
import { ComingSoonComponent } from './components/coming-soon/coming-soon.component';
import { ThemeToggleComponent } from './components/theme-toggle/theme-toggle.component';

@NgModule({
  declarations: [
    LoadingComponent,
    ComingSoonComponent,
    ThemeToggleComponent
  ],
  imports: [
    CommonModule
  ],
  exports: [
    LoadingComponent,
    ComingSoonComponent,
    ThemeToggleComponent
  ]
})
export class SharedModule { }