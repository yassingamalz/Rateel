import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CompletionModalComponent } from './completion-modal.component';

describe('CompletionModalComponent', () => {
  let component: CompletionModalComponent;
  let fixture: ComponentFixture<CompletionModalComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [CompletionModalComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CompletionModalComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
