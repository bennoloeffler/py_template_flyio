# UI Design System - SystemPraktiker

## Design Vision & Mood Board

### Core Design Philosophy
**Modern. Clean. Professional. Accessible.**

The SystemPraktiker design system embodies clarity and purposefulness - reflecting the systematic thinking at the heart of the movement. Our design is not about flashy effects but about creating an intuitive, professional experience that makes users feel confident and oriented.

### Color Palette

#### Primary Orange Accent System
The orange color is the energy and warmth of the SystemPraktiker identity:

```
--orange-light:     #fed7aa  // Light backgrounds, subtle highlights
--orange-medium:    #fb923c  // Hover states, secondary actions
--orange-primary:   #ea580c  // Main CTA buttons, primary actions
--orange-dark:      #c2410c  // Active states, emphasis
--orange-shadow:    rgb(234 88 12 / 0.3)  // Shadows and glows
--orange-glow:      rgb(251 146 60 / 0.2) // Subtle ambient effects
```

**Usage Philosophy:**
- Orange = Action, Energy, Forward Movement
- Use sparingly for maximum impact
- Primary CTAs always orange
- Hover states consistently orange
- Links transition to orange on hover

#### Neutral Gray System
The foundation of visual hierarchy:

```
--gray-elegant:     #f8fafc  // Subtle backgrounds
--gray-soft:        #f1f5f9  // Card backgrounds
--gray-muted:       #64748b  // Secondary text
--gray-dark:        #334155  // Primary text
```

**Tailwind Gray Scale (50-950):**
- 50-200: Backgrounds and subtle borders
- 300-500: Inactive states, secondary UI
- 600-900: Text, active states, strong elements

#### Semantic Colors
```
Blue:     #3b82f6  // Information, trust (sparingly used)
Green:    #10b981  // Success, available actions
Red:      #ef4444  // Errors, warnings, destructive actions
```

### Typography System

#### Font Family
**Inter** - Modern, readable, professional
- 300: Light (headers, hero text)
- 400: Regular (body text)
- 500: Medium (buttons, labels)
- 600: Semibold (emphasis, card titles)
- 700: Bold (main headers)

#### Type Scale
```
Hero:           4xl-6xl (36px-60px) - extralight/light
Section Title:  3xl-5xl (30px-48px) - extralight
Subsection:     2xl-3xl (24px-30px) - light/medium
Card Title:     xl-2xl (20px-24px) - semibold
Body:           base-lg (16px-18px) - regular
Small:          sm-base (14px-16px) - regular/medium
Tiny:           xs-sm (12px-14px) - medium
```

### Spacing & Layout

#### Section Spacing
```
section-spacing:     5rem (80px) vertical
section-spacing-sm:  3rem (48px) vertical
section-spacing-lg:  7rem (112px) vertical
```

#### Component Spacing
```
Card padding:    6-8 (24px-32px)
Button padding:  px: 6-12 (24px-48px), py: 3-5 (12px-20px)
Grid gaps:       6-8 (24px-32px)
```

#### Max Widths
```
Content:  4xl (896px)  - Long-form text
Standard: 7xl (1280px) - Main content area
Hero:     Full width with contained content
```

### Shadow System

**Depth Hierarchy:**
```
--shadow-sm:   0 1px 2px rgba(0,0,0,0.05)       // Subtle lift
--shadow-md:   0 4px 6px rgba(0,0,0,0.1)        // Default cards
--shadow-lg:   0 10px 15px rgba(0,0,0,0.1)      // Hover states
--shadow-xl:   0 20px 25px rgba(0,0,0,0.1)      // Modals, popovers
--shadow-2xl:  0 25px 50px rgba(0,0,0,0.25)     // Maximum depth
```

### Border Radius System

**Consistency is Key:**
```
Small elements:  8px-12px   (badges, small buttons)
Cards/Buttons:   12px-16px  (standard components)
Large elements:  16px-24px  (hero cards, main CTAs)
Pills:           50px       (admin buttons, tags)
```

## Component Design Language

### 1. Navigation System

**Current Issues:**
- L Logo not linked to home
- L Buttons appear on hover (inconsistent)
- L Only cursor change indicates links

**Design Requirements:**

#### Logo
```html
<a href="/" class="flex items-center hover:opacity-80 transition-opacity">
    <img src="/static/SystemPraktiker-LOGO.png" alt="SystemPraktiker Home" class="h-12 w-auto">
</a>
```
- **MUST** link to home page
- Subtle opacity change on hover (0.8)
- No transform effects

#### Navigation Links
```css
.nav-link {
    transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    border-radius: 8px;
    padding: 8px 16px !important;
    color: #64748b;  /* gray-muted */
}

.nav-link:hover {
    color: var(--orange-primary);
    background: var(--gray-elegant);
    /* NO transform, NO button appearance */
}

.nav-link.active {
    color: var(--gray-dark);
    font-weight: 500;
}
```

**Hover Behavior:**
- Text color: gray ’ orange
- Background: transparent ’ subtle gray
- NO size changes
- NO button appearance
- NO transformations

### 2. Button System

**Current Issues:**
- L Inconsistent button sizes on homepage
- L "Jetzt mitmachen" sometimes with/without arrow
- L "Kontakt aufnehmen" buttons vary across pages
- L Gradient effects on some buttons

**Button Hierarchy:**

#### Primary CTA (.btn-cta)
```css
.btn-cta {
    background: var(--orange-primary);
    color: white;
    border-radius: 16px;
    padding: 12px 32px;  /* Consistent size */
    font-size: 16px;
    font-weight: 600;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    /* NO gradients in default state */
}

.btn-cta:hover {
    background: var(--orange-medium);
    transform: translateY(-2px);
    box-shadow: var(--shadow-xl), 0 0 30px var(--orange-shadow);
}

.btn-cta:active {
    transform: translateY(0);
}
```

**Rules:**
- Always solid orange (no gradients)
- Hover: lighter orange + lift + glow
- Consistent size across site
- Icon placement: always at end, always same icon per action type
- "Jetzt mitmachen" ’ always with arrow
- "Kontakt aufnehmen" ’ always with envelope icon

#### Secondary Button (.btn-elegant)
```css
.btn-elegant {
    background: white;
    color: var(--gray-dark);
    border: 1px solid rgba(148, 163, 184, 0.2);
    border-radius: 12px;
    padding: 10px 24px;
    transition: all 0.2s;
}

.btn-elegant:hover {
    border-color: var(--orange-primary);
    color: var(--orange-primary);
    transform: translateY(-2px);
    box-shadow: var(--shadow-lg);
}
```

**Rules:**
- White background, gray border
- Hover: orange border + orange text
- Subtle lift on hover
- Never a gradient

#### Admin Button (.btn-admin)
```css
.btn-admin {
    background: #475569;
    color: white;
    border-radius: 50px;  /* Full pill shape */
    padding: 10px 20px;
    transition: all 0.3s;
}

.btn-admin:hover {
    background: var(--orange-primary);
    transform: translateY(-2px);
}
```

### 3. Link System

**Current Issues:**
- L Inconsistent link indicators
- L Some links only show cursor change
- L No color change on text links

**Universal Link Rules:**

#### Text Links
```css
/* Default state */
.link-standard {
    color: var(--gray-muted);
    text-decoration: none;
    transition: color 0.2s;
    position: relative;
}

/* Hover state */
.link-standard:hover {
    color: var(--orange-primary);
    text-decoration: none;
}

/* Optional: underline animation */
.link-standard::after {
    content: '';
    position: absolute;
    bottom: -2px;
    left: 0;
    width: 0;
    height: 1px;
    background: var(--orange-primary);
    transition: width 0.2s;
}

.link-standard:hover::after {
    width: 100%;
}
```

#### Icon Links (arrows, etc.)
```css
.icon-link {
    color: var(--gray-muted);
    transition: all 0.2s;
}

.icon-link:hover {
    color: var(--orange-primary);
    transform: translateX(2px);  /* Subtle movement */
}
```

**Rules:**
- All links MUST show color change on hover (gray ’ orange)
- Text links MAY show underline animation
- Icon links MAY show subtle movement
- Cursor alone is NOT sufficient

### 4. Card System

**Current Issues:**
- L Principe boxes: arrow + "Mehr erfahren" text (redundant)
- L Inconsistent hover indicators

**Card Design:**

#### Standard Card (.elegant-card)
```css
.elegant-card {
    background: white;
    border: 1px solid rgba(148, 163, 184, 0.15);
    border-radius: 16px;
    box-shadow: var(--shadow-md);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.elegant-card:hover {
    transform: translateY(-4px);
    box-shadow: var(--shadow-lg);
    border-color: var(--orange-primary);
}
```

**Principle Cards Specific:**
```css
.principle-card {
    cursor: pointer;
}

.principle-card:hover {
    border-color: var(--orange-primary);
}

/* Arrow indicator only */
.principle-card .arrow-icon {
    color: var(--gray-muted);
    transition: all 0.2s;
}

.principle-card:hover .arrow-icon {
    color: var(--orange-primary);
}

/* Remove "Mehr erfahren" text - arrow is sufficient */
```

**Rules:**
- Hover: border color ’ orange + lift
- Clickable cards: arrow icon only (no text)
- Arrow changes to orange on hover
- Consistent lift amount (4px)

### 5. Interactive Elements

**Current Issues:**
- L Inconsistent hover states
- L Some elements lack visual feedback

**Interaction States:**

#### Default Interactive Element
```css
.interactive-element {
    transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.interactive-element:hover {
    transform: translateY(-1px);
    /* Plus color change to orange where appropriate */
}

.interactive-element:active {
    transform: translateY(0);
}
```

**Rules:**
- ALL interactive elements MUST have hover state
- Hover = color change OR subtle lift OR both
- Orange is the primary hover color
- Transitions MUST be smooth (0.2-0.3s)

### 6. Form Inputs

**Design:**
```css
.modern-input {
    border: 1px solid rgba(148, 163, 184, 0.2);
    border-radius: 12px;
    background: white;
    padding: 12px 16px;
    transition: all 0.2s;
}

.modern-input:focus {
    outline: none;
    border-color: var(--orange-primary);
    box-shadow: 0 0 0 3px var(--orange-glow);
}

.modern-input:hover:not(:focus) {
    border-color: var(--gray-muted);
}
```

**Rules:**
- Focus: orange border + orange glow
- Hover (not focused): gray border
- Consistent border radius (12px)

## Animation System

### Transition Timing
```css
/* Quick interactions */
--timing-fast: 0.15s

/* Standard interactions */
--timing-standard: 0.2s-0.3s

/* Smooth, noticeable */
--timing-slow: 0.4s-0.6s
```

### Easing Functions
```css
/* Default - smooth start and end */
cubic-bezier(0.4, 0, 0.2, 1)

/* Bounce effect (sparingly) */
cubic-bezier(0.68, -0.55, 0.265, 1.55)
```

### Subtle Animations
```css
/* Fade in up */
@keyframes fadeInUp {
    from {
        opacity: 0;
        transform: translateY(30px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

/* Orange glow pulse (CTAs only) */
@keyframes orangeGlow {
    0%, 100% {
        box-shadow: 0 0 5px var(--orange-glow);
    }
    50% {
        box-shadow: 0 0 20px var(--orange-shadow);
    }
}
```

## Accessibility Guidelines

### Color Contrast
- Text on white: minimum 4.5:1 ratio
- Primary text: #334155 (gray-dark)
- Secondary text: #64748b (gray-muted)
- Orange on white: passes WCAG AA

### Interactive Elements
- Minimum touch target: 44x44px (mobile)
- Clear focus indicators (orange glow)
- Keyboard navigation support
- Skip-to-content links

### Visual Feedback
- Never rely on color alone
- Icon + text for important actions
- Loading states for async actions
- Error messages with icons

## Responsive Design

### Breakpoints
```
Mobile:    < 768px
Tablet:    768px - 1024px
Desktop:   > 1024px
Wide:      > 1280px
```

### Mobile-First Adjustments
- Reduce section spacing (5rem ’ 3rem)
- Stack columns (grid ’ single column)
- Larger touch targets
- Simplified navigation (hamburger)
- Full-width cards with margin

## Page-Specific Considerations

### Homepage
- Hero: Large logo, clear CTAs
- "Jetzt mitmachen" button: Always consistent
- Events section: Clean cards with orange accents
- Principle cards: Arrow-only interaction

### Was ist das?
- Contact buttons: Consistent across all sections
- Testimonial cards: No blue accents, use orange
- Section icons: Minimal, consistent style

### Navigation
- Logo always clickable
- Clear active states
- Orange hover states
- No button transformations

## Design Tokens (CSS Variables)

```css
:root {
    /* Colors */
    --orange-primary: #ea580c;
    --orange-medium: #fb923c;
    --orange-dark: #c2410c;
    --orange-light: #fed7aa;
    --orange-shadow: rgb(234 88 12 / 0.3);
    --orange-glow: rgb(251 146 60 / 0.2);

    --gray-elegant: #f8fafc;
    --gray-soft: #f1f5f9;
    --gray-muted: #64748b;
    --gray-dark: #334155;

    /* Shadows */
    --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
    --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
    --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
    --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1);

    /* Spacing */
    --spacing-xs: 0.5rem;   /* 8px */
    --spacing-sm: 1rem;     /* 16px */
    --spacing-md: 1.5rem;   /* 24px */
    --spacing-lg: 2rem;     /* 32px */
    --spacing-xl: 3rem;     /* 48px */

    /* Border Radius */
    --radius-sm: 8px;
    --radius-md: 12px;
    --radius-lg: 16px;
    --radius-pill: 50px;

    /* Transitions */
    --transition-fast: 0.15s ease;
    --transition-base: 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    --transition-smooth: 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}
```

---

## Implementation Todo List

### Phase 1: Navigation & Core Components (High Priority)
- [ ] **NAV-01**: Make logo clickable (link to home) with opacity hover
- [ ] **NAV-02**: Fix navigation links - remove button appearance on hover
- [ ] **NAV-03**: Implement consistent orange hover color for all nav links
- [ ] **NAV-04**: Ensure all links have visible hover indicators (not just cursor)
- [ ] **LINK-01**: Audit all text links - add orange hover color
- [ ] **LINK-02**: Audit all icon links - add orange hover color + subtle movement

### Phase 2: Button Consistency (High Priority)
- [ ] **BTN-01**: Standardize "Jetzt mitmachen" button size across all pages
- [ ] **BTN-02**: Ensure "Jetzt mitmachen" always has arrow icon
- [ ] **BTN-03**: Remove gradients from default button states
- [ ] **BTN-04**: Standardize "Kontakt aufnehmen" buttons (always with envelope icon)
- [ ] **BTN-05**: Update all primary CTAs to solid orange (no gradient)
- [ ] **BTN-06**: Implement consistent orange hover state for all CTAs
- [ ] **BTN-07**: Ensure "Mehr erfahren" buttons are consistent size

### Phase 3: Card & Interactive Elements (Medium Priority)
- [ ] **CARD-01**: Remove "Mehr erfahren" text from principle cards (keep arrow only)
- [ ] **CARD-02**: Add orange border on hover for all principle cards
- [ ] **CARD-03**: Make arrow icon orange on card hover
- [ ] **CARD-04**: Ensure consistent card lift amount (4px) on hover
- [ ] **CARD-05**: Add orange accent to hoverable elements
- [ ] **INTER-01**: Audit all clickable elements for hover indicators

### Phase 4: Page-Specific Fixes (Medium Priority)
- [ ] **HOME-01**: Fix hero section button consistency
- [ ] **HOME-02**: Ensure events cards use orange accents (not blue)
- [ ] **HOME-03**: Standardize principle card interactions
- [ ] **WAS-01**: Replace blue accents with orange in "Was ist das" page
- [ ] **WAS-02**: Update testimonial card colors (blue ’ orange)
- [ ] **WAS-03**: Ensure CTA sections use consistent button styles
- [ ] **WAS-04**: Update section icons from blue to match brand

### Phase 5: Form & Input Elements (Low Priority)
- [ ] **FORM-01**: Add orange focus states to all inputs
- [ ] **FORM-02**: Add orange glow effect on input focus
- [ ] **FORM-03**: Ensure consistent input border radius (12px)
- [ ] **FORM-04**: Add subtle hover state to inputs

### Phase 6: Animation & Polish (Low Priority)
- [ ] **ANIM-01**: Audit animation timing consistency
- [ ] **ANIM-02**: Ensure smooth transitions (0.2-0.3s) across site
- [ ] **ANIM-03**: Remove any jarring or inconsistent animations
- [ ] **ANIM-04**: Add subtle lift animations to all buttons

### Phase 7: Color System Cleanup (Low Priority)
- [ ] **COLOR-01**: Remove blue accents from homepage
- [ ] **COLOR-02**: Replace all blue accent colors with orange
- [ ] **COLOR-03**: Ensure consistent gray tones across site
- [ ] **COLOR-04**: Audit shadow colors for consistency

### Phase 8: Accessibility & Testing (Final)
- [ ] **A11Y-01**: Test keyboard navigation on all pages
- [ ] **A11Y-02**: Verify color contrast ratios
- [ ] **A11Y-03**: Ensure all interactive elements have focus indicators
- [ ] **A11Y-04**: Test with screen reader
- [ ] **TEST-01**: Mobile responsiveness test
- [ ] **TEST-02**: Cross-browser testing (Chrome, Firefox, Safari)
- [ ] **TEST-03**: Check all hover states work correctly
- [ ] **TEST-04**: Verify consistent spacing across pages

### Phase 9: Documentation & Handoff (Final)
- [ ] **DOC-01**: Create component showcase page
- [ ] **DOC-02**: Document all CSS variables and usage
- [ ] **DOC-03**: Create style guide for future development
- [ ] **DOC-04**: Update README with design system info

---

## Priority Matrix

### Critical (Must Fix Immediately)
1. Logo not clickable ’ broken UX
2. Navigation hover inconsistency ’ confusing
3. Button size inconsistency ’ unprofessional
4. Missing link hover indicators ’ accessibility issue

### High (Fix in Next Sprint)
1. Remove gradients from buttons ’ brand consistency
2. Standardize "Jetzt mitmachen" appearance ’ brand consistency
3. Fix principle card interactions ’ UX improvement
4. Replace blue accents with orange ’ brand consistency

### Medium (Nice to Have)
1. Animation timing polish
2. Form input improvements
3. Card hover refinements

### Low (Future Enhancement)
1. Advanced animations
2. Micro-interactions
3. Loading states polish

---

## Notes for Implementation

### Testing Checklist
For each change, verify:
- [ ] Works on desktop (Chrome, Firefox, Safari)
- [ ] Works on mobile (iOS Safari, Android Chrome)
- [ ] Keyboard navigation works
- [ ] Hover states are consistent
- [ ] No layout shifts on hover
- [ ] Smooth transitions (not jarring)

### Code Review Checklist
- [ ] Uses design tokens (CSS variables)
- [ ] Follows naming conventions
- [ ] No inline styles (use classes)
- [ ] Responsive at all breakpoints
- [ ] Accessibility attributes present
- [ ] Performance impact minimal

---

**Last Updated:** 2025-09-29
**Version:** 1.0
**Author:** Claude Code (Design System Architect)