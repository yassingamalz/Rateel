import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { UnitsRoutingModule } from './units-routing.module';
import { UnitCardComponent } from './unit-card/unit-card.component';
import { UnitsListComponent } from './units-list/units-list.component';
import { BorderFillDirective } from '../../shared/directives/border-fill.directive';
import { SharedModule } from '../../shared/shared.module';


@NgModule({
  declarations: [
    UnitCardComponent,
    UnitsListComponent,
  ],
  imports: [
    CommonModule,
    SharedModule,
    BorderFillDirective,
    UnitsRoutingModule
  ]
})
export class UnitsModule { }
