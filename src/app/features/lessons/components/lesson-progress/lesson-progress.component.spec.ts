import { ComponentFixture, TestBed } from '@angular/core/testing';

import { LessonProgressComponent } from './lesson-progress.component';

describe('LessonProgressComponent', () => {
  let component: LessonProgressComponent;
  let fixture: ComponentFixture<LessonProgressComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [LessonProgressComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(LessonProgressComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
