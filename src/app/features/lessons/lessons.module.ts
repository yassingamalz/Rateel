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

@NgModule({
  declarations: [
    LessonsListComponent,
    LessonCardComponent,
    LessonDetailsComponent,
    VideoPlayerComponent,
    InteractiveLessonComponent,
    AudioPlayerComponent,
    ReadingLessonComponent,
  ],
  imports: [
    CommonModule,
    LessonsRoutingModule,
  ]
})
export class LessonsModule { }