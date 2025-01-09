// src/preload-styles.ts
export function preloadStyles() {
    const styles = [
      'components',
      'utils'
    ];
  
    styles.forEach(style => {
      const link = document.createElement('link');
      link.rel = 'preload';
      link.as = 'style';
      link.href = `${style}.css`;
      document.head.appendChild(link);
    });
  }