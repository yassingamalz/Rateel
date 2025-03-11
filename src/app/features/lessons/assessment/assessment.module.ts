// src/app/features/lessons/assessment/assessment.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { SharedModule } from '../../../shared/shared.module';
import { QuestionCardComponent } from './components/question-card/question-card.component';
import { QuestionNavigatorComponent } from './components/question-navigator/question-navigator.component';
import { FeedbackModalComponent } from './components/feedback-modal/feedback-modal.component';
import { CompletionModalComponent } from './components/completion-modal/completion-modal.component';
import { QuestionDetailsModalComponent } from './components/question-details-modal/question-details-modal.component';
import { QuestionActionsComponent } from './components/question-actions/question-actions.component';
import { AssessmentResultsComponent } from './components/assessment-results/assessment-results.component';

@NgModule({
  declarations: [
    QuestionCardComponent,
    QuestionNavigatorComponent,
    FeedbackModalComponent,
    CompletionModalComponent,
    QuestionDetailsModalComponent,
    QuestionActionsComponent,
    AssessmentResultsComponent,
  ],
  imports: [
    CommonModule,
    FormsModule,
    SharedModule
  ],
  exports: [
    QuestionCardComponent,
    QuestionNavigatorComponent,
    FeedbackModalComponent,
    CompletionModalComponent,
    QuestionDetailsModalComponent,
    AssessmentResultsComponent
  ]
})
export class AssessmentModule { }