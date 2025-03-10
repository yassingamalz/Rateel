import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-completion-modal',
  standalone: false,
  
  templateUrl: './completion-modal.component.html',
  styleUrl: './completion-modal.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CompletionModalComponent {

}
