import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-question-actions',
  standalone: false,
  
  templateUrl: './question-actions.component.html',
  styleUrl: './question-actions.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class QuestionActionsComponent {

}
