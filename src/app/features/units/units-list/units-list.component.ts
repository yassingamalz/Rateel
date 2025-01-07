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
  dragStarted = false;
  startX = 0;
  scrollLeft = 0;
  dragThreshold = 5;
  dragStartTime = Date.now();
  mouseInitialX = 0;
  dragSpeedMultiplier = 2.5; // Increase for faster dragging
  inertiaMultiplier = 200;   // Increase for more momentum after release

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

  onMouseDown(event: MouseEvent): void {
    if ((event.target as HTMLElement).closest('.unit-item')) {
      this.dragStarted = true;
      this.mouseInitialX = event.pageX;
      this.startX = event.pageX;
      this.scrollLeft = this.unitsContainer.nativeElement.scrollLeft;
      this.dragStartTime = Date.now();
    }
  }

  onMouseMove(event: MouseEvent): void {
    if (!this.dragStarted) return;

    const dragDistance = Math.abs(event.pageX - this.mouseInitialX);
    if (dragDistance > this.dragThreshold) {
      this.isDragging = true;
    }

    const walk = (event.pageX - this.startX) * this.dragSpeedMultiplier;
    this.unitsContainer.nativeElement.scrollLeft = this.scrollLeft - walk;
  }

  onMouseUp(event: MouseEvent): void {
    if (!this.dragStarted) return;

    const dragDistance = Math.abs(event.pageX - this.mouseInitialX);
    const dragDuration = Date.now() - this.dragStartTime;

    if (!this.isDragging && dragDistance < this.dragThreshold && dragDuration < 200) {
      const unitElement = (event.target as HTMLElement).closest('[data-unit-id]');
      if (unitElement) {
        const unitId = unitElement.getAttribute('data-unit-id');
        const units = (this.units$ as any).value;
        const unit = units?.find((u: Unit) => u.id === unitId);
        if (unit && !unit.isLocked) {
          this.onUnitSelected(unit);
        }
      }
    } else if (dragDistance > this.dragThreshold) {
      const speed = dragDistance / dragDuration;
      const inertiaDistance = speed * this.inertiaMultiplier;

      this.unitsContainer.nativeElement.scrollBy({
        left: -inertiaDistance,
        behavior: 'smooth'
      });
    }

    this.isDragging = false;
    this.dragStarted = false;
  }

  onMouseLeave(): void {
    if (this.dragStarted) {
      this.isDragging = false;
      this.dragStarted = false;
    }
  }

  onTouchStart(event: TouchEvent): void {
    if ((event.target as HTMLElement).closest('.unit-item')) {
      this.dragStarted = true;
      this.mouseInitialX = event.touches[0].pageX;
      this.startX = event.touches[0].pageX;
      this.scrollLeft = this.unitsContainer.nativeElement.scrollLeft;
      this.dragStartTime = Date.now();
    }
  }

  onTouchMove(event: TouchEvent): void {
    if (!this.dragStarted) return;

    const dragDistance = Math.abs(event.touches[0].pageX - this.mouseInitialX);
    if (dragDistance > this.dragThreshold) {
      this.isDragging = true;
    }

    const walk = (event.touches[0].pageX - this.startX) * this.dragSpeedMultiplier;
    this.unitsContainer.nativeElement.scrollLeft = this.scrollLeft - walk;
  }

  onTouchEnd(event: TouchEvent): void {
    if (!this.dragStarted) return;

    const touch = event.changedTouches[0];
    const dragDistance = Math.abs(touch.pageX - this.mouseInitialX);
    const dragDuration = Date.now() - this.dragStartTime;

    if (!this.isDragging && dragDistance < this.dragThreshold && dragDuration < 200) {
      const unitElement = (event.target as HTMLElement).closest('[data-unit-id]');
      if (unitElement) {
        const unitId = unitElement.getAttribute('data-unit-id');
        const units = (this.units$ as any).value;
        const unit = units?.find((u: Unit) => u.id === unitId);
        if (unit && !unit.isLocked) {
          this.onUnitSelected(unit);
        }
      }
    } else if (dragDistance > this.dragThreshold) {
      const speed = dragDistance / dragDuration;
      const inertiaDistance = speed * 100;

      this.unitsContainer.nativeElement.scrollBy({
        left: -inertiaDistance,
        behavior: 'smooth'
      });
    }

    this.isDragging = false;
    this.dragStarted = false;
  }

  onUnitSelected(unit: Unit): void {
    if (!unit.isLocked) {
      this.activeUnitId = unit.id;
      this.router.navigate(['/courses', this.courseId, 'units', unit.id, 'lessons']);
    }
  }

  getConnectorProgress(currentUnit: Unit, nextUnit: Unit): number {
    if (currentUnit.isCompleted) return 100;
    if (nextUnit.isLocked) return 0;
    return (currentUnit.progress || 0) / 2;
  }
}