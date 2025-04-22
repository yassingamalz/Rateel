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
  isCurrentUserVisible: boolean = false;
  visibleRowsStart: number = 3; // Start after medals
  visibleRowsEnd: number = 10; // Initial visible rows
  scrollCheckThrottle: number = 0; // For performance optimization

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

    // End is calculated from displayLimit, but add space for sticky user position
    this.visibleRowsEnd = Math.max(this.displayLimit - 1, 3);
  }

  // Filter the leaderboard based on selected filter
  setFilter(filter: 'all' | 'friends' | 'region'): void {
    this.currentFilter = filter;

    // Apply the filter
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

    // Important: Reset visibility state when changing tabs
    this.isCurrentUserVisible = false;
    this.highlightedCurrentUser = false;

    // Force check if user is immediately visible after filter change
    setTimeout(() => {
      this.checkCurrentUserVisibility();
      this.cdr.markForCheck();
    }, 100);

    // Recalculate visible rows
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

    // Create 15 users with mock data
    const mockUsers: GamificationUser[] = [];

    for (let i = 0; i < 15; i++) {
      // Make the 8th user (index 7) the current user for testing
      const isCurrentUser = i === 7;

      mockUsers.push({
        id: `user-${i + 1}`,
        rank: i + 1, // Will be updated after sorting
        name: names[i % names.length],
        avatar: avatars[i % avatars.length],
        score: isCurrentUser ? 4500 : 12500 - (i * 800) + Math.floor(Math.random() * 100),
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

    // Calculate display limit (excluding top 3 and space for fixed user)
    const displayLimit = this.visibleRowsEnd - 3;

    // If there are fewer players than our limit, show all
    if (displayLimit >= regularPlayers.length) {
      return regularPlayers;
    }

    // Otherwise, limit to our calculated display limit 
    return regularPlayers.slice(0, displayLimit);
  }

  // Improved current user position logic with comprehensive checks
  shouldShowCurrentUserAtBottom(): boolean {
    // Don't show if there's no current user
    if (!this.currentUserPosition) {
      return false;
    }

    // Check if current user exists in the filtered list
    const userInFilteredList = this.filteredLeaderboard.some(user => user.isCurrentUser);
    if (!userInFilteredList) {
      return false; // Don't show if user is not in the filtered list (important for tab switching)
    }

    // Don't show if current user is in top 3 (medals)
    if (this.currentUserPosition.rank <= 3) {
      return false;
    }

    // Don't show if we're already seeing the current user's real position
    if (this.isCurrentUserVisible) {
      return false;
    }

    // Find user's position in the filtered list
    const userIndex = this.filteredLeaderboard.findIndex(user => user.isCurrentUser);

    // If within the visible display limit, check if actually visible in viewport
    const isWithinInitialDisplayList = userIndex >= 0 && userIndex < this.visibleRowsEnd;
    if (isWithinInitialDisplayList && this.tableBodyRef) {
      // Check if the user's element exists and is visible
      const currentUserElement = document.getElementById(`player-${this.currentUserPosition.rank}`);
      if (currentUserElement) {
        const tableRect = this.tableBodyRef.nativeElement.getBoundingClientRect();
        const elemRect = currentUserElement.getBoundingClientRect();

        // If actually visible in the viewport, don't show fixed position
        if (elemRect.top >= tableRect.top && elemRect.bottom <= tableRect.bottom) {
          this.isCurrentUserVisible = true;
          return false;
        }
      }
    }

    // Default: show fixed position
    return true;
  }

  // Improved scroll handling for better tab support
  onTableScroll(): void {
    // Skip frequent checks for performance
    this.scrollCheckThrottle++;
    if (this.scrollCheckThrottle % 3 !== 0) return;

    if (!this.tableBodyRef || this.isScrollingToCurrentUser) {
      return;
    }

    // Don't do anything if current user isn't in the filtered list
    const userInFilteredList = this.filteredLeaderboard.some(user => user.isCurrentUser);
    if (!this.currentUserPosition || !userInFilteredList) {
      return;
    }

    // Check if current user exists in filtered list
    const userIndex = this.filteredLeaderboard.findIndex(user => user.isCurrentUser);
    if (userIndex === -1) {
      this.isCurrentUserVisible = false;
      this.cdr.detectChanges();
      return;
    }

    const currentUserElement = document.getElementById(`player-${this.currentUserPosition.rank}`);

    if (currentUserElement) {
      // Check if element is in viewport
      const tableRect = this.tableBodyRef.nativeElement.getBoundingClientRect();
      const elemRect = currentUserElement.getBoundingClientRect();

      // Determine if the current user's actual position is visible
      const isVisible =
        elemRect.top >= tableRect.top &&
        elemRect.bottom <= tableRect.bottom;

      // Update visibility state
      if (isVisible !== this.isCurrentUserVisible) {
        this.isCurrentUserVisible = isVisible;

        // Add highlight effect if newly visible
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

        this.cdr.detectChanges();
      }
    }
  }

  // Helper method to check current user visibility
  private checkCurrentUserVisibility(): void {
    if (!this.currentUserPosition || !this.tableBodyRef) {
      this.isCurrentUserVisible = false;
      return;
    }

    // Check if current user exists in the filtered list
    const userInFilteredList = this.filteredLeaderboard.some(user => user.isCurrentUser);
    if (!userInFilteredList) {
      this.isCurrentUserVisible = false;
      return;
    }

    // Get the DOM element
    const currentUserElement = document.getElementById(`player-${this.currentUserPosition.rank}`);
    if (!currentUserElement) {
      this.isCurrentUserVisible = false;
      return;
    }

    // Check visibility in viewport
    const tableRect = this.tableBodyRef.nativeElement.getBoundingClientRect();
    const elemRect = currentUserElement.getBoundingClientRect();

    this.isCurrentUserVisible =
      elemRect.top >= tableRect.top &&
      elemRect.bottom <= tableRect.bottom;
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
      this.tableBodyRef.nativeElement.scrollTo({
        top: currentUserElement.offsetTop - 100, // Offset to show some content above
        behavior: 'smooth'
      });

      // Add highlight animation after scrolling
      setTimeout(() => {
        currentUserElement.classList.add('animate-highlight');
        this.isCurrentUserVisible = true;
        this.highlightedCurrentUser = true;

        // Remove animation class after it completes
        setTimeout(() => {
          if (currentUserElement) {
            currentUserElement.classList.remove('animate-highlight');
          }
          this.isScrollingToCurrentUser = false;
          this.cdr.markForCheck();
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
      this.displayLimit = 6; // Very small screens
    } else if (height < 600) {
      this.displayLimit = 8; // Small screens
    } else if (height < 800) {
      this.displayLimit = 10; // Medium screens
    } else {
      this.displayLimit = 12; // Large screens
    }
  }

  ngOnDestroy(): void {
    // Clean up subscriptions
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }
}