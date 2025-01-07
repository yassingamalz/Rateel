// src/app/features/units/units-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { UnitsListComponent } from './units-list/units-list.component';
import { UnitDetailsComponent } from './unit-details/unit-details.component';

const routes: Routes = [
  {
    path: ':courseId',
    children: [
      {
        path: '',
        component: UnitsListComponent
      },
      {
        path: ':unitId',
        component: UnitDetailsComponent
      }
    ]
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class UnitsRoutingModule { }
