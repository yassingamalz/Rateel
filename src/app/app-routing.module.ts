// app-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { InitializationComponent } from './core/initialization/initialization.component';
import { InitializationGuard } from './core/guards/initialization.guard';

const routes: Routes = [
  {
    path: 'initialization',
    component: InitializationComponent
  },
  {
    path: 'courses',
    // canActivate: [InitializationGuard],
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
    redirectTo: 'initialization',
    pathMatch: 'full'
  }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }