import { ComponentFixture, TestBed } from '@angular/core/testing';

import { QuestionActionsComponent } from './question-actions.component';

describe('QuestionActionsComponent', () => {
  let component: QuestionActionsComponent;
  let fixture: ComponentFixture<QuestionActionsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [QuestionActionsComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(QuestionActionsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
