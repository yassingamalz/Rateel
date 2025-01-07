// src/app/features/lessons/lessons.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { LessonsRoutingModule } from './lessons-routing.module';
import { LessonsListComponent } from './lessons-list/lessons-list.component';
import { LessonDetailsComponent } from './lesson-details/lesson-details.component';
import { LessonsService } from './lessons.service';
import { LessonCardComponent } from './lesson-card/lesson-card.component';

@NgModule({
  declarations: [
    LessonsListComponent,
    LessonCardComponent,
    LessonDetailsComponent
  ],
  imports: [
    CommonModule,
    RouterModule,
    LessonsRoutingModule
  ],
  providers: [LessonsService]
})
export class LessonsModule { }