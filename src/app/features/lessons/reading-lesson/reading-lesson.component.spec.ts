import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ReadingLessonComponent } from './reading-lesson.component';

describe('ReadingLessonComponent', () => {
  let component: ReadingLessonComponent;
  let fixture: ComponentFixture<ReadingLessonComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ReadingLessonComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ReadingLessonComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
