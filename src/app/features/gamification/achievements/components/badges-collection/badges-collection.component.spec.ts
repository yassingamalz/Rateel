import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BadgesCollectionComponent } from './badges-collection.component';

describe('BadgesCollectionComponent', () => {
  let component: BadgesCollectionComponent;
  let fixture: ComponentFixture<BadgesCollectionComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [BadgesCollectionComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(BadgesCollectionComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
