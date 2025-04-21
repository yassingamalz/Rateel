import { Component, OnInit, OnDestroy, ChangeDetectionStrategy, ChangeDetectorRef } from '@angular/core';
import { DailyChallengesService, DailyChallenge } from '../services/daily-challenges.service';
import { Subscription } from 'rxjs';
import { trigger, transition, style, animate } from '@angular/animations';

@Component({
  selector: 'app-daily-challenges',
  standalone: false,
  templateUrl: './daily-challenges.component.html',
  styleUrls: ['./daily-challenges.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('nodeAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.8)' }),
        animate('300ms ease-out', style({ opacity: 1, transform: 'scale(1)' }))
      ])
    ])
  ]
})
export class DailyChallengesComponent implements OnInit, OnDestroy {
  challengePath: DailyChallenge[] = [];
  dailyStreak: number = 0;
  isAllChallengesCompleted: boolean = false;

  private subscriptions: Subscription[] = [];

  constructor(
    private dailyChallengesService: DailyChallengesService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    // Subscribe to challenge path
    this.subscriptions.push(
      this.dailyChallengesService.getChallengesPath().subscribe(path => {
        this.challengePath = path;
        this.checkAllChallengesCompleted();
        this.cdr.markForCheck();
      })
    );
  }

  private checkAllChallengesCompleted(): void {
    this.isAllChallengesCompleted =
      this.challengePath.every(challenge => challenge.isCompleted);
  }

  onChallengeNodeClick(challenge: DailyChallenge): void {
    // Can only interact with unlocked and not completed challenges
    if (!challenge.isLocked && !challenge.isCompleted) {
      this.dailyChallengesService.completeChallengeNode(challenge.id);
    }
  }

  claimFinalReward(): void {
    if (this.isAllChallengesCompleted) {
      this.dailyChallengesService.claimFinalReward();
    }
  }

  ngOnDestroy(): void {
    // Clean up subscriptions
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }
}