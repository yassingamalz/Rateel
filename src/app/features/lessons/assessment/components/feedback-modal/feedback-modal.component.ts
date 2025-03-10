import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-feedback-modal',
  standalone: false,
  
  templateUrl: './feedback-modal.component.html',
  styleUrl: './feedback-modal.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class FeedbackModalComponent {

}
