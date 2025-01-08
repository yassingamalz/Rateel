import { TestBed } from '@angular/core/testing';

import { ContentCacheService } from './content-cache.service';

describe('ContentCacheService', () => {
  let service: ContentCacheService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(ContentCacheService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
