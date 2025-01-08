import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DefaultLessonComponent } from './default-lesson.component';

describe('DefaultLessonComponent', () => {
  let component: DefaultLessonComponent;
  let fixture: ComponentFixture<DefaultLessonComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [DefaultLessonComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(DefaultLessonComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
