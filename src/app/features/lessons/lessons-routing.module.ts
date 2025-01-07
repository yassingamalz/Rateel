// lessons-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LessonsListComponent } from './lessons-list/lessons-list.component';
import { LessonDetailsComponent } from './lesson-details/lesson-details.component';

const routes: Routes = [
 {
   path: '',
   children: [
     {
       path: '',
       component: LessonsListComponent
     },
     {
       path: ':lessonId',
       component: LessonDetailsComponent
     }
   ]
 }
];

@NgModule({
 imports: [RouterModule.forChild(routes)],
 exports: [RouterModule]
})
export class LessonsRoutingModule { }