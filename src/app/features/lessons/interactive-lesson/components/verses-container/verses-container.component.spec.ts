import { ComponentFixture, TestBed } from '@angular/core/testing';

import { VersesContainerComponent } from './verses-container.component';

describe('VersesContainerComponent', () => {
  let component: VersesContainerComponent;
  let fixture: ComponentFixture<VersesContainerComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [VersesContainerComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(VersesContainerComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
