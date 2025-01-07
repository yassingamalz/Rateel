import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { LessonsRoutingModule } from './lessons-routing.module';
import { LessonCardComponent } from './lesson-card/lesson-card.component';
import { LessonsListComponent } from './lessons-list/lessons-list.component';
import { LessonDetailsComponent } from './lesson-details/lesson-details.component';


@NgModule({
  declarations: [
    LessonCardComponent,
    LessonsListComponent,
    LessonDetailsComponent
  ],
  imports: [
    CommonModule,
    LessonsRoutingModule
  ]
})
export class LessonsModule { }
