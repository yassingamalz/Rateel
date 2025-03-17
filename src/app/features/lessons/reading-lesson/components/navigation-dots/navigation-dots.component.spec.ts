import { ComponentFixture, TestBed } from '@angular/core/testing';

import { NavigationDotsComponent } from './navigation-dots.component';

describe('NavigationDotsComponent', () => {
  let component: NavigationDotsComponent;
  let fixture: ComponentFixture<NavigationDotsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [NavigationDotsComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(NavigationDotsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
