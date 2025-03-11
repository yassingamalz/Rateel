import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { LoadingComponent } from './components/loading/loading.component';
import { ComingSoonComponent } from './components/coming-soon/coming-soon.component';
import { ThemeToggleComponent } from './components/theme-toggle/theme-toggle.component';
import { ModalComponent } from './components/modal/modal.component';

@NgModule({
  declarations: [
    LoadingComponent,
    ComingSoonComponent,
    ThemeToggleComponent,
    ModalComponent
  ],
  imports: [
    CommonModule,
    FormsModule
  ],
  exports: [
    LoadingComponent,
    ComingSoonComponent,
    ThemeToggleComponent,
    ModalComponent
  ]
})
export class SharedModule { }