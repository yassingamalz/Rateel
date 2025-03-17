import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { LoadingComponent } from './components/loading/loading.component';
import { ComingSoonComponent } from './components/coming-soon/coming-soon.component';
import { ThemeToggleComponent } from './components/theme-toggle/theme-toggle.component';
import { ModalComponent } from './components/modal/modal.component';
import { ModalHostComponent } from './components/modal-host/modal-host.component';
import { ClickOutsideDirective } from './directives/click-outside.directive';

@NgModule({
  declarations: [
    LoadingComponent,
    ComingSoonComponent,
    ThemeToggleComponent,
    ModalComponent,
    ModalHostComponent,
  ],
  imports: [
    CommonModule,
    FormsModule
  ],
  exports: [
    LoadingComponent,
    ComingSoonComponent,
    ThemeToggleComponent,
    ModalComponent,
    ModalHostComponent,
  ]
})
export class SharedModule { }