import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-question-navigator',
  standalone: false,
  
  templateUrl: './question-navigator.component.html',
  styleUrl: './question-navigator.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class QuestionNavigatorComponent {

}
