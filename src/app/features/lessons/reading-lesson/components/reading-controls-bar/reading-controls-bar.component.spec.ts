import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ReadingControlsBarComponent } from './reading-controls-bar.component';

describe('ReadingControlsBarComponent', () => {
  let component: ReadingControlsBarComponent;
  let fixture: ComponentFixture<ReadingControlsBarComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ReadingControlsBarComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ReadingControlsBarComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
