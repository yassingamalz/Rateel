import { TestBed } from '@angular/core/testing';

import { DynamicModalService } from './dynamic-modal.service';

describe('DynamicModalService', () => {
  let service: DynamicModalService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(DynamicModalService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
