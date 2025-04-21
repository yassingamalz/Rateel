import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LeaderboardComponent } from './leaderboard/leaderboard.component';
import { DailyChallengesComponent } from './daily-challenges/daily-challenges.component';

const routes: Routes = [
  {
    path: '',
    children: [
      {
        path: 'leaderboard',
        component: LeaderboardComponent
      },
      {
        path: 'daily-challenges',
        component: DailyChallengesComponent
      },
      {
        path: '',
        redirectTo: 'leaderboard',
        pathMatch: 'full'
      }
    ]
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class GamificationRoutingModule { }