import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

// Import all interactive lesson components
import { VerseCardComponent } from './components/verse-card/verse-card.component';
import { VersesContainerComponent } from './components/verses-container/verses-container.component';
import { RecordingControlsComponent } from './components/recording-controls/recording-controls.component';
import { FeedbackOverlayComponent } from './components/feedback-overlay/feedback-overlay.component';
import { CompletionScreenComponent } from './components/completion-screen/completion-screen.component';
import { TajweedLegendComponent } from './components/tajweed-legend/tajweed-legend.component';
import { HelpTipsComponent } from './components/help-tips/help-tips.component';
import { UniqueRulesPipe } from './pipes/unique-rules.pipe';

@NgModule({
  declarations: [
    VerseCardComponent,
    VersesContainerComponent,
    RecordingControlsComponent,
    FeedbackOverlayComponent,
    CompletionScreenComponent,
    TajweedLegendComponent,
    HelpTipsComponent,
    UniqueRulesPipe
  ],
  imports: [
    CommonModule
  ],
  exports: [
    VerseCardComponent,
    VersesContainerComponent,
    RecordingControlsComponent,
    FeedbackOverlayComponent,
    CompletionScreenComponent,
    TajweedLegendComponent,
    HelpTipsComponent,
    UniqueRulesPipe
  ]
})
export class InteractiveLessonComponentsModule { }