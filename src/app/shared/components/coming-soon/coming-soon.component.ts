// coming-soon.component.ts
import { Component, Input, OnInit, ChangeDetectionStrategy } from '@angular/core';
import { trigger, transition, style, animate } from '@angular/animations';

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
        style({ opacity: 0, transform: 'translateY(20px)' }),
        animate('500ms ease-out', style({ opacity: 1, transform: 'translateY(0)' }))
      ])
    ]),
    trigger('ornamentAnimation', [
      transition(':enter', [
        style({ opacity: 0, scale: 0.5 }),
        animate('700ms cubic-bezier(0.175, 0.885, 0.32, 1.275)',
          style({ opacity: 1, scale: 1 }))
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
    }
  ];

  emailAddress: string = '';
  isEmailSubmitted: boolean = false;

  ngOnInit() {
    // Optional: Add any initialization logic
  }

  submitEmail() {
    if (this.validateEmail(this.emailAddress)) {
      // TODO: Implement actual email submission logic
      console.log('Submitted email:', this.emailAddress);
      this.isEmailSubmitted = true;
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
}