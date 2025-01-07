// app-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

const routes: Routes = [
  {
    path: 'courses',
    children: [
      {
        path: '',
        loadChildren: () => import('./features/courses/courses.module')
          .then(m => m.CoursesModule)
      },
      {
        path: ':courseId/units/:unitId/lessons',
        loadChildren: () => import('./features/lessons/lessons.module')
          .then(m => m.LessonsModule)
      },
      {
        path: ':courseId/units',
        loadChildren: () => import('./features/units/units.module')
          .then(m => m.UnitsModule)
      }
    ]
  },
  {
    path: '',
    redirectTo: 'courses',
    pathMatch: 'full'
  }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }