import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { UnitsRoutingModule } from './units-routing.module';
import { UnitCardComponent } from './unit-card/unit-card.component';
import { UnitsListComponent } from './units-list/units-list.component';
import { UnitDetailsComponent } from './unit-details/unit-details.component';
import { BorderFillDirective } from '../../shared/directives/border-fill.directive';


@NgModule({
  declarations: [
    UnitCardComponent,
    UnitsListComponent,
    UnitDetailsComponent
  ],
  imports: [
    CommonModule,
    BorderFillDirective,
    UnitsRoutingModule
  ]
})
export class UnitsModule { }
