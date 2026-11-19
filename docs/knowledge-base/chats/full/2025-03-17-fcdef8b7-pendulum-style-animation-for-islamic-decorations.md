# Pendulum-Style Animation for Islamic Decorations

- Link: https://claude.ai/chat/fcdef8b7-a92b-4c4b-81c1-5e7519b57033
- Creata: 2025-03-17T01:36:53.255263Z
- Aggiornata: 2025-03-17T01:37:51.307762Z

## Yassin (2025-03-17T01:36)

.ambient-background {
  position: absolute;
  inset: 0;
  overflow: hidden;
  pointer-events: none;
  z-index: 0;
}

.islamic-decorations {
  position: absolute;
  inset: 0;
  z-index: 1;
  pointer-events: none;
  overflow: hidden;
  
  .decoration-svg {
    position: absolute;
    top: 10%;
    left: -30%; // Force positioning to left side
    width: 100%;
    height: 100%;
    opacity: 0.25; // Higher base opacity
    transform-origin: top left; // For pendulum effect
    animation: pendulum 8s ease-in-out infinite alternate; // Add pendulum animation
    transform: translateZ(0); // Force hardware acceleration
  }
}

// Define pendulum animation
@keyframes pendulum {
  0% {
    transform: rotate(-1deg);
  }
  50% {
    transform: rotate(1deg);
  }
  100% {
    transform: rotate(-1deg);
  }
}

// Theme-specific styles
.theme-dark {
  .islamic-decorations .decoration-svg {
    opacity: 0.2; // Adjust for dark theme
    filter: drop-shadow(0 0 10px rgba(218, 165, 32, 0.15));
  }
}

.theme-light {
  .islamic-decorations .decoration-svg {
    opacity: 0.25 !important; // Force visibility in light mode with !important
    filter: drop-shadow(0 0 8px rgba(196, 164, 132, 0.2));
  }
}

// Always ensure Islamic decorations are visible regardless of theme
.interactive-lesson.theme-light .islamic-decorations .decoration-svg,
.interactive-lesson.theme-dark .islamic-decorations .decoration-svg {
  visibility: visible !important;
  display: block !important;
}

// Media queries for responsive behavior
@media (max-width: 768px) {
  .islamic-decorations .decoration-svg {
    left: -40%; // Keep to the left on mobile
    width: 120%;
    height: 120%;
  }
}


i want to correct the aniamotn to be a panodol aniamton only from right to left

## Claude (2025-03-17T01:37)

I'll help you modify the pendulum animation to create a more specific right-to-left swaying motion. I'll update the keyframes to create a more controlled pendulum-like effect.

Here's an improved version for the decorative SVG animation:

**Artifact: islamic-decorations-style** (`application/vnd.ant.code`, create)

```scss
// Islamic Decorations Animation

.islamic-decorations {
  position: absolute;
  inset: 0;
  z-index: 1;
  pointer-events: none;
  overflow: hidden;
  
  .decoration-svg {
    position: absolute;
    top: 10%;
    left: -30%; // Force positioning to left side
    width: 100%;
    height: 100%;
    opacity: 0.25; // Higher base opacity
    transform-origin: top left; // Pivot point for animation
    animation: pendulumRightToLeft 8s ease-in-out infinite alternate; // Refined pendulum animation
    transform: translateZ(0); // Force hardware acceleration
  }
}

// Enhanced Pendulum Animation (Right to Left)
@keyframes pendulumRightToLeft {
  0% {
    transform: 
      translateX(0) 
      rotate(-3deg); // Start slightly rotated
  }
  50% {
    transform: 
      translateX(-20px)  // Subtle horizontal movement
      rotate(3deg);  // Opposite rotation
  }
  100% {
    transform: 
      translateX(0)
      rotate(-3deg); // Return to original position
  }
}

// Theme-specific styles
.theme-dark {
  .islamic-decorations .decoration-svg {
    opacity: 0.2; // Adjust for dark theme
    filter: drop-shadow(0 0 10px rgba(218, 165, 32, 0.15));
  }
}

.theme-light {
  .islamic-decorations .decoration-svg {
    opacity: 0.25 !important; // Force visibility in light mode with !important
    filter: drop-shadow(0 0 8px rgba(196, 164, 132, 0.2));
  }
}

// Always ensure Islamic decorations are visible regardless of theme
.interactive-lesson.theme-light .islamic-decorations .decoration-svg,
.interactive-lesson.theme-dark .islamic-decorations .decoration-svg {
  visibility: visible !important;
  display: block !important;
}

// Media queries for responsive behavior
@media (max-width: 768px) {
  .islamic-decorations .decoration-svg {
    left: -40%; // Keep to the left on mobile
    width: 120%;
    height: 120%;
  }
}

```

<details><summary>risultato tool</summary>

```
OK
```
</details>



The key changes in this updated version are:

1. Renamed the animation to `pendulumRightToLeft` for clarity
2. Added a subtle horizontal translation with `translateX()` to enhance the pendulum effect
3. Used smaller rotation angles (-3deg to 3deg) for a more natural swing
4. Kept the pivot point at the top left for a more realistic pendulum motion
5. Maintained the smooth `ease-in-out` timing for a natural swing

The animation now creates a more controlled, subtle right-to-left swaying motion that mimics a pendulum, with slight horizontal movement and rotation. The SVG will gently sway from its left anchor point, creating a more refined and elegant effect.

Would you like me to integrate this into the specific component's SCSS file, or would you prefer to keep it as a standalone artifact?
