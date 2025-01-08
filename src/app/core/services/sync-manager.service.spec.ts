import { TestBed } from '@angular/core/testing';

import { SyncManagerService } from './sync-manager.service';

describe('SyncManagerService', () => {
  let service: SyncManagerService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(SyncManagerService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
