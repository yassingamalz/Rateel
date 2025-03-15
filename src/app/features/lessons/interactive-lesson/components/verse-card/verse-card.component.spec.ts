import { ComponentFixture, TestBed } from '@angular/core/testing';

import { VerseCardComponent } from './verse-card.component';

describe('VerseCardComponent', () => {
  let component: VerseCardComponent;
  let fixture: ComponentFixture<VerseCardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [VerseCardComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(VerseCardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
