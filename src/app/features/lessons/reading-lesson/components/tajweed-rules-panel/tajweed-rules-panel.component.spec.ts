import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TajweedRulesPanelComponent } from './tajweed-rules-panel.component';

describe('TajweedRulesPanelComponent', () => {
  let component: TajweedRulesPanelComponent;
  let fixture: ComponentFixture<TajweedRulesPanelComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [TajweedRulesPanelComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(TajweedRulesPanelComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
