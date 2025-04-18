import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { InitializationComponent } from './core/initialization/initialization.component';
import { ComingSoonComponent } from './shared/components/coming-soon/coming-soon.component';

const routes: Routes = [
  {
    path: 'initialization',
    component: InitializationComponent
  },
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
    path: 'gamification',
    loadChildren: () => import('./features/gamification/gamification.module')
      .then(m => m.GamificationModule)
  },
  {
    path: 'quran',
    component: ComingSoonComponent
  },
  {
    path: 'practice',
    component: ComingSoonComponent
  },
  {
    path: 'certificates',
    component: ComingSoonComponent
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