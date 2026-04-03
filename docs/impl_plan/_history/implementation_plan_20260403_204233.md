# Implementation Plan - Bright Pastel Tone Redesign

The goal is to transition from the current dark theme to a soft, bright pastel aesthetic that feels light, airy, and modern.

## Proposed Changes

### [Frontend] Admin Frontend Visual Overhaul

#### [MODIFY] [LoginView.vue](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/frontend/src/views/LoginView.vue)
-   **Background**: Change from `bg-slate-950` to a light `bg-white` or `bg-slate-50`.
-   **Pastel Blobs**: Update the floating background blobs with soft pastel colors (e.g., Mint, Lavender, and Peach) with lowered opacity and high blur for a "cloud-like" effect.
-   **Light Glassmorphism**: Update the card to use a white-based glassmorphism (`bg-white/70`, `backdrop-blur-xl`) with a more subtle, high-contrast shadow for depth.
-   **Typography**: Switch text colors to dark shades (`text-slate-900`, `text-slate-600`) for accessibility.
-   **Accents**: Update the "漢" logo and the sign-in button to use a cohesive pastel primary color (e.g., a soft indigo or violet).
-   **Inputs**: Modernize input fields with a soft, clean look (light borders, subtle focus rings).

#### [MODIFY] [style.css](file:///Users/yutaek/zWorkSpace/zBasis/HANJA/admin/frontend/src/style.css)
-   Refine or add pastel-specific utility classes if needed, though most can be handled via Tailwind classes in the component.

## Verification Plan

### Manual Verification
-   **Color Contrast**: Ensure all text has sufficient contrast against the pastel backgrounds.
-   **Visual Feel**: Verify the "Bright Pastel" aesthetic matches the user's expectation (soft, airy).
-   **Mobile/Desktop Consistency**: Ensure the light theme looks premium on both viewports.
-   **Functionality**: Confirm the Firebase login flow still works as expected.
