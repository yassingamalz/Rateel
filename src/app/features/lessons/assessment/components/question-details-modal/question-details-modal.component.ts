import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-question-details-modal',
  standalone: false,
  
  templateUrl: './question-details-modal.component.html',
  styleUrl: './question-details-modal.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class QuestionDetailsModalComponent {

}
