// src/app/features/gamification/gamification-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LeaderboardComponent } from './leaderboard/leaderboard.component';
import { DailyChallengesComponent } from './daily-challenges/daily-challenges.component';
import { AchievementsComponent } from './achievements/achievements.component';

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
        path: 'achievements',
        component: AchievementsComponent
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