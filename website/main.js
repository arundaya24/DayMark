// DAYMARK Landing Page Scripts

(function () {
  'use strict';

  // Mobile nav toggle
  const toggle = document.getElementById('navToggle');
  const menu = document.getElementById('mobileMenu');

  if (toggle && menu) {
    toggle.addEventListener('click', () => {
      toggle.classList.toggle('open');
      menu.classList.toggle('open');
    });

    // Close on link click
    menu.querySelectorAll('.mobile-menu-link').forEach((link) => {
      link.addEventListener('click', () => {
        toggle.classList.remove('open');
        menu.classList.remove('open');
      });
    });
  }

  // Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener('click', (e) => {
      const target = document.querySelector(anchor.getAttribute('href'));
      if (target) {
        e.preventDefault();
        const offset = 72;
        const top = target.getBoundingClientRect().top + window.pageYOffset - offset;
        window.scrollTo({ top, behavior: 'smooth' });
      }
    });
  });

  // Generate heatmap cells
  function generateHeatmap(container, cols, rows) {
    if (!container) return;
    const levels = ['var(--heat-0)', 'var(--heat-1)', 'var(--heat-2)', 'var(--heat-3)', 'var(--heat-4)'];
    const weights = [0.40, 0.22, 0.18, 0.12, 0.08]; // probability weights: more empty, fewer intense
    const total = cols * rows;

    for (let i = 0; i < total; i++) {
      const cell = document.createElement('div');
      cell.classList.add('hm-cell');

      // Weighted random level
      const r = Math.random();
      let cumulative = 0;
      let level = 0;
      for (let w = 0; w < weights.length; w++) {
        cumulative += weights[w];
        if (r <= cumulative) {
          level = w;
          break;
        }
      }

      cell.style.background = levels[level];
      container.appendChild(cell);
    }
  }

  // Sim heatmap in phone mock (13 cols x 7 rows)
  generateHeatmap(document.getElementById('simHeatmap'), 13, 7);

  // Bento heatmap (26 cols x 7 rows)
  generateHeatmap(document.getElementById('bentoHeatmap'), 26, 7);

  // Nav background on scroll
  const nav = document.getElementById('nav');
  let ticking = false;

  function onScroll() {
    if (!ticking) {
      window.requestAnimationFrame(() => {
        if (window.scrollY > 10) {
          nav.style.borderBottomColor = 'var(--clr-border)';
        } else {
          nav.style.borderBottomColor = 'var(--clr-border-subtle)';
        }
        ticking = false;
      });
      ticking = true;
    }
  }

  window.addEventListener('scroll', onScroll, { passive: true });

  // Intersection observer for section fade-in
  if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    const sections = document.querySelectorAll('.section, .hero');
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.08 }
    );

    sections.forEach((s) => {
      s.style.opacity = '0';
      s.style.transform = 'translateY(24px)';
      s.style.transition = `opacity 0.6s var(--ease-out, cubic-bezier(0.22, 1, 0.36, 1)), transform 0.6s var(--ease-out, cubic-bezier(0.22, 1, 0.36, 1))`;
      observer.observe(s);
    });
  }

  // Apply visible class styles
  const style = document.createElement('style');
  style.textContent = `.visible { opacity: 1 !important; transform: translateY(0) !important; }`;
  document.head.appendChild(style);
})();
