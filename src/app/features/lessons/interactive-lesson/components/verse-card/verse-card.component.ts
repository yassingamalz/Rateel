import { Component, Input, OnChanges, SimpleChanges, ChangeDetectionStrategy } from '@angular/core';
import { TajweedVerse } from '../../interactive-lesson.types';

@Component({
  selector: 'app-verse-card',
  standalone: false,
  templateUrl: './verse-card.component.html',
  styleUrls: ['./verse-card.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class VerseCardComponent implements OnChanges {
  @Input() verse!: TajweedVerse;
  @Input() verseIndex!: number;
  @Input() isActive = false;
  @Input() isCompleted = false;
  @Input() currentWordIndex?: number;
  @Input() recognizedWords: Set<number> = new Set<number>();

  words: string[] = [];

  // Arabic numeral mapping
  private arabicNumerals: {[key: string]: string} = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩'
  };

  // Word counts for each verse (based on your logs)
  private verseWordCounts = [4, 4, 5, 4, 3];

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['verse'] && this.verse) {
      this.words = this.splitVerseIntoWords(this.verse.text);
    }
  }

  /**
   * Converts western numerals to Arabic numerals
   */
  convertToArabicNumeral(num: number): string {
    return num.toString().split('').map(digit => 
      this.arabicNumerals[digit] || digit
    ).join('');
  }

  /**
   * Splits verse text into words
   */
  splitVerseIntoWords(text: string): string[] {
    if (!text) return [];
    return text.trim().split(/\s+/).filter(Boolean);
  }

  /**
   * Checks if a word has a tajweed highlight
   */
  hasHighlight(word: string, wordIndex: number): boolean {
    if (!this.verse.highlights) return false;

    const wordStart = this.getWordStartIndex(this.verse.text, wordIndex);
    const wordEnd = wordStart + word.length;

    return this.verse.highlights.some(h =>
      (h.start >= wordStart && h.start < wordEnd) ||
      (h.end > wordStart && h.end <= wordEnd) ||
      (wordStart >= h.start && wordEnd <= h.end)
    );
  }

  /**
   * Gets color for a word based on tajweed rule
   */
  getWordColor(word: string, wordIndex: number): string {
    if (!this.verse.highlights) return '';

    const wordStart = this.getWordStartIndex(this.verse.text, wordIndex);

    // Find all highlights that contain this word
    const matchingHighlights = this.verse.highlights.filter(h =>
      (h.start <= wordStart && h.end >= wordStart + word.length) ||
      (wordStart <= h.start && wordStart + word.length >= h.end)
    );

    // Return the color of the first matching highlight
    return matchingHighlights.length > 0 ? matchingHighlights[0].color : '';
  }

  /**
   * Gets the word start index in the verse text
   */
  private getWordStartIndex(text: string, wordIndex: number): number {
    if (!text) return 0;

    const words = text.split(/\s+/);
    let startIndex = 0;

    for (let i = 0; i < wordIndex && i < words.length; i++) {
      startIndex += words[i].length + 1; // +1 for the space
    }

    return startIndex;
  }

  /**
   * Checks if a word has been spoken/recognized
   */
  isWordSpoken(wordIndex: number): boolean {
    const globalIndex = this.getGlobalWordIndex(this.verseIndex, wordIndex);
    return this.recognizedWords.has(globalIndex);
  }

  /**
   * Checks if this is the current word being spoken
   */
  isCurrentWord(wordIndex: number): boolean {
    if (this.currentWordIndex === undefined) return false;
    const globalIndex = this.getGlobalWordIndex(this.verseIndex, wordIndex);
    return this.currentWordIndex === globalIndex;
  }

  /**
   * Converts local word index to global word index
   * Takes into account all previous verses' words
   */
  private getGlobalWordIndex(verseIndex: number, wordIndex: number): number {
    // Calculate base index from all previous verses
    let baseIndex = 0;
    
    // Sum up word counts from all previous verses
    for (let i = 0; i < verseIndex; i++) {
      // Use the word counts array if index is available, otherwise default to 4
      baseIndex += i < this.verseWordCounts.length ? 
        this.verseWordCounts[i] : 4;
    }
    
    return baseIndex + wordIndex;
  }
}