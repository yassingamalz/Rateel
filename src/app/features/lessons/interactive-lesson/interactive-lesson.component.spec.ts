import { ComponentFixture, TestBed } from '@angular/core/testing';

import { InteractiveLessonComponent } from './interactive-lesson.component';

describe('InteractiveLessonComponent', () => {
  let component: InteractiveLessonComponent;
  let fixture: ComponentFixture<InteractiveLessonComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [InteractiveLessonComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(InteractiveLessonComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
