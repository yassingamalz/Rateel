import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';

@Component({
  selector: 'app-recording-controls',
  standalone: false,
  templateUrl: './recording-controls.component.html',
  styleUrls: ['./recording-controls.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class RecordingControlsComponent {
  @Input() isRecording = false;
  @Input() isCompleted = false;
  
  @Output() recordingToggle = new EventEmitter<Event>();

  // Wave bar heights for the audio visualization
  waveBarHeights = [10, 15, 20, 25, 30, 20, 15];
  
  /**
   * Toggles recording state and passes the original event to parent
   */
  toggleRecording(event: Event): void {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }
    
    this.recordingToggle.emit(event);
  }
}