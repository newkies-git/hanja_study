/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "#f7f9fb",
        surface: "#f7f9fb",
        "surface-container-low": "#f2f4f6",
        "surface-container": "#eceef0",
        "surface-container-high": "#e6e8ea",
        "surface-container-lowest": "#ffffff",
        "surface-variant": "#e0e3e5",
        outline: "#737686",
        "outline-variant": "#c3c6d7",
        primary: "#004ac6",
        "primary-container": "#2563eb",
        secondary: "#515f74",
        "secondary-container": "#d5e3fc",
        tertiary: "#943700",
        error: "#ba1a1a",
        "error-container": "#ffdad6",
        "on-surface": "#191c1e",
        "on-surface-variant": "#434655",
        "on-primary": "#ffffff",
        "on-primary-container": "#eeefff",
      },
      fontFamily: {
        headline: ["Manrope", "ui-sans-serif", "system-ui", "sans-serif"],
        body: ["Inter", "ui-sans-serif", "system-ui", "sans-serif"],
        label: ["Inter", "ui-sans-serif", "system-ui", "sans-serif"],
      },
      boxShadow: {
        ambient: "0 10px 30px rgba(25, 28, 30, 0.06)",
      },
    },
  },
  plugins: [],
}
