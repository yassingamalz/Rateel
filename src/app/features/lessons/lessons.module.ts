// src/app/features/lessons/lessons.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { LessonsRoutingModule } from './lessons-routing.module';
import { LessonsListComponent } from './lessons-list/lessons-list.component';
import { LessonCardComponent } from './lesson-card/lesson-card.component';
import { VideoPlayerComponent } from './video-player/video-player.component';
import { InteractiveLessonComponent } from './interactive-lesson/interactive-lesson.component';
import { AudioPlayerComponent } from './audio-player/audio-player.component';
import { ReadingLessonComponent } from './reading-lesson/reading-lesson.component';
import { LessonDetailsComponent } from './lesson-details/lesson-details.component';
import { SharedModule } from '../../shared/shared.module';
import { BorderFillDirective } from '../../shared/directives/border-fill.directive';
import { AssessmentLessonComponent } from './assessment-lesson/assessment-lesson.component';

@NgModule({
  declarations: [
    LessonsListComponent,
    LessonCardComponent,
    LessonDetailsComponent,
    VideoPlayerComponent,
    InteractiveLessonComponent,
    AudioPlayerComponent,
    ReadingLessonComponent,
    AssessmentLessonComponent,
  ],
  imports: [
    CommonModule,
    SharedModule,
    BorderFillDirective,
    LessonsRoutingModule,
  ]
})
export class LessonsModule { }