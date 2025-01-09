// src/app/shared/components/loading/loading.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-loading',
  standalone: false,
  template: `
    <div class="loading-container">
      <!-- Main Circle -->
      <div class="loading-circle">
        <!-- Rotating outer ring -->
        <div class="loading-ring"></div>
        
        <!-- Inner circle with icon -->
        <div class="loading-inner">
          <div class="loading-icon">
            <i class="fas fa-book"></i>
          </div>
        </div>
      </div>

      <!-- Loading Text -->
      <div class="loading-text">
        <h3>جاري التحميل...</h3>
        <p>يرجى الانتظار</p>
      </div>
      
      <!-- Loading Dots -->
      <div class="loading-dots">
        <div class="dot"></div>
        <div class="dot"></div>
        <div class="dot"></div>
      </div>
    </div>
  `,
  styles: [`
    .loading-container {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 400px;
      width: 100%;
    }

    .loading-circle {
      position: relative;
      width: 8rem;
      height: 8rem;
      margin-bottom: 2rem;
    }

    .loading-ring {
      position: absolute;
      inset: 0;
      border-radius: 50%;
      border: 4px solid transparent;
      border-top-color: #DAA520;
      animation: spin 1s linear infinite;
    }

    .loading-inner {
      position: absolute;
      inset: 0.5rem;
      border-radius: 50%;
      background: rgba(218, 165, 32, 0.2);
      backdrop-filter: blur(8px);
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .loading-icon {
      width: 3rem;
      height: 3rem;
      border-radius: 50%;
      background: #DAA520;
      display: flex;
      align-items: center;
      justify-content: center;
      animation: pulse 2s infinite;
    }

    .loading-icon i {
      font-size: 1.5rem;
      color: #081C15;
    }

    .loading-text {
      text-align: center;
    }

    .loading-text h3 {
      color: #FFFFFF;
      font-size: 1.25rem;
      font-weight: 600;
      margin-bottom: 0.5rem;
    }

    .loading-text p {
      color: #95D5B2;
      font-size: 0.875rem;
    }

    .loading-dots {
      display: flex;
      gap: 0.5rem;
      margin-top: 1rem;
    }

    .dot {
      width: 0.5rem;
      height: 0.5rem;
      border-radius: 50%;
      background: #DAA520;
      animation: bounce 1s infinite;
    }

    .dot:nth-child(2) { animation-delay: 0.2s; }
    .dot:nth-child(3) { animation-delay: 0.4s; }

    @keyframes spin {
      to { transform: rotate(360deg); }
    }

    @keyframes pulse {
      0%, 100% { transform: scale(1); }
      50% { transform: scale(1.1); }
    }

    @keyframes bounce {
      0%, 100% { transform: translateY(0); }
      50% { transform: translateY(-0.5rem); }
    }
  `]
})
export class LoadingComponent { }