import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { GamificationService } from './gamification.service';

export interface DailyChallenge {
  id: number;
  points: number;
  isCompleted: boolean;
  isLocked: boolean;
  type?: 'lesson' | 'practice' | 'recitation';
  icon?: string;
  progressRequired?: number;
  currentProgress?: number;
}

@Injectable({
  providedIn: 'root'
})
export class DailyChallengesService {
  private readonly STORAGE_KEY = 'tajweed_daily_challenge_path';
  private challengePath = new BehaviorSubject<DailyChallenge[]>([]);
  private dailyStreak = new BehaviorSubject<number>(0);

  constructor(private gamificationService: GamificationService) {
    this.initializeChallengePath();
  }

  private initializeChallengePath(): void {
    const storedPath = localStorage.getItem(this.STORAGE_KEY);

    if (storedPath) {
      const parsedPath: DailyChallenge[] = JSON.parse(storedPath);
      this.challengePath.next(parsedPath);
    } else {
      this.generateNewChallengePath();
    }
  }

  private generateNewChallengePath(): void {
    const newPath: DailyChallenge[] = [
      {
        id: 1,
        points: 50,
        isCompleted: false,
        isLocked: false,
        type: 'lesson',
        icon: 'book',
        progressRequired: 1
      },
      {
        id: 2,
        points: 50,
        isCompleted: false,
        isLocked: true,
        type: 'practice',
        icon: 'microphone',
        progressRequired: 1
      },
      {
        id: 3,
        points: 50,
        isCompleted: false,
        isLocked: true,
        type: 'recitation',
        icon: 'quran',
        progressRequired: 1
      },
      {
        id: 4,
        points: 50,
        isCompleted: false,
        isLocked: true,
        type: 'lesson',
        icon: 'book',
        progressRequired: 1
      },
      {
        id: 5,
        points: 50,
        isCompleted: false,
        isLocked: true,
        type: 'practice',
        icon: 'microphone',
        progressRequired: 1
      },
      {
        id: 6,
        points: 50,
        isCompleted: false,
        isLocked: true,
        type: 'recitation',
        icon: 'quran',
        progressRequired: 1
      },
      {
        id: 7,
        points: 100,
        isCompleted: false,
        isLocked: true,
        type: 'lesson',
        icon: 'trophy',
        progressRequired: 1
      }
    ];

    this.challengePath.next(newPath);
    this.saveChallengePath();
  }

  private saveChallengePath(): void {
    localStorage.setItem(
      this.STORAGE_KEY,
      JSON.stringify(this.challengePath.value)
    );
  }

  getChallengesPath(): Observable<DailyChallenge[]> {
    return this.challengePath.asObservable();
  }

  completeChallengeNode(nodeId: number): void {
    const currentPath = [...this.challengePath.value];
    const nodeIndex = currentPath.findIndex(node => node.id === nodeId);

    if (nodeIndex !== -1) {
      // Complete current node
      currentPath[nodeIndex].isCompleted = true;

      // Unlock next node if exists
      if (nodeIndex + 1 < currentPath.length) {
        currentPath[nodeIndex + 1].isLocked = false;
      }

      // Award points
      this.gamificationService.addPoints(
        `إكمال التحدي ${nodeId}`,
        currentPath[nodeIndex].points,
        'earned'
      ).subscribe();

      this.challengePath.next(currentPath);
      this.saveChallengePath();
    }
  }

  resetChallengePath(): void {
    this.generateNewChallengePath();
  }

  claimFinalReward(): void {
    const finalRewardPoints = 500;

    this.gamificationService.addPoints(
      'مكافأة إكمال التحديات اليومية',
      finalRewardPoints,
      'bonus'
    ).subscribe();

    // Potentially reset the path or do something special
    this.resetChallengePath();
  }
}