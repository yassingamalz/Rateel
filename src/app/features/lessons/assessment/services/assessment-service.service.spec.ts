import { TestBed } from '@angular/core/testing';

import { AssessmentServiceService } from './assessment-service.service';

describe('AssessmentServiceService', () => {
  let service: AssessmentServiceService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(AssessmentServiceService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
