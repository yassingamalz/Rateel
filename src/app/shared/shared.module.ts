// src/app/shared/shared.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { LoadingComponent } from './components/loading/loading.component';
import { ComingSoonComponent } from './components/coming-soon/coming-soon.component';
import { ThemeToggleComponent } from './components/theme-toggle/theme-toggle.component';

const routes: Routes = [
  {
    path: '',
    component: ComingSoonComponent
  }
];

@NgModule({
  declarations: [
    LoadingComponent,
    ComingSoonComponent,
    ThemeToggleComponent
  ],
  imports: [
    CommonModule,
    RouterModule.forChild(routes)
  ],
  exports: [
    LoadingComponent,
    ComingSoonComponent
  ]
})
export class SharedModule { }