import { TestBed } from '@angular/core/testing';

import { DailyChallengesService } from './daily-challenges.service';

describe('DailyChallengesService', () => {
  let service: DailyChallengesService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(DailyChallengesService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
