import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AchievementBadgeComponent } from './achievement-badge.component';

describe('AchievementBadgeComponent', () => {
  let component: AchievementBadgeComponent;
  let fixture: ComponentFixture<AchievementBadgeComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [AchievementBadgeComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AchievementBadgeComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
