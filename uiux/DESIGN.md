# Design System Specification: The Scholar’s Editorial

## 1. Overview & Creative North Star
**Creative North Star: "The Modern Calligrapher"**

This design system moves away from the sterile, "template-driven" feel of typical educational apps. Instead, it adopts a **High-End Editorial** aesthetic that balances the discipline of classical Hanja study with the fluidity of modern digital interactions. 

The system rejects the "boxed-in" layout. By using intentional asymmetry, overlapping layers, and high-contrast typography scales, we create an environment that feels like a premium, custom-bound academic journal. We prioritize "Focus through Depth"—using soft tonal layering to guide the eye toward the Hanja characters, ensuring the student’s cognitive load is reserved for learning, not navigating.

---

## 2. Colors & Surface Philosophy
The palette is rooted in 'Scholar Blue' (#1A56DB), evoking the ink of a master’s brush, set against parchment-like neutrals.

### Surface Hierarchy & The "No-Line" Rule
To achieve a premium feel, **1px solid borders are strictly prohibited for sectioning.** 
- **The Transition Rule:** Define boundaries through background color shifts. A `surface-container-low` section should sit directly on a `surface` background. 
- **Nesting Depth:** Treat the UI as stacked sheets of fine paper. Use `surface-container-lowest` for the primary work area (the "Won-go-ji" grid) and `surface-container-high` for navigation bars to create a natural, physical sense of importance.

### Glass & Gradient Implementation
- **Signature CTAs:** Do not use flat blue. Apply a subtle linear gradient from `primary` (#003fb1) to `primary_container` (#1a56db) at a 135° angle to give buttons a "gem-like" depth.
- **Glassmorphism:** For floating action buttons or modal overlays, use `surface_container_lowest` at 80% opacity with a `24px` backdrop blur. This allows the calligraphy strokes beneath to bleed through, maintaining a cohesive visual narrative.

---

## 3. Typography: The Dual-Script Intent
The typography strategy creates a dialogue between modern instruction and ancient art.

- **The UI Layer (Inter):** Used for all functional labels, instructions, and metadata. It is precise and invisible. 
    - *Title-LG (1.375rem):* Used for lesson titles to provide clear, authoritative anchoring.
- **The Hanja Layer (Noto Serif / Traditional Calligraphy):** Reserved exclusively for Hanja characters. 
    - *Display-LG (3.5rem):* Used in the center of the "Won-go-ji" grid. The high contrast and serif details are essential for the student to observe stroke terminals and weight transitions.

**Editorial Tip:** Use `headline-lg` for meaning/definitions in a slightly tracked-out (letter-spacing: 0.02em) style to give the app a curated, textbook-quality feel.

---

## 4. Elevation & Depth
We eschew traditional shadows in favor of **Tonal Layering**.

- **The Layering Principle:** Depth is achieved by stacking. A `surface-container-lowest` card placed on a `surface-container-low` background creates a "soft lift" that feels organic.
- **Ambient Shadows:** When a component must float (e.g., a stroke-order hint), use a shadow with a `32px` blur, `0%` spread, and `6%` opacity. The shadow color must be a tinted version of `on_surface` (deep navy/grey) rather than true black.
- **The "Ghost Border" Fallback:** If a divider is required for accessibility, use the `outline_variant` token at **15% opacity**. It should be felt, not seen.

---

## 5. Components

### The Won-go-ji (Handwriting Grid)
*The core component of the system.* 
- **Base:** `surface_container_lowest`.
- **Guides:** Use `outline_variant` at 20% opacity for dashed internal cross-sections.
- **Stroke Feedback:** Use `secondary` (#006c4a) for successful strokes and `tertiary` (#98000c) for errors. These colors should feel like ink stains, not neon lights.

### Buttons (The Scholar’s Seal)
- **Primary:** Gradient-filled (`primary` to `primary_container`), `xl` (0.75rem) corner radius. Use `title-md` for text.
- **Secondary:** Transparent background with a "Ghost Border" (15% opacity `outline`).
- **Interaction:** On press, the button should scale down to 96% and the background should shift to `primary_fixed_variant`.

### Input Fields & Text Areas
- **Style:** Minimalist. No bottom line or box. Use a slightly darker background (`surface_container_low`) to define the hit area. 
- **Focus State:** Transition the background to `surface_container_lowest` and add a subtle `primary` glow (4px blur).

### Cards & Lists
- **Rule:** Absolute prohibition of divider lines. 
- **Separation:** Use `spacing-6` (2rem) of vertical white space or a shift from `surface` to `surface_container_low` to separate different character sets or lessons.

---

## 6. Do’s and Don’ts

### Do
- **Do** use intentional asymmetry. Place a Hanja character slightly off-center in a hero section to create an editorial, "designed" look.
- **Do** prioritize the `surface_bright` and `surface_container_lowest` tones to keep the screen feeling like fresh paper.
- **Do** use large touch targets (minimum 48dp) but keep the visual mark (the icon or text) elegantly small within that space.

### Don't
- **Don’t** use pure black (#000000). Always use `on_surface` (#191c1d) to maintain a soft, academic tone.
- **Don’t** use standard Material Design "Drop Shadows." They break the paper-like art direction.
- **Don’t** crowd the Hanja. Each character needs at least `spacing-8` (2.75rem) of "breathing room" to be respected as a piece of art.

### Accessibility Note
While we use "Ghost Borders," ensure that all interactive elements maintain a 4.5:1 contrast ratio for text. The "Scholar Blue" was chosen specifically to exceed these standards while remaining deep and sophisticated.