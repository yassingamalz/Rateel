import { Component, Input, ChangeDetectionStrategy } from '@angular/core';

@Component({
  selector: 'app-user-score',
  standalone: false,
  templateUrl: './user-score.component.html',
  styleUrls: ['./user-score.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserScoreComponent {
  @Input() score: number = 0;
  @Input() size: 'sm' | 'md' | 'lg' = 'md';
  @Input() showIcon: boolean = true;
  @Input() customClass: string = '';
}