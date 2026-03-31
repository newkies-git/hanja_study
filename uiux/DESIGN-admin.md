# Design System: High-End Editorial Admin

## 1. Overview & Creative North Star
The "Creative North Star" for this design system is **"The Scholarly Curator."** 

Admin dashboards are traditionally cluttered and utilitarian. We are breaking that mold. For a Hanja (Sino-Korean) learning platform, the UI must mirror the precision and weight of the characters it hosts. We move away from the "template" look by using **intentional asymmetry, deep tonal layering, and an editorial typographic hierarchy.** 

The experience should feel like a premium digital archive. We prioritize white space and breathing room—essential for a data-heavy tool—to prevent cognitive overload. By utilizing "nested depth" instead of rigid grid lines, we create an interface that feels like a series of sophisticated, physical layers rather than a flat, digital table.

---

## 2. Colors
Our palette is a sophisticated interplay of deep architectural blues and "clean-room" whites.

*   **Primary (`#004ac6`) & Primary Container (`#2563eb`):** Use these for high-intent actions. The Primary Container is your "Action Surface," providing a softer, more modern blue for large interaction areas.
*   **Surface Hierarchy (Tonal Depth):** 
    *   **Background (`#f7f9fb`):** The canvas.
    *   **Surface-Container-Low (`#f2f4f6`):** Secondary groupings.
    *   **Surface-Container-Lowest (`#ffffff`):** High-priority data cards.
*   **The "No-Line" Rule:** 1px solid borders are strictly prohibited for sectioning. Contrast must be achieved through background color shifts. For example, a `surface-container-lowest` card sits atop a `surface-container-low` section to define its boundary.
*   **The "Glass & Gradient" Rule:** Floating elements (modals, dropdowns) must use Glassmorphism. Utilize semi-transparent surface colors with a `backdrop-blur` effect.
*   **Signature Textures:** For primary CTAs, use a subtle linear gradient transitioning from `primary` to `primary_container` (Top-to-Bottom). This adds a "soul" and depth that static hex codes lack.

---

## 3. Typography
We use a dual-font strategy to balance character legibility with modern editorial flair.

*   **Display & Headlines (Manrope):** A geometric sans-serif that provides a "high-tech" look. Use `display-lg` for dashboard summaries and `headline-sm` for section titles.
*   **Body & Labels (Inter):** Chosen for its exceptional legibility at small sizes, specifically for multi-script support (Hanja, Korean, English). 
*   **The Hierarchy Rule:** Hanja characters in data tables should be 120% the size of accompanying Korean text to ensure the intricate strokes are visible. Use `title-lg` for Hanja character previews within cards.
*   **Tonal Contrast:** Use `on_surface_variant` (`#434655`) for secondary metadata to create a clear visual hierarchy against the primary `on_surface` text.

---

## 4. Elevation & Depth
Depth in this system is organic, not structural. We avoid heavy dropshadows in favor of **Tonal Layering.**

*   **The Layering Principle:** Stack surfaces like sheets of fine paper. 
    *   Base: `surface`
    *   Sectioning: `surface-container-low`
    *   Active Component: `surface-container-lowest`
*   **Ambient Shadows:** If a component must "float" (e.g., a mobile FAB or a Hanja detail modal), use an ultra-diffused shadow: `box-shadow: 0 10px 30px rgba(25, 28, 30, 0.06)`. The tint is derived from `on-surface`, making it feel like natural light.
*   **The "Ghost Border" Fallback:** If a border is required for accessibility, use `outline-variant` (`#c3c6d7`) at **20% opacity**. Never use 100% opaque borders.

---

## 5. Components

### Buttons
*   **Primary:** Gradient of `primary` to `primary_container`. `rounded-md` (0.375rem). Text: `label-md` in `on_primary`.
*   **Secondary:** `surface-container-highest` background. No border. Text: `on_surface`.
*   **Tertiary:** Ghost style. No background. Use `on_primary_fixed_variant` for text color.

### Hanja Data Cards (Replacing Lists)
*   **Structure:** Avoid 1px dividers. Instead, use `spacing-5` (1.1rem) vertical margin between items. 
*   **Background:** Use `surface-container-lowest` for the card body. 
*   **Mobile Optimization:** On mobile, transform the "data-heavy" table into a vertical stack of cards. The Hanja character is the hero, placed in the top-left using `headline-md`.

### Input Fields
*   **Style:** Minimalist. No bottom line or full border. Use `surface-container-high` as a subtle background fill with `rounded-sm`.
*   **Focus State:** A 2px "Ghost Border" using `primary` at 40% opacity.

### Chips (Category Tags)
*   **Visuals:** Use `secondary_container` background with `on_secondary_container` text. `rounded-full`. These should be used for Hanja difficulty levels (e.g., 8급, 7급).

---

## 6. Do's and Don'ts

### Do
*   **Do** use asymmetrical spacing. A wider left-hand margin on desktop creates a curated, editorial feel.
*   **Do** leverage `title-sm` for Hanja definitions to ensure clear reading of complex strokes.
*   **Do** use `surface-bright` for hover states on list items to create a "glow" effect without adding lines.
*   **Do** prioritize "scannability" by grouping related Hanja radicals using `surface-container-low` backdrops.

### Don't
*   **Don't** use black (`#000000`) for text. Always use `on_surface` (`#191c1e`) to maintain the "professional blue" tonal range.
*   **Don't** use standard "Select All" checkboxes in tables. Use a `surface-variant` chip that toggles state to keep the UI clean.
*   **Don't** use dividers (`<hr>`). Use `spacing-8` (1.75rem) to separate major dashboard modules.
*   **Don't** cram data. If a Hanja character has too many definitions, use a "more" chip using `surface-container-highest` to hide overflow.