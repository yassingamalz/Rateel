import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PointsCardComponent } from './points-card.component';

describe('PointsCardComponent', () => {
  let component: PointsCardComponent;
  let fixture: ComponentFixture<PointsCardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [PointsCardComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(PointsCardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
