import { Component, Input, ChangeDetectionStrategy } from '@angular/core';

@Component({
  selector: 'app-tajweed-legend',
  standalone: false,
  templateUrl: './tajweed-legend.component.html',
  styleUrls: ['./tajweed-legend.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class TajweedLegendComponent {
  @Input() rules: { rule: string; color: string; }[] = [];
  @Input() isActive = false;
}