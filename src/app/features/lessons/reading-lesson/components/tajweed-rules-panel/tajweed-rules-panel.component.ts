import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { TajweedRule } from '../../reading-lesson.types';

@Component({
  selector: 'app-tajweed-rules-panel',
  standalone: false,
  templateUrl: './tajweed-rules-panel.component.html',
  styleUrls: ['./tajweed-rules-panel.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class TajweedRulesPanelComponent {
  @Input() rules: TajweedRule[] = [];
  @Input() selectedRuleId?: string;
  @Input() currentTheme: string = 'theme-dark';

  @Output() ruleClicked = new EventEmitter<string>();
  @Output() searchChanged = new EventEmitter<string>();
  @Output() closePanel = new EventEmitter<void>();

  searchTerm: string = '';

  onRuleClick(ruleId: string): void {
    this.ruleClicked.emit(ruleId);
  }

  onSearch(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.searchTerm = input.value;
    this.searchChanged.emit(this.searchTerm);
  }

  clearSearch(): void {
    this.searchTerm = '';
    this.searchChanged.emit('');
  }

  onClose(): void {
    this.closePanel.emit();
  }

  isRuleActive(ruleId: string): boolean {
    return this.selectedRuleId === ruleId;
  }
}