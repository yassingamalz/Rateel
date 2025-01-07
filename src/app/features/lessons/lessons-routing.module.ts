// src/app/features/lessons/lessons-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LessonsListComponent } from './lessons-list/lessons-list.component';

const routes: Routes = [
  {
    path: ':lessonId',
    children: [
      {
        path: '',
        component: LessonsListComponent
      }
    ]
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class LessonsRoutingModule { }