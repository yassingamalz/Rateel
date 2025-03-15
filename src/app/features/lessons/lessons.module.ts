// src/app/features/lessons/lessons.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

// Routing
import { LessonsRoutingModule } from './lessons-routing.module';

// Shared modules
import { SharedModule } from '../../shared/shared.module';
import { BorderFillDirective } from '../../shared/directives/border-fill.directive';
import { AssessmentModule } from './assessment/assessment.module';

// Main components
import { LessonsListComponent } from './lessons-list/lessons-list.component';
import { LessonCardComponent } from './lesson-card/lesson-card.component';
import { LessonDetailsComponent } from './lesson-details/lesson-details.component';
import { VideoPlayerComponent } from './video-player/video-player.component';
import { AudioPlayerComponent } from './audio-player/audio-player.component';
import { ReadingLessonComponent } from './reading-lesson/reading-lesson.component';
import { AssessmentLessonComponent } from './assessment-lesson/assessment-lesson.component';

// Interactive lesson feature module
import { InteractiveLessonComponent } from './interactive-lesson/interactive-lesson.component';
import { InteractiveLessonComponentsModule } from './interactive-lesson/interactive-lesson-components.module';

@NgModule({
  declarations: [
    // Main lesson components
    LessonsListComponent,
    LessonCardComponent,
    LessonDetailsComponent,
    VideoPlayerComponent,
    InteractiveLessonComponent,
    AudioPlayerComponent,
    ReadingLessonComponent,
    AssessmentLessonComponent
  ],
  imports: [
    // Angular modules
    CommonModule,
    FormsModule,
    
    // Routing
    LessonsRoutingModule,
    
    // Shared modules
    SharedModule,
    BorderFillDirective,
    AssessmentModule,
    
    // Feature modules
    InteractiveLessonComponentsModule
  ]
})
export class LessonsModule { }