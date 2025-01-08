import { TestBed } from '@angular/core/testing';

import { AssetPreloaderService } from './asset-preloader.service';

describe('AssetPreloaderService', () => {
  let service: AssetPreloaderService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(AssetPreloaderService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
