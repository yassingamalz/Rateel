import { ComponentFixture, TestBed } from '@angular/core/testing';

import { QuestionDetailsModalComponent } from './question-details-modal.component';

describe('QuestionDetailsModalComponent', () => {
  let component: QuestionDetailsModalComponent;
  let fixture: ComponentFixture<QuestionDetailsModalComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [QuestionDetailsModalComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(QuestionDetailsModalComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
