import { Component, Input, ChangeDetectionStrategy } from '@angular/core';

@Component({
  selector: 'app-help-tips',
  standalone: false,
  templateUrl: './help-tips.component.html',
  styleUrls: ['./help-tips.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class HelpTipsComponent {
  @Input() hasStartedLesson = false;
  @Input() isRecording = false;
  
  // Tips to display
  tips = [
    {
      icon: 'microphone',
      text: 'انقر على زر الميكروفون للبدء في القراءة'
    },
    {
      icon: 'arrows-alt-h',
      text: 'اسحب يميناً أو يساراً للتنقل بين الآيات'
    }
  ];
}