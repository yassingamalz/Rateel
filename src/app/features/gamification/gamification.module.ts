// src/app/features/gamification/gamification.module.ts
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
import { AchievementsComponent } from './achievements/achievements.component';
import { AchievementHeaderComponent } from './achievements/components/achievement-header/achievement-header.component';
import { AchievementListComponent } from './achievements/components/achievement-list/achievement-list.component';
import { BadgesCollectionComponent } from './achievements/components/badges-collection/badges-collection.component';
import { PointsHistoryComponent } from './achievements/components/points-history/points-history.component';
import { AchievementDetailsModalComponent } from './achievements/components/achievement-details-modal/achievement-details-modal.component';

@NgModule({
  declarations: [
    LeaderboardComponent,
    UserScoreComponent,
    AchievementBadgeComponent,
    PointsCardComponent,
    DailyChallengesComponent,
    AchievementsComponent,
    AchievementHeaderComponent,
    AchievementListComponent,
    BadgesCollectionComponent,
    PointsHistoryComponent,
    AchievementDetailsModalComponent,
  ],
  imports: [
    CommonModule,
    FormsModule,
    SharedModule,
    GamificationRoutingModule
  ],
  exports: [
    UserScoreComponent,
    AchievementBadgeComponent,
    PointsCardComponent
  ]
})
export class GamificationModule { }