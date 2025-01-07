import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

const routes: Routes = [
  {
    path: 'courses',
    loadChildren: () => import('./features/courses/courses.module')
      .then(m => m.CoursesModule)
  },
  {
    path: 'units',
    loadChildren: () => import('./features/units/units.module')
      .then(m => m.UnitsModule)
  },
  {
    path: 'lessons',
    loadChildren: () => import('./features/lessons/lessons.module')
      .then(m => m.LessonsModule)
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