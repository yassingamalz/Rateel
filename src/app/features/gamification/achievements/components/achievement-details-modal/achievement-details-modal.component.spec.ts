import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AchievementDetailsModalComponent } from './achievement-details-modal.component';

describe('AchievementDetailsModalComponent', () => {
  let component: AchievementDetailsModalComponent;
  let fixture: ComponentFixture<AchievementDetailsModalComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [AchievementDetailsModalComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AchievementDetailsModalComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
