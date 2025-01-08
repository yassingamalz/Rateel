// src/app/features/lessons/reading-lesson/reading-lesson.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { TajweedRule, ReadingState, TajweedMark, ReadingContent } from './reading-lesson.types';

@Injectable({
  providedIn: 'root'
})
export class ReadingLessonService {
  private readonly MIN_FONT_SIZE = 18;
  private readonly MAX_FONT_SIZE = 36;
  private readonly DEFAULT_FONT_SIZE = 24;

  private tajweedRules: TajweedRule[] = [
    {
      id: 'idgham',
      name: 'إدغام',
      color: '#FF5733',
      description: 'دمج حرفين متماثلين أو متقاربين بحيث يصيران حرفاً واحداً مشدداً'
    },
    {
      id: 'ikhfa',
      name: 'إخفاء',
      color: '#33FF57',
      description: 'النطق بالحرف بصفة بين الإظهار والإدغام'
    },
    {
      id: 'qalqalah',
      name: 'قلقلة',
      color: '#3357FF',
      description: 'اضطراب الصوت عند النطق بالحرف الساكن حتى يسمع له نبرة قوية'
    },
    // Add more rules as needed
  ];

  private state = new BehaviorSubject<ReadingState>({
    fontSize: this.DEFAULT_FONT_SIZE,
    showRules: false,
    progress: 0,
    isCompleted: false
  });

  getState(): Observable<ReadingState> {
    return this.state.asObservable();
  }

  getTajweedRules(): TajweedRule[] {
    return this.tajweedRules;
  }

  getRuleById(ruleId: string): TajweedRule | undefined {
    return this.tajweedRules.find(rule => rule.id === ruleId);
  }

  selectRule(ruleId: string): void {
    const rule = this.getRuleById(ruleId);
    this.state.next({
      ...this.state.value,
      selectedRule: rule
    });
  }

  clearSelectedRule(): void {
    this.state.next({
      ...this.state.value,
      selectedRule: undefined
    });
  }

  toggleRulesPanel(): void {
    this.state.next({
      ...this.state.value,
      showRules: !this.state.value.showRules
    });
  }

  increaseFontSize(): void {
    if (this.state.value.fontSize < this.MAX_FONT_SIZE) {
      this.state.next({
        ...this.state.value,
        fontSize: this.state.value.fontSize + 2
      });
    }
  }

  decreaseFontSize(): void {
    if (this.state.value.fontSize > this.MIN_FONT_SIZE) {
      this.state.next({
        ...this.state.value,
        fontSize: this.state.value.fontSize - 2
      });
    }
  }

  updateProgress(verseIndex: number, totalVerses: number): void {
    const progress = ((verseIndex + 1) / totalVerses) * 100;
    this.state.next({
      ...this.state.value,
      currentVerse: verseIndex,
      progress,
      isCompleted: progress >= 100
    });
  }

  parseContent(content: string): ReadingContent {
    try {
      // Assuming content is a JSON string with the correct structure
      const parsedContent: ReadingContent = JSON.parse(content);
      
      // Validate the content structure
      if (!Array.isArray(parsedContent.verses)) {
        throw new Error('Invalid content structure: verses array missing');
      }

      return parsedContent;
    } catch (error) {
      console.error('Error parsing reading content:', error);
      return {
        verses: [],
        title: 'Error loading content'
      };
    }
  }

  resetState(): void {
    this.state.next({
      fontSize: this.DEFAULT_FONT_SIZE,
      showRules: false,
      progress: 0,
      isCompleted: false
    });
  }

  formatTajweedText(text: string, marks: TajweedMark[]): string {
    let result = text;
    // Sort marks by start index in descending order to avoid index shifting
    const sortedMarks = [...marks].sort((a, b) => b.startIndex - a.startIndex);

    for (const mark of sortedMarks) {
      const rule = this.getRuleById(mark.ruleId);
      if (rule) {
        const markedText = `<span class="tajweed-mark" style="color: ${rule.color};" data-rule="${mark.ruleId}">${mark.text}</span>`;
        result = result.slice(0, mark.startIndex) + markedText + result.slice(mark.endIndex);
      }
    }

    return result;
  }
}