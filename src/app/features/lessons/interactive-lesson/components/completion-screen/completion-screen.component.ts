import { Component, Input, ChangeDetectionStrategy } from '@angular/core';
import { trigger, transition, style, animate } from '@angular/animations';

@Component({
  selector: 'app-completion-screen',
  standalone: false,
  templateUrl: './completion-screen.component.html',
  styleUrls: ['./completion-screen.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('completionAnimation', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('500ms ease-out', style({ opacity: 1 }))
      ]),
      transition(':leave', [
        animate('300ms ease-in', style({ opacity: 0 }))
      ])
    ])
  ]
})
export class CompletionScreenComponent {
  // Make sure isCompleted has a default value of false
  @Input() isCompleted = false;
}