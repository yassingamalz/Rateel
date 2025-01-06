// shared/layout.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { MainLayoutComponent } from './main-layout/main-layout.component';
import { SidebarComponent } from './sidebar/sidebar.component';
import { MainContentComponent } from './main-content/main-content.component';

@NgModule({
  declarations: [
    MainLayoutComponent,
    SidebarComponent,
    MainContentComponent
  ],
  imports: [
    CommonModule,
    RouterModule
  ],
  exports: [
    MainLayoutComponent,
    SidebarComponent,
    MainContentComponent
  ]
})
export class LayoutModule { }