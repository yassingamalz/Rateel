import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { MainLayoutComponent } from './layout/main-layout/main-layout.component';
import { SidebarComponent } from './layout/sidebar/sidebar.component';
import { MainContentComponent } from './layout/main-content/main-content.component';
import { UnitCardComponent } from './features/units/components/unit-card/unit-card.component';
import { UnitListComponent } from './features/units/components/unit-list/unit-list.component';
import { UnitHeaderComponent } from './features/units/components/unit-header/unit-header.component';
import { LessonStepComponent } from './features/lessons/components/lesson-step/lesson-step.component';
import { LessonProgressComponent } from './features/lessons/components/lesson-progress/lesson-progress.component';
import { LessonHeaderComponent } from './features/lessons/components/lesson-header/lesson-header.component';
import { CommonModule } from '@angular/common';
import { LayoutModule } from './layout/layout.module';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';

@NgModule({
  declarations: [
    AppComponent,
    UnitCardComponent,
    UnitListComponent,
    UnitHeaderComponent,
    LessonStepComponent,
    LessonProgressComponent,
    LessonHeaderComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    LayoutModule,
    CommonModule,
    FontAwesomeModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
