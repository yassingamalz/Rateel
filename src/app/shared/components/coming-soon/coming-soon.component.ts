// coming-soon.component.ts
import { Component, Input, OnInit, ChangeDetectionStrategy } from '@angular/core';
import { trigger, transition, style, animate, query, stagger, state } from '@angular/animations';

interface Feature {
  icon: string;
  title: string;
  description: string;
}

@Component({
  selector: 'app-coming-soon',
  standalone: false,
  templateUrl: './coming-soon.component.html',
  styleUrls: ['./coming-soon.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('featureAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateY(30px)' }),
        animate('600ms cubic-bezier(0.35, 0.1, 0.25, 1)', 
          style({ opacity: 1, transform: 'translateY(0)' }))
      ])
    ]),
    trigger('ornamentAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.5) rotate(-15deg)' }),
        animate('1000ms cubic-bezier(0.175, 0.885, 0.32, 1.275)',
          style({ opacity: 0.1, transform: 'scale(1) rotate(0)' }))
      ])
    ]),
    trigger('staggeredFeatures', [
      transition('* => *', [
        query(':enter', [
          style({ opacity: 0, transform: 'translateY(30px)' }),
          stagger('200ms', [
            animate('600ms cubic-bezier(0.35, 0.1, 0.25, 1)', 
              style({ opacity: 1, transform: 'translateY(0)' }))
          ])
        ], { optional: true })
      ])
    ]),
    trigger('floatAnimation', [
      state('start', style({ transform: 'translateY(0)' })),
      state('end', style({ transform: 'translateY(-15px)' })),
      transition('start <=> end', [
        animate('3000ms ease-in-out')
      ])
    ]),
    trigger('fadeInUp', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateY(40px)' }),
        animate('800ms 300ms ease-out', 
          style({ opacity: 1, transform: 'translateY(0)' }))
      ])
    ]),
    trigger('shimmerAnimation', [
      state('start', style({ 
        backgroundPosition: '-200px 0'
      })),
      state('end', style({ 
        backgroundPosition: '200px 0'
      })),
      transition('start <=> end', [
        animate('2000ms linear')
      ])
    ])
  ]
})
export class ComingSoonComponent implements OnInit {
  @Input() title: string = 'مستقبل التعلم قريباً';
  @Input() mainDescription: string = 'نحن نعمل بجد لتقديم تجربة تعليمية مميزة تجمع بين الإتقان والروحانية';

  upcomingFeatures: Feature[] = [
    {
      icon: 'fa-book-quran',
      title: 'دروس متقدمة',
      description: 'مناهج متخصصة في التجويد والقراءات'
    },
    {
      icon: 'fa-mosque',
      title: 'مسار روحاني',
      description: 'رحلة تعليمية تربط العلم بالعبادة'
    },
    {
      icon: 'fa-graduation-cap',
      title: 'شهادات معتمدة',
      description: 'برامج إجازة معتمدة من علماء متخصصين'
    },
    {
      icon: 'fa-users',
      title: 'مجتمع المتعلمين',
      description: 'انضم إلى مجتمع من المتعلمين في رحلة تحسين التلاوة'
    }
  ];

  emailAddress: string = '';
  isEmailSubmitted: boolean = false;
  floatState: 'start' | 'end' = 'start';
  shimmerState: 'start' | 'end' = 'start';
  subscribers: number = 512;
  showSubscriberCount: boolean = false;
  days: number = Math.floor(Math.random() * 30) + 20;

  ngOnInit() {
    this.startAnimations();
    setTimeout(() => {
      this.showSubscriberCount = true;
    }, 1500);
  }

  startAnimations() {
    // Start floating animation
    setInterval(() => {
      this.floatState = this.floatState === 'start' ? 'end' : 'start';
    }, 3000);

    // Start shimmer animation
    setInterval(() => {
      this.shimmerState = this.shimmerState === 'start' ? 'end' : 'start';
    }, 2000);
  }

  submitEmail() {
    if (this.validateEmail(this.emailAddress)) {
      // Simulate email submission
      this.isEmailSubmitted = true;
      this.subscribers++; // Increment subscriber count for visual feedback
    } else {
      // Show error or validation message
      alert('الرجاء إدخال بريد إلكتروني صحيح');
    }
  }

  private validateEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  resetEmailSubmission() {
    this.isEmailSubmitted = false;
    this.emailAddress = '';
  }

  // Touch-friendly parallax effect
  onMouseMove(event: MouseEvent) {
    // Use requestAnimationFrame for performance
    requestAnimationFrame(() => {
      const container = document.querySelector('.coming-soon') as HTMLElement;
      if (!container) return;

      const elements = container.querySelectorAll('.parallax-element');
      const centerX = window.innerWidth / 2;
      const centerY = window.innerHeight / 2;
      const moveX = (event.clientX - centerX) / 30;
      const moveY = (event.clientY - centerY) / 30;

      elements.forEach((element: Element, index: number) => {
        const htmlElement = element as HTMLElement;
        const depth = parseFloat(htmlElement.getAttribute('data-depth') || '0.1');
        const translateX = moveX * depth;
        const translateY = moveY * depth;

        htmlElement.style.transform = `translate(${translateX}px, ${translateY}px)`;
      });
    });
  }

  // For mobile touch events
  onTouchMove(event: TouchEvent) {
    if (event.touches.length > 0) {
      this.onMouseMove(event.touches[0] as unknown as MouseEvent);
    }
  }
}