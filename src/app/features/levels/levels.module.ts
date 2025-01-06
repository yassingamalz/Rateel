import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { LevelCardComponent } from './level-card/level-card.component';
import { LevelsListComponent } from './levels-list/levels-list.component';



@NgModule({
  declarations: [
    LevelCardComponent,
    LevelsListComponent
  ],
  imports: [
    CommonModule
  ]
})
export class LevelsModule { }
