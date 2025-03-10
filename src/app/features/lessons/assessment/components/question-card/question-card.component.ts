import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-question-card',
  standalone: false,
  
  templateUrl: './question-card.component.html',
  styleUrl: './question-card.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class QuestionCardComponent {

}
