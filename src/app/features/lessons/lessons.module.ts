// src/app/features/lessons/lessons.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { LessonsRoutingModule } from './lessons-routing.module';
import { LessonsListComponent } from './lessons-list/lessons-list.component';
import { LessonCardComponent } from './lesson-card/lesson-card.component';

@NgModule({
  declarations: [
    LessonsListComponent,
    LessonCardComponent
  ],
  imports: [
    CommonModule,
    LessonsRoutingModule,
  ]
})
export class LessonsModule { }