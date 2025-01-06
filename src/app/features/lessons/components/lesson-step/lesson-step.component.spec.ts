import { ComponentFixture, TestBed } from '@angular/core/testing';

import { LessonStepComponent } from './lesson-step.component';

describe('LessonStepComponent', () => {
  let component: LessonStepComponent;
  let fixture: ComponentFixture<LessonStepComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [LessonStepComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(LessonStepComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
