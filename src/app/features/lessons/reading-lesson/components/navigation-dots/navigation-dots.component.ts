import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';

@Component({
  selector: 'app-navigation-dots',
  standalone: false,
  templateUrl: './navigation-dots.component.html',
  styleUrls: ['./navigation-dots.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class NavigationDotsComponent {
  @Input() totalVerses: number = 0;
  @Input() currentIndex: number = 0;
  @Input() currentTheme: string = 'theme-dark';

  @Output() verseSelected = new EventEmitter<number>();

  goToVerse(index: number): void {
    this.verseSelected.emit(index);
  }

  isActive(index: number): boolean {
    return index === this.currentIndex;
  }

  isCompleted(index: number): boolean {
    return index < this.currentIndex;
  }

  getVerseIndices(): number[] {
    return Array.from({ length: this.totalVerses }, (_, i) => i);
  }
}