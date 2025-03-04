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
    {
      id: 'adab-general',
      name: 'آداب عامة',
      color: '#1F4037',
      description: 'الآداب العامة المتعلقة بتلاوة القرآن الكريم'
    },
    {
      id: 'adab-title',
      name: 'عنوان',
      color: '#DAA520',
      description: 'عناوين الآداب والأقسام'
    },
    {
      id: 'quran-verse',
      name: 'آية قرآنية',
      color: '#B87333',
      description: 'آية من القرآن الكريم'
    }
    // Additional rules will be loaded from content
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
      console.log('[ReadingLessonService] Parsing content...');
      // Parse the content JSON string to object
      const parsedContent: ReadingContent = typeof content === 'string' 
        ? JSON.parse(content) 
        : content;
      
      // Validate the content structure
      if (!Array.isArray(parsedContent.verses)) {
        console.error('[ReadingLessonService] Invalid content structure: verses array missing');
        return {
          verses: [],
          title: 'Error loading content'
        };
      }

      // If the content includes custom tajweed rules, add them to our collection
      if (Array.isArray(parsedContent.rules) && parsedContent.rules.length > 0) {
        // Merge the custom rules with the default ones, avoiding duplicates
        const existingRuleIds = new Set(this.tajweedRules.map(r => r.id));
        
        for (const rule of parsedContent.rules) {
          if (!existingRuleIds.has(rule.id)) {
            this.tajweedRules.push(rule);
            existingRuleIds.add(rule.id);
          }
        }
      }

      return parsedContent;
    } catch (error) {
      console.error('[ReadingLessonService] Error parsing reading content:', error);
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
    
    // If no marks, return the text as is
    if (!marks || marks.length === 0) {
      return result;
    }
    
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