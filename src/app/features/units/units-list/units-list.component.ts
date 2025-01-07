// units-list.component.ts
import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Observable, BehaviorSubject } from 'rxjs';
import { UnitsService } from '../units.service';
import { Unit } from '../../../shared/interfaces/unit';

@Component({
  selector: 'app-units-list',
  standalone: false,
  templateUrl: './units-list.component.html',
  styleUrls: ['./units-list.component.scss']
})
export class UnitsListComponent implements OnInit {
  @ViewChild('unitsContainer') unitsContainer!: ElementRef;

  units$!: Observable<Unit[]>;
  courseId!: string;
  activeUnitId: string | null = null;
  isDragging = false;
  startX = 0;
  scrollLeft = 0;

  constructor(
    private unitsService: UnitsService,
    private route: ActivatedRoute,
    private router: Router
  ) { }

  ngOnInit(): void {
    this.courseId = this.route.snapshot.paramMap.get('courseId')!;
    this.unitsService.setCurrentCourse(this.courseId);
    this.units$ = this.unitsService.getUnitsByCourseId(this.courseId);

    const unitId = this.route.snapshot.paramMap.get('unitId');
    if (unitId) {
      this.activeUnitId = unitId;
    }
  }

  onUnitSelected(unit: Unit): void {
    if (!unit.isLocked) {
      console.log("hey")
      this.activeUnitId = unit.id;
      this.router.navigate(['/courses', this.courseId, 'units', unit.id, 'lessons'])
        .then(() => {
          // Scroll selected unit into view
          setTimeout(() => {
            const element = document.getElementById(`unit-${unit.id}`);
            if (element) {
              element.scrollIntoView({
                behavior: 'smooth',
                block: 'nearest',
                inline: 'center'
              });
            }
          }, 100);
        });
    }
  }

  getConnectorProgress(currentUnit: Unit, nextUnit: Unit): number {
    if (currentUnit.isCompleted) return 100;
    if (nextUnit.isLocked) return 0;
    return (currentUnit.progress || 0) / 2;
  }

  // Mouse event handlers for dragging
  onMouseDown(event: MouseEvent): void {
    this.isDragging = true;
    this.startX = event.pageX - this.unitsContainer.nativeElement.offsetLeft;
    this.scrollLeft = this.unitsContainer.nativeElement.scrollLeft;
  }

  onMouseMove(event: MouseEvent): void {
    if (!this.isDragging) return;
    event.preventDefault();
    const x = event.pageX - this.unitsContainer.nativeElement.offsetLeft;
    const walk = (x - this.startX) * 2;
    this.unitsContainer.nativeElement.scrollLeft = this.scrollLeft - walk;
  }

  onMouseUp(): void {
    this.isDragging = false;
  }

  onMouseLeave(): void {
    this.isDragging = false;
  }

  // Touch event handlers for mobile
  onTouchStart(event: TouchEvent): void {
    this.isDragging = true;
    this.startX = event.touches[0].pageX - this.unitsContainer.nativeElement.offsetLeft;
    this.scrollLeft = this.unitsContainer.nativeElement.scrollLeft;
  }

  onTouchMove(event: TouchEvent): void {
    if (!this.isDragging) return;
    const x = event.touches[0].pageX - this.unitsContainer.nativeElement.offsetLeft;
    const walk = (x - this.startX) * 2;
    this.unitsContainer.nativeElement.scrollLeft = this.scrollLeft - walk;
  }

  onTouchEnd(): void {
    this.isDragging = false;
  }
}