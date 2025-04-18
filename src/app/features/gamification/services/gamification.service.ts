import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { catchError, tap, map } from 'rxjs/operators';

export interface GamificationUser {
  id: string;
  rank: number;
  name: string;
  avatar: string;
  score: number;
  completedLessons: number;
  isCurrentUser: boolean;
  isFriend: boolean;
  region: string;
}

export interface PointsActivity {
  id: string;
  userId: string;
  title: string;
  points: number;
  date: Date;
  icon?: string;
  type: 'earned' | 'spent' | 'bonus';
  context?: {
    lessonId?: string;
    courseId?: string;
    achievement?: string;
  };
}

export interface Achievement {
  id: string;
  title: string;
  description: string;
  icon: string;
  type: 'bronze' | 'silver' | 'gold' | 'platinum' | 'diamond';
  points: number;
  requirement: {
    type: 'lessons_completed' | 'score_reached' | 'streak' | 'perfect_score' | 'custom';
    value: number;
    customCheck?: string;
  };
  isUnlocked: boolean;
  progress: number;
  dateUnlocked?: Date;
}

@Injectable({
  providedIn: 'root'
})
export class GamificationService {
  // BehaviorSubjects to track various gamification states
  private userScore = new BehaviorSubject<number>(0);
  private userActivities = new BehaviorSubject<PointsActivity[]>([]);
  private userAchievements = new BehaviorSubject<Achievement[]>([]);
  private leaderboardData = new BehaviorSubject<GamificationUser[]>([]);
  
  // Local storage keys
  private readonly STORAGE_KEYS = {
    SCORE: 'tajweed_user_score',
    ACTIVITIES: 'tajweed_user_activities',
    ACHIEVEMENTS: 'tajweed_user_achievements',
    LEADERBOARD: 'tajweed_leaderboard'
  };

  constructor(private http: HttpClient) {
    this.loadInitialData();
  }

  /**
   * Load initial data from local storage or API
   */
  private loadInitialData(): void {
    // Try to load from localStorage first
    this.loadFromLocalStorage();
    
    // Then try to load from API (which will update localStorage if successful)
    this.loadFromApi();
  }
  
  /**
   * Load gamification data from local storage
   */
  private loadFromLocalStorage(): void {
    try {
      // Load score
      const scoreData = localStorage.getItem(this.STORAGE_KEYS.SCORE);
      if (scoreData) {
        this.userScore.next(JSON.parse(scoreData));
      }
      
      // Load activities
      const activitiesData = localStorage.getItem(this.STORAGE_KEYS.ACTIVITIES);
      if (activitiesData) {
        const activities: PointsActivity[] = JSON.parse(activitiesData);
        // Convert string dates back to Date objects
        activities.forEach(a => a.date = new Date(a.date));
        this.userActivities.next(activities);
      }
      
      // Load achievements
      const achievementsData = localStorage.getItem(this.STORAGE_KEYS.ACHIEVEMENTS);
      if (achievementsData) {
        const achievements: Achievement[] = JSON.parse(achievementsData);
        // Convert string dates back to Date objects
        achievements.forEach(a => {
          if (a.dateUnlocked) {
            a.dateUnlocked = new Date(a.dateUnlocked);
          }
        });
        this.userAchievements.next(achievements);
      }
      
      // Load leaderboard
      const leaderboardData = localStorage.getItem(this.STORAGE_KEYS.LEADERBOARD);
      if (leaderboardData) {
        this.leaderboardData.next(JSON.parse(leaderboardData));
      }
      
      console.log('Loaded gamification data from localStorage');
    } catch (error) {
      console.error('Error loading gamification data from localStorage:', error);
    }
  }
  
  /**
   * Load gamification data from API
   */
  private loadFromApi(): void {
    // In a real app, these would be API calls
    // For now, we'll simulate them with timeouts
    
    // Simulate API delay
    setTimeout(() => {
      // If we don't have data in localStorage, generate mock data
      if (this.userScore.value === 0) {
        this.generateMockData();
      }
    }, 1000);
  }
  
  /**
   * Generate mock data for testing
   */
  private generateMockData(): void {
    // Generate mock score
    const score = Math.floor(Math.random() * 1000) + 500;
    this.userScore.next(score);
    
    // Generate mock activities
    const activities: PointsActivity[] = [];
    const activityTypes = ['earned', 'bonus', 'spent'] as const;
    const activityTitles = [
      'إكمال درس النون الساكنة',
      'إكمال اختبار بنجاح',
      'إكمال تحدي الإدغام',
      'إنجاز متتالي',
      'مكافأة يومية',
      'إكمال المقرر الأساسي'
    ];
    
    for (let i = 0; i < 10; i++) {
      const type = activityTypes[Math.floor(Math.random() * activityTypes.length)];
      const title = activityTitles[Math.floor(Math.random() * activityTitles.length)];
      const points = type === 'spent' ? 
        -(Math.floor(Math.random() * 50) + 10) : 
        (Math.floor(Math.random() * 50) + 10);
      
      // Generate a date within the last 30 days
      const date = new Date();
      date.setDate(date.getDate() - Math.floor(Math.random() * 30));
      
      activities.push({
        id: `activity-${i}`,
        userId: 'current-user',
        title,
        points,
        date,
        type,
        icon: type === 'bonus' ? 'gift' : undefined
      });
    }
    
    // Sort by date (newest first)
    activities.sort((a, b) => b.date.getTime() - a.date.getTime());
    this.userActivities.next(activities);
    
    // Generate mock achievements
    const achievements: Achievement[] = [
      {
        id: 'achievement-1',
        title: 'بداية الرحلة',
        description: 'أكمل 5 دروس من المقرر',
        icon: 'graduation-cap',
        type: 'bronze',
        points: 50,
        requirement: {
          type: 'lessons_completed',
          value: 5
        },
        isUnlocked: true,
        progress: 100,
        dateUnlocked: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) // 7 days ago
      },
      {
        id: 'achievement-2',
        title: 'متقن القراءة',
        description: 'أكمل 10 دروس من المقرر',
        icon: 'book',
        type: 'silver',
        points: 100,
        requirement: {
          type: 'lessons_completed',
          value: 10
        },
        isUnlocked: true,
        progress: 100,
        dateUnlocked: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000) // 3 days ago
      },
      {
        id: 'achievement-3',
        title: 'حافظ النص',
        description: 'أكمل جميع دروس المقرر الأساسي',
        icon: 'award',
        type: 'gold',
        points: 200,
        requirement: {
          type: 'lessons_completed',
          value: 20
        },
        isUnlocked: false,
        progress: 70
      },
      {
        id: 'achievement-4',
        title: 'المتفوق',
        description: 'احصل على علامة كاملة في 5 اختبارات',
        icon: 'trophy',
        type: 'platinum',
        points: 300,
        requirement: {
          type: 'perfect_score',
          value: 5
        },
        isUnlocked: false,
        progress: 40
      },
      {
        id: 'achievement-5',
        title: 'سيد التجويد',
        description: 'أكمل جميع مقررات التجويد',
        icon: 'crown',
        type: 'diamond',
        points: 500,
        requirement: {
          type: 'custom',
          value: 1,
          customCheck: 'complete_all_courses'
        },
        isUnlocked: false,
        progress: 25
      }
    ];
    
    this.userAchievements.next(achievements);
    
    // Generate mock leaderboard data
    const avatars = Array.from({ length: 10 }, (_, i) => `assets/images/avatars/avatar-${i+1}.png`);
    
    const names = [
      'محمد أحمد',
      'فاطمة علي',
      'عبدالله محمد',
      'نورة سلطان',
      'أحمد عبدالرحمن',
      'سارة خالد',
      'يوسف محمد',
      'ليلى أحمد',
      'حسن علي',
      'ريم سعد',
      'عمر محمد',
      'جواهر فهد',
      'خالد ناصر',
      'سلمى عبدالله',
      'طلال فيصل'
    ];
    
    const leaderboard: GamificationUser[] = [];
    
    for (let i = 0; i < 15; i++) {
      const isCurrentUser = i === 4; // Make the 5th user the current user
      
      leaderboard.push({
        id: `user-${i + 1}`,
        rank: i + 1, // Will be overridden after sorting
        name: names[i],
        avatar: avatars[i % avatars.length],
        score: isCurrentUser ? score : Math.floor(Math.random() * 1000) + 500,
        completedLessons: Math.floor(Math.random() * 30) + 5,
        isCurrentUser,
        isFriend: Math.random() > 0.6,
        region: ['الرياض', 'جدة', 'الدمام', 'المدينة', 'مكة'][Math.floor(Math.random() * 5)]
      });
    }
    
    // Sort by score
    leaderboard.sort((a, b) => b.score - a.score);
    
    // Update ranks based on sorted order
    leaderboard.forEach((user, index) => {
      user.rank = index + 1;
    });
    
    this.leaderboardData.next(leaderboard);
    
    // Save to localStorage
    this.saveToLocalStorage();
    
    console.log('Generated mock gamification data');
  }
  
  /**
   * Save current state to localStorage
   */
  private saveToLocalStorage(): void {
    try {
      localStorage.setItem(this.STORAGE_KEYS.SCORE, JSON.stringify(this.userScore.value));
      localStorage.setItem(this.STORAGE_KEYS.ACTIVITIES, JSON.stringify(this.userActivities.value));
      localStorage.setItem(this.STORAGE_KEYS.ACHIEVEMENTS, JSON.stringify(this.userAchievements.value));
      localStorage.setItem(this.STORAGE_KEYS.LEADERBOARD, JSON.stringify(this.leaderboardData.value));
    } catch (error) {
      console.error('Error saving gamification data to localStorage:', error);
    }
  }
  
  // PUBLIC API METHODS
  
  /**
   * Get user's current score
   */
  getUserScore(): Observable<number> {
    return this.userScore.asObservable();
  }
  
  /**
   * Get user's points activities
   */
  getUserActivities(): Observable<PointsActivity[]> {
    return this.userActivities.asObservable();
  }
  
  /**
   * Get user's achievements
   */
  getUserAchievements(): Observable<Achievement[]> {
    return this.userAchievements.asObservable();
  }
  
  /**
   * Get leaderboard data
   */
  getLeaderboard(): Observable<GamificationUser[]> {
    return this.leaderboardData.asObservable();
  }
  
  /**
   * Add points to user's score and create an activity
   */
  addPoints(title: string, points: number, type: 'earned' | 'bonus' = 'earned', context?: any): Observable<number> {
    // Update score
    const newScore = this.userScore.value + points;
    this.userScore.next(newScore);
    
    // Create activity record
    const activity: PointsActivity = {
      id: `activity-${Date.now()}`,
      userId: 'current-user',
      title,
      points,
      date: new Date(),
      type,
      context
    };
    
    // Add to activities
    const activities = [activity, ...this.userActivities.value];
    this.userActivities.next(activities);
    
    // Check for achievement unlocks
    this.checkAchievements();
    
    // Update leaderboard
    this.updateLeaderboard();
    
    // Save to localStorage
    this.saveToLocalStorage();
    
    return of(newScore);
  }
  
  /**
   * Subtract points from user's score and create an activity
   */
  subtractPoints(title: string, points: number, context?: any): Observable<number> {
    // Make sure points is positive
    const pointsToSubtract = Math.abs(points);
    
    // Update score
    const newScore = Math.max(0, this.userScore.value - pointsToSubtract);
    this.userScore.next(newScore);
    
    // Create activity record
    const activity: PointsActivity = {
      id: `activity-${Date.now()}`,
      userId: 'current-user',
      title,
      points: -pointsToSubtract,
      date: new Date(),
      type: 'spent',
      context
    };
    
    // Add to activities
    const activities = [activity, ...this.userActivities.value];
    this.userActivities.next(activities);
    
    // Update leaderboard
    this.updateLeaderboard();
    
    // Save to localStorage
    this.saveToLocalStorage();
    
    return of(newScore);
  }
  
  /**
   * Complete a lesson and earn points
   */
  completeLessonEarnPoints(lessonId: string, lessonTitle: string, courseId: string, pointsEarned: number): Observable<number> {
    return this.addPoints(
      `إكمال درس ${lessonTitle}`,
      pointsEarned,
      'earned',
      { lessonId, courseId }
    );
  }
  
  /**
   * Complete an assessment with a perfect score
   */
  completeAssessmentPerfectScore(assessmentId: string, assessmentTitle: string, courseId: string): Observable<number> {
    // Award bonus points for perfect score
    return this.addPoints(
      `درجة كاملة في ${assessmentTitle}`,
      50,
      'bonus',
      { assessmentId, courseId }
    );
  }
  
  /**
   * Award daily streak bonus
   */
  awardDailyStreak(streakDays: number): Observable<number> {
    const bonusPoints = Math.min(50, 10 * streakDays);
    return this.addPoints(
      `مكافأة استمرار ${streakDays} أيام`,
      bonusPoints,
      'bonus',
      { streakDays }
    );
  }
  
  /**
   * Check for achievement unlocks based on current state
   */
  private checkAchievements(): void {
    const achievements = [...this.userAchievements.value];
    let achievementsUpdated = false;
    
    // Check each locked achievement
    achievements.forEach(achievement => {
      if (achievement.isUnlocked) {
        return;
      }
      
      let newProgress = 0;
      let isUnlocked = false;
      
      // Calculate progress based on requirement type
      switch (achievement.requirement.type) {
        case 'lessons_completed':
          // Calculate from activities
          const lessonsCompleted = this.userActivities.value.filter(
            a => a.type === 'earned' && a.context?.lessonId
          ).length;
          newProgress = Math.min(100, Math.round((lessonsCompleted / achievement.requirement.value) * 100));
          isUnlocked = lessonsCompleted >= achievement.requirement.value;
          break;
          
        case 'score_reached':
          newProgress = Math.min(100, Math.round((this.userScore.value / achievement.requirement.value) * 100));
          isUnlocked = this.userScore.value >= achievement.requirement.value;
          break;
          
        case 'perfect_score':
          const perfectScores = this.userActivities.value.filter(
            a => a.type === 'bonus' && a.title.includes('درجة كاملة')
          ).length;
          newProgress = Math.min(100, Math.round((perfectScores / achievement.requirement.value) * 100));
          isUnlocked = perfectScores >= achievement.requirement.value;
          break;
      }
      
      // Update achievement if progress changed
      if (newProgress !== achievement.progress || isUnlocked !== achievement.isUnlocked) {
        achievement.progress = newProgress;
        
        // If newly unlocked, update status and add points
        if (isUnlocked && !achievement.isUnlocked) {
          achievement.isUnlocked = true;
          achievement.dateUnlocked = new Date();
          achievementsUpdated = true;
          
          // Add points for achievement
          this.addPoints(
            `إنجاز جديد: ${achievement.title}`,
            achievement.points,
            'bonus',
            { achievementId: achievement.id }
          ).subscribe();
        }
      }
    });
    
    // Update the achievements BehaviorSubject if changes were made
    if (achievementsUpdated) {
      this.userAchievements.next(achievements);
      this.saveToLocalStorage();
    }
  }
  
  /**
   * Update the leaderboard with the current user's score
   */
  private updateLeaderboard(): void {
    const leaderboard = [...this.leaderboardData.value];
    
    // Find current user
    const currentUserIndex = leaderboard.findIndex(user => user.isCurrentUser);
    if (currentUserIndex >= 0) {
      // Update score
      leaderboard[currentUserIndex].score = this.userScore.value;
      
      // Update completed lessons count
      const lessonsCompleted = this.userActivities.value.filter(
        a => a.type === 'earned' && a.context?.lessonId
      ).length;
      leaderboard[currentUserIndex].completedLessons = lessonsCompleted;
      
      // Re-sort leaderboard
      leaderboard.sort((a, b) => b.score - a.score);
      
      // Update ranks
      leaderboard.forEach((user, index) => {
        user.rank = index + 1;
      });
      
      this.leaderboardData.next(leaderboard);
    }
  }
  
  /**
   * Reset all gamification data (mostly for testing)
   */
  resetAllData(): Observable<boolean> {
    // Clear all data
    this.userScore.next(0);
    this.userActivities.next([]);
    this.userAchievements.next([]);
    this.leaderboardData.next([]);
    
    // Clear localStorage
    localStorage.removeItem(this.STORAGE_KEYS.SCORE);
    localStorage.removeItem(this.STORAGE_KEYS.ACTIVITIES);
    localStorage.removeItem(this.STORAGE_KEYS.ACHIEVEMENTS);
    localStorage.removeItem(this.STORAGE_KEYS.LEADERBOARD);
    
    // Generate new mock data after a short delay
    setTimeout(() => this.generateMockData(), 500);
    
    return of(true);
  }
}