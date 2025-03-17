import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { ReadingLessonComponent } from './reading-lesson.component';
import { ReadingControlsBarComponent } from './components/reading-controls-bar/reading-controls-bar.component';
import { VerseCardComponent } from './components/verse-card/verse-card.component';
import { TajweedRulesPanelComponent } from './components/tajweed-rules-panel/tajweed-rules-panel.component';
import { NavigationDotsComponent } from './components/navigation-dots/navigation-dots.component';

@NgModule({
  declarations: [
    ReadingLessonComponent,
    ReadingControlsBarComponent,
    VerseCardComponent,
    TajweedRulesPanelComponent,
    NavigationDotsComponent
  ],
  imports: [
    CommonModule,
    FormsModule
  ],
  exports: [
    ReadingLessonComponent
  ]
})
export class ReadingLessonModule { }