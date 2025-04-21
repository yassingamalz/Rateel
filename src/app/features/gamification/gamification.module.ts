import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { GamificationRoutingModule } from './gamification-routing.module';
import { LeaderboardComponent } from './leaderboard/leaderboard.component';
import { SharedModule } from '../../shared/shared.module';
import { UserScoreComponent } from './components/user-score/user-score.component';
import { AchievementBadgeComponent } from './components/achievement-badge/achievement-badge.component';
import { PointsCardComponent } from './components/points-card/points-card.component';
import { DailyChallengesComponent } from './daily-challenges/daily-challenges.component';

@NgModule({
  declarations: [
    LeaderboardComponent,
    UserScoreComponent,
    AchievementBadgeComponent,
    PointsCardComponent,
    DailyChallengesComponent,
  ],
  imports: [
    CommonModule,
    FormsModule,
    SharedModule,
    GamificationRoutingModule
  ],
  exports: [
  ]
})
export class GamificationModule { }