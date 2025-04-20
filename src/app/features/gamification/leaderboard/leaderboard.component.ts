// src/app/features/gamification/leaderboard/leaderboard.component.ts
import { Component, OnInit, OnDestroy, ChangeDetectionStrategy, ChangeDetectorRef, HostListener, ViewChild, ElementRef } from '@angular/core';
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
  @ViewChild('tableBodyRef') tableBodyRef!: ElementRef;

  // Data properties
  leaderboard: GamificationUser[] = [];
  filteredLeaderboard: GamificationUser[] = [];
  currentUserPosition: GamificationUser | null = null;
  currentFilter: 'all' | 'friends' | 'region' = 'all';
  displayLimit: number = 10;
  isLoading: boolean = true;
  highlightedCurrentUser: boolean = false;
  isScrollingToCurrentUser: boolean = false;
  visibleRowsStart: number = 3; // Start after medals
  visibleRowsEnd: number = 10; // Initial visible rows

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

          // Calculate initially visible rows
          this.calculateVisibleRows();

          this.isLoading = false;
          this.cdr.markForCheck();
        },
        error: (error) => {
          console.error('Error loading leaderboard data:', error);

          // Generate mock data on error
          this.generateMockData();
          this.setFilter('all');
          this.findCurrentUserPosition();
          this.calculateVisibleRows();

          this.isLoading = false;
          this.cdr.markForCheck();
        }
      })
    );
  }

  // Calculate which rows should be initially visible
  private calculateVisibleRows(): void {
    // If we have screen height info, adjust displayLimit
    this.checkScreenDimensions();

    // Start after medals (3)
    this.visibleRowsStart = 3;

    // End is calculated from displayLimit, but minimum 3
    this.visibleRowsEnd = Math.max(this.displayLimit, 3);

    // If current user is beyond visible range, adjust to show them at the bottom
    if (this.currentUserPosition &&
      this.currentUserPosition.rank > 3 &&
      this.currentUserPosition.rank > this.visibleRowsEnd) {
      // We'll handle this in getDisplayedRegularPlayers()
    }
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

    // Recalculate visible rows after filtering
    this.calculateVisibleRows();
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

  // Get players to display (excluding top 3 with medals)
  getDisplayedRegularPlayers(): GamificationUser[] {
    if (!this.filteredLeaderboard || this.filteredLeaderboard.length <= 3) {
      return [];
    }

    // Get regular players (after top 3)
    const regularPlayers = this.filteredLeaderboard.slice(3);

    // Check if current user is in regular players but outside visible range
    const displayLimit = this.visibleRowsEnd - 3; // Adjust for the 3 medal positions

    // Base case: just show next rows after medals
    if (displayLimit >= regularPlayers.length) {
      // If we can display all, return all
      return regularPlayers;
    }

    // If current user is beyond display limit, replace last visible with current user
    if (this.currentUserPosition &&
      this.currentUserPosition.rank > 3 &&
      !this.shouldShowCurrentUserAtBottom()) {
      // Current user is within regular displayed range, return normal slice
      return regularPlayers.slice(0, displayLimit);
    }

    // If we need to swap last visible row with current user (handled in template),
    // return one less to make room for current user at bottom
    if (this.shouldShowCurrentUserAtBottom()) {
      return regularPlayers.slice(0, displayLimit - 1);
    }

    // Default case: return standard slice
    return regularPlayers.slice(0, displayLimit);
  }

  // Determine if we should show current user at the bottom of the visible area
  shouldShowCurrentUserAtBottom(): boolean {
    if (!this.currentUserPosition) {
      return false;
    }

    // Don't show at bottom if current user is in top 3 (medals)
    if (this.currentUserPosition.rank <= 3) {
      return false;
    }

    // Get index in filtered leaderboard (accounting for medals)
    const currentUserIndex = this.filteredLeaderboard.findIndex(user => user.isCurrentUser);

    // If not in view range, show at bottom
    return currentUserIndex >= this.visibleRowsEnd;
  }

  // Handle table scrolling
  onTableScroll(): void {
    if (!this.tableBodyRef || this.isScrollingToCurrentUser) {
      return;
    }

    // Check if current user element is visible
    if (this.currentUserPosition && this.currentUserPosition.rank > 3) {
      const currentUserElement = document.getElementById(`player-${this.currentUserPosition.rank}`);

      if (currentUserElement) {
        // Check if element is in viewport
        const rect = currentUserElement.getBoundingClientRect();
        const isVisible = (
          rect.top >= 0 &&
          rect.left >= 0 &&
          rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
          rect.right <= (window.innerWidth || document.documentElement.clientWidth)
        );

        // If visible and not already highlighted, add highlight effect
        if (isVisible && !this.highlightedCurrentUser) {
          currentUserElement.classList.add('animate-highlight');
          this.highlightedCurrentUser = true;

          // Remove the highlight class after animation completes
          setTimeout(() => {
            if (currentUserElement) {
              currentUserElement.classList.remove('animate-highlight');
            }
          }, 1500);
        }
      }
    }
  }

  // Scroll to current user's position
  scrollToCurrentUser(): void {
    if (!this.currentUserPosition || !this.tableBodyRef) {
      return;
    }

    this.isScrollingToCurrentUser = true;

    // Get the current user's element
    const currentUserElement = document.getElementById(`player-${this.currentUserPosition.rank}`);
    if (currentUserElement) {
      // Scroll to the element
      currentUserElement.scrollIntoView({ behavior: 'smooth', block: 'center' });

      // Add highlight animation after scrolling
      setTimeout(() => {
        currentUserElement.classList.add('animate-highlight');

        // Remove animation class after it completes
        setTimeout(() => {
          if (currentUserElement) {
            currentUserElement.classList.remove('animate-highlight');
          }
          this.isScrollingToCurrentUser = false;
        }, 1500);
      }, 500);
    } else {
      this.isScrollingToCurrentUser = false;
    }
  }

  // Listen for window resize to adjust displayLimit
  @HostListener('window:resize')
  onResize(): void {
    this.checkScreenDimensions();
    this.calculateVisibleRows();
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