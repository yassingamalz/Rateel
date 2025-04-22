import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AchievementHeaderComponent } from './achievement-header.component';

describe('AchievementHeaderComponent', () => {
  let component: AchievementHeaderComponent;
  let fixture: ComponentFixture<AchievementHeaderComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [AchievementHeaderComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AchievementHeaderComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
