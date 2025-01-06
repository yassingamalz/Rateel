import { ComponentFixture, TestBed } from '@angular/core/testing';

import { LessonHeaderComponent } from './lesson-header.component';

describe('LessonHeaderComponent', () => {
  let component: LessonHeaderComponent;
  let fixture: ComponentFixture<LessonHeaderComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [LessonHeaderComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(LessonHeaderComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
