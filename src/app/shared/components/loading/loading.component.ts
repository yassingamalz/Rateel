// src/app/shared/components/loading/loading.component.ts
import { Component, Input, OnInit } from '@angular/core';

@Component({
  selector: 'app-loading',
  standalone: false,
  templateUrl: './loading.component.html',
  styleUrls: ['./loading.component.scss']
})
export class LoadingComponent implements OnInit {
  @Input() message: string = 'جاري التحميل...';
  @Input() submessage: string = 'يرجى الانتظار';
  @Input() showProgress: boolean = false;
  @Input() progress: number = 0;

  // For the geometric pattern animation
  patternElements: number[] = [];

  ngOnInit() {
    // Initialize animation elements with random delays
    this.patternElements = Array(8).fill(0).map(() => Math.random() * 2);
  }
}