// src/app/features/gamification/leaderboard/leaderboard.component.ts
import { Component, OnInit, OnDestroy, ChangeDetectionStrategy, ChangeDetectorRef, HostListener } from '@angular/core';
import { Subscription } from 'rxjs';
import { trigger, transition, style, animate } from '@angular/animations';
import { GamificationService, GamificationUser } from '../services/gamification.service';

@Component({
  selector: 'app-leaderboard',
  standalone: false,
  templateUrl: './leaderboard.component.html',
  styleUrls: ['./leaderboard.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('fadeIn', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('300ms ease-out', style({ opacity: 1 }))
      ])
    ]),
    trigger('slideIn', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateY(10px)' }),
        animate('300ms ease-out', style({ opacity: 1, transform: 'translateY(0)' }))
      ])
    ])
  ]
})
export class LeaderboardComponent implements OnInit, OnDestroy {
  // Data properties
  leaderboard: GamificationUser[] = [];
  filteredLeaderboard: GamificationUser[] = [];
  currentUserPosition: GamificationUser | null = null;
  currentFilter: 'all' | 'friends' | 'region' = 'all';
  displayLimit: number = 10;
  isLoading: boolean = true;

  private subscriptions: Subscription[] = [];

  constructor(
    private gamificationService: GamificationService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    this.checkScreenDimensions();
    this.loadLeaderboardData();
  }

  private loadLeaderboardData(): void {
    this.isLoading = true;

    // Subscribe to leaderboard data from service
    this.subscriptions.push(
      this.gamificationService.getLeaderboard().subscribe({
        next: (data) => {
          if (data && data.length > 0) {
            this.leaderboard = data;

            // Make sure the list is properly sorted by score
            this.leaderboard.sort((a, b) => b.score - a.score);

            // Update ranks based on sorted order
            this.leaderboard.forEach((user, index) => {
              user.rank = index + 1;
            });
          } else {
            // If service returns empty data, generate mock data
            this.generateMockData();
          }

          // Apply initial filter
          this.setFilter('all');

          // Find current user position
          this.findCurrentUserPosition();

          this.isLoading = false;
          this.cdr.markForCheck();
        },
        error: (error) => {
          console.error('Error loading leaderboard data:', error);

          // Generate mock data on error
          this.generateMockData();
          this.setFilter('all');
          this.findCurrentUserPosition();

          this.isLoading = false;
          this.cdr.markForCheck();
        }
      })
    );
  }

  // Filter the leaderboard based on selected filter
  setFilter(filter: 'all' | 'friends' | 'region'): void {
    this.currentFilter = filter;

    switch (filter) {
      case 'all':
        this.filteredLeaderboard = [...this.leaderboard];
        break;

      case 'friends':
        this.filteredLeaderboard = this.leaderboard.filter(user =>
          user.isFriend || user.isCurrentUser
        );
        break;

      case 'region':
        const currentUser = this.leaderboard.find(user => user.isCurrentUser);
        if (currentUser) {
          this.filteredLeaderboard = this.leaderboard.filter(user =>
            user.region === currentUser.region
          );
        } else {
          this.filteredLeaderboard = [...this.leaderboard];
        }
        break;
    }

    this.cdr.markForCheck();
  }

  // Find the current user's position in the leaderboard
  findCurrentUserPosition(): void {
    this.currentUserPosition = this.leaderboard.find(user => user.isCurrentUser) || null;
    this.cdr.markForCheck();
  }

  // Generate mock data for testing/preview
  private generateMockData(): void {
    const avatars = [
      'assets/images/avatars/avatar-1.png',
      'assets/images/avatars/avatar-2.png',
      'assets/images/avatars/avatar-3.png',
      'assets/images/avatars/avatar-4.png',
      'assets/images/avatars/avatar-5.png'
    ];

    const names = [
      'ليلى أحمد',
      'خالد ناصر',
      'محمد أحمد',
      'أحمد عبدالرحمن',
      'فاطمة علي',
      'عبدالله محمد',
      'نورة سلطان',
      'سارة خالد',
      'يوسف محمد',
      'حسن علي',
      'ريم سعد',
      'عمر محمد'
    ];

    const regions = ['الرياض', 'جدة', 'الدمام', 'المدينة', 'مكة'];

    // Create 12 users with mock data
    const mockUsers: GamificationUser[] = [];

    for (let i = 0; i < 12; i++) {
      // Make the 8th user (index 7) the current user for testing
      const isCurrentUser = i === 7;

      mockUsers.push({
        id: `user-${i + 1}`,
        rank: i + 1, // Will be updated after sorting
        name: names[i],
        avatar: avatars[i % avatars.length],
        score: isCurrentUser ? 911 : 1500 - (i * 50) + Math.floor(Math.random() * 30),
        completedLessons: Math.max(5, Math.floor(Math.random() * 30)),
        isCurrentUser,
        isFriend: Math.random() > 0.6,
        region: regions[Math.floor(Math.random() * regions.length)]
      });
    }

    // Sort by score in descending order
    mockUsers.sort((a, b) => b.score - a.score);

    // Update ranks based on sorted order
    mockUsers.forEach((user, index) => {
      user.rank = index + 1;
    });

    this.leaderboard = mockUsers;
  }

  // Listen for window resize to adjust displayLimit
  @HostListener('window:resize')
  onResize(): void {
    this.checkScreenDimensions();
    this.cdr.markForCheck();
  }

  // Set appropriate display limit based on screen dimensions
  private checkScreenDimensions(): void {
    const height = window.innerHeight;

    if (height < 400) {
      this.displayLimit = 6;
    } else if (height < 600) {
      this.displayLimit = 8;
    } else {
      this.displayLimit = 10;
    }
  }

  ngOnDestroy(): void {
    // Clean up subscriptions
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }
}